const mongoose = require('mongoose');
const Order = require('../models/Order');
const Shop = require('../models/Shop');
const Product = require('../models/Product');
const Review = require('../models/Review');
const orderService = require('../services/orderService');

exports.createOrder = async (req, res) => {
  try {
    const { shopId, items, orderType } = req.body;

    if (!shopId || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: 'Shop and at least one item are required' });
    }

    if (!['DELIVERY', 'PICKUP_CHAT'].includes(orderType)) {
      return res.status(400).json({ message: 'Invalid order type' });
    }

    const order = await orderService.createOrder(req.user.id, req.body);

    // Emit socket event to Merchant
    const io = req.app.get('socketio');
    if (io) {
      io.to(shopId.toString()).emit('new_order', order);
    }

    res.status(201).json(order);
  } catch (error) {
    const status = error.message.includes('unavailable') || error.message.includes('Stock changed') ? 409 : 500;
    res.status(status).json({ message: error.message });
  }
};

exports.getShopOrders = async (req, res) => {
  try {
    const orders = await orderService.getShopOrders(req.user.id, req.query.status);
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ buyerId: req.user.id })
      .populate('shopId', 'shopName bannerUrl')
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAvailableDeliveries = async (req, res) => {
  try {
    const orders = await Order.find({
      orderType: 'DELIVERY',
      orderStatus: 'PACKED',
      riderId: { $exists: false }
    })
      .populate('shopId', 'shopName addressText location')
      .sort({ createdAt: 1 });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyDeliveries = async (req, res) => {
  try {
    const orders = await Order.find({ riderId: req.user.id })
      .populate('shopId', 'shopName addressText location')
      .populate('buyerId', 'name phone addresses')
      .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateRiderAvailability = async (req, res) => {
  try {
    const { isAvailable, coordinates } = req.body;
    if (typeof isAvailable !== 'boolean') {
      return res.status(400).json({ message: 'isAvailable must be boolean' });
    }

    const update = { isAvailable };
    if (Array.isArray(coordinates) && coordinates.length === 2) {
      update.lastLocation = { type: 'Point', coordinates };
    }

    const User = require('../models/User');
    const rider = await User.findByIdAndUpdate(req.user.id, update, { new: true })
      .select('isAvailable lastLocation');
    res.status(200).json(rider);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.acceptDelivery = async (req, res) => {
  try {
    // Simulating distance and earnings for the demo/screenshots
    const simulatedDistance = parseFloat((Math.random() * 5 + 1).toFixed(1));
    const simulatedEarnings = Math.round(simulatedDistance * 20);

    const order = await Order.findOneAndUpdate(
      {
        _id: req.params.id,
        orderType: 'DELIVERY',
        orderStatus: 'PACKED',
        riderId: { $exists: false }
      },
      {
        riderId: req.user.id,
        orderStatus: 'DISPATCHED',
        totalDistance: simulatedDistance,
        riderEarnings: simulatedEarnings
      },
      { new: true }
    ).populate('shopId buyerId riderId');

    if (!order) {
      return res.status(409).json({ message: 'This delivery is no longer available' });
    }

    const io = req.app.get('socketio');
    if (io) {
      io.to(order.buyerId._id.toString()).emit('order_status_update', {
        orderId: order._id,
        status: order.orderStatus,
        rider: {
          id: req.user.id,
          name: order.riderId.name,
          phone: order.riderId.phone
        }
      });
      io.to(order.shopId._id.toString()).emit('rider_assigned', {
        orderId: order._id,
        riderId: req.user.id
      });
    }

    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getRiderStats = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const stats = await Order.aggregate([
      { $match: { riderId: new mongoose.Types.ObjectId(req.user.id), orderStatus: 'DELIVERED' } },
      {
        $group: {
          _id: null,
          totalEarnings: { $sum: '$riderEarnings' },
          totalDeliveries: { $sum: 1 },
          todayEarnings: {
            $sum: {
              $cond: [{ $gte: ['$createdAt', today] }, '$riderEarnings', 0]
            }
          },
          todayDeliveries: {
            $sum: {
              $cond: [{ $gte: ['$createdAt', today] }, 1, 0]
            }
          }
        }
      }
    ]);

    const reviewStats = await Review.aggregate([
      { $match: { riderRating: { $exists: true }, riderId: new mongoose.Types.ObjectId(req.user.id) } },
      { $group: { _id: null, avgRating: { $avg: '$riderRating' } } }
    ]);

    const result = stats[0] || { totalEarnings: 0, totalDeliveries: 0, todayEarnings: 0, todayDeliveries: 0 };
    result.rating = reviewStats[0]?.avgRating || 5.0;

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getRiderHistory = async (req, res) => {
  try {
    const orders = await Order.find({
      riderId: req.user.id,
      orderStatus: { $in: ['DELIVERED', 'CANCELLED'] }
    })
    .populate('shopId', 'shopName addressText')
    .sort({ createdAt: -1 });

    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getRiderWallet = async (req, res) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(req.user.id).select('wallet');
    res.status(200).json(user.wallet || { balance: 0, transactions: [] });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderDetails = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('shopId buyerId riderId');
    if (!order) return res.status(404).json({ message: 'Order not found' });

    const isBuyer = order.buyerId._id.toString() === req.user.id;
    const isRider = order.riderId?._id?.toString() === req.user.id;
    const isShopOwner = order.shopId.ownerId.toString() === req.user.id;
    if (!isBuyer && !isRider && !isShopOwner) {
      return res.status(403).json({ message: 'You are not authorized to view this order' });
    }

    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status, deliveryOtp } = req.body;
    const allowedStatuses = ['PLACED', 'ACCEPTED', 'PACKED', 'DISPATCHED', 'DELIVERED', 'CANCELLED'];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ message: 'Invalid order status' });
    }

    const order = await Order.findById(req.params.id).populate('shopId', 'ownerId');
    if (!order) return res.status(404).json({ message: 'Order not found' });

    const isBuyer = order.buyerId.toString() === req.user.id;
    const isShopOwner = order.shopId.ownerId.toString() === req.user.id;
    const isRider = order.riderId?.toString() === req.user.id;
    const transitions = {
      PLACED: ['ACCEPTED', 'CANCELLED'],
      ACCEPTED: ['PACKED', 'CANCELLED'],
      PACKED: ['DISPATCHED', 'CANCELLED'],
      DISPATCHED: ['DELIVERED'],
      DELIVERED: [],
      CANCELLED: []
    };

    const canChange = (isShopOwner && transitions[order.orderStatus].includes(status))
      || (isRider && order.orderStatus === 'DISPATCHED' && status === 'DELIVERED')
      || (isBuyer && ['PLACED', 'ACCEPTED'].includes(order.orderStatus) && status === 'CANCELLED');

    if (!canChange) {
      return res.status(403).json({ message: 'You are not authorized to make this order status change' });
    }

    if (isRider && status === 'DELIVERED' && order.deliveryOtp !== String(deliveryOtp ?? '')) {
      return res.status(400).json({ message: 'Invalid delivery OTP' });
    }

    order.orderStatus = status;
    await order.save();

    // If status is PACKED, broadcast to available riders
    if (status === 'PACKED' && order.orderType === 'DELIVERY') {
      const io = req.app.get('socketio');
      if (io) {
        const fullOrder = await Order.findById(order._id)
          .populate('shopId', 'shopName addressText location')
          .populate('buyerId', 'addresses');

        const buyerAddress = fullOrder.buyerId.addresses.find(a => a.isDefault) || fullOrder.buyerId.addresses[0];

        // Simulating trip details for the dispatch request
        const simulatedDistance = parseFloat((Math.random() * 5 + 1).toFixed(1));
        const simulatedEarnings = Math.round(simulatedDistance * 20);

        io.to('riders').emit('new_dispatch', {
          orderId: fullOrder._id,
          orderNumber: fullOrder.orderNumber,
          shopName: fullOrder.shopId.shopName,
          pickupAddress: fullOrder.shopId.addressText,
          dropoffAddress: buyerAddress?.addressText || 'Address not set',
          orderValue: fullOrder.grandTotal,
          riderEarnings: simulatedEarnings,
          totalDistance: simulatedDistance,
          estimatedTime: Math.round(simulatedDistance * 5)
        });
      }
    }

    // If delivered by rider, credit wallet
    if (isRider && status === 'DELIVERED') {
      const User = require('../models/User');
      await User.findByIdAndUpdate(req.user.id, {
        $inc: { 'wallet.balance': order.riderEarnings, 'wallet.totalEarned': order.riderEarnings },
        $push: {
          'wallet.transactions': {
            amount: order.riderEarnings,
            type: 'CREDIT',
            reason: `Earnings for ${order.orderNumber}`,
            orderId: order._id
          }
        }
      });
    }

    // Emit socket event to Buyer
    const io = req.app.get('socketio');
    if (io) {
      io.to(order.buyerId.toString()).emit('order_status_update', {
        orderId: order._id,
        status: status
      });
    }

    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.proposeReplacement = async (req, res) => {
  try {
    const { itemProductId, replacementProductId } = req.body;
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });

    const shop = await Shop.findOne({ _id: order.shopId, ownerId: req.user.id });
    if (!shop) return res.status(403).json({ message: 'You are not authorized to update this order' });
    if (!['PLACED', 'ACCEPTED'].includes(order.orderStatus)) {
      return res.status(409).json({ message: 'Replacement is no longer available for this order' });
    }

    const item = order.items.find((orderItem) => orderItem.productId.toString() === itemProductId);
    const replacement = await Product.findOne({ _id: replacementProductId, shopId: order.shopId, isAvailable: true });
    if (!item || !replacement) return res.status(400).json({ message: 'Invalid replacement product' });

    item.replacement = {
      status: 'PROPOSED',
      productId: replacement._id,
      productName: replacement.name,
      unitPrice: replacement.discountPrice ?? replacement.price,
      proposedAt: new Date()
    };
    await order.save();
    const io = req.app.get('socketio');
    if (io) io.to(order.buyerId.toString()).emit('replacement_proposed', { orderId: order._id, item });
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.respondToReplacement = async (req, res) => {
  try {
    const { decision } = req.body;
    if (!['ACCEPTED', 'REJECTED'].includes(decision)) {
      return res.status(400).json({ message: 'Invalid replacement decision' });
    }

    const order = await Order.findOne({ _id: req.params.id, buyerId: req.user.id });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    const item = order.items.find((orderItem) => orderItem.replacement?.status === 'PROPOSED');
    if (!item) return res.status(404).json({ message: 'No pending replacement found' });

    item.replacement.status = decision;
    item.replacement.respondedAt = new Date();
    if (decision === 'ACCEPTED') item.productId = item.replacement.productId;
    if (decision === 'ACCEPTED') {
      item.productName = item.replacement.productName;
      item.unitPrice = item.replacement.unitPrice;
    }
    await order.save();
    const io = req.app.get('socketio');
    if (io) io.to(order.shopId.toString()).emit('replacement_decided', { orderId: order._id, item });
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createReview = async (req, res) => {
  try {
    const { rating, comment, mediaUrls = [] } = req.body;
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be an integer from 1 to 5' });
    }

    const order = await Order.findOne({ _id: req.params.id, buyerId: req.user.id });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (order.orderStatus !== 'DELIVERED') return res.status(409).json({ message: 'Only delivered orders can be reviewed' });

    const review = await Review.create({
      orderId: order._id,
      buyerId: req.user.id,
      shopId: order.shopId,
      rating,
      comment,
      mediaUrls
    });

    const stats = await Review.aggregate([
      { $match: { shopId: order.shopId } },
      { $group: { _id: '$shopId', rating: { $avg: '$rating' }, reviewCount: { $sum: 1 } } }
    ]);
    if (stats[0]) {
      await Shop.findByIdAndUpdate(order.shopId, {
        rating: Math.round(stats[0].rating * 10) / 10,
        reviewCount: stats[0].reviewCount
      });
    }
    const io = req.app.get('socketio');
    if (io) {
      io.to(order.shopId.toString()).emit('review_created', { review });
      io.to(`public_shop:${order.shopId}`).emit('review_created', { review });
      io.to(`public_shop:${order.shopId}`).emit('shop_rating_changed', { shopId: order.shopId, rating: stats[0]?.rating, reviewCount: stats[0]?.reviewCount });
    }
    res.status(201).json(review);
  } catch (error) {
    if (error.code === 11000) return res.status(409).json({ message: 'This order has already been reviewed' });
    res.status(500).json({ message: error.message });
  }
};

exports.getShopReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ shopId: req.params.shopId })
      .populate('buyerId', 'name profilePic')
      .sort({ createdAt: -1 })
      .limit(50);
    res.status(200).json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
