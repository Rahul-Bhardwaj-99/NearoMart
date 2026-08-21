const Shop = require('../models/Shop');
const Order = require('../models/Order');
const User = require('../models/User');
const shopService = require('../services/shopService');
const { SHOP_PUBLIC_FIELDS } = require('../utils/projections');

exports.createShop = async (req, res) => {
  try {
    const shop = await shopService.createShop(req.user.id, req.body);
    res.status(201).json(shop);
  } catch (error) {
    const status = error.message.includes('required') ? 400 : 500;
    res.status(status).json({ message: error.message });
  }
};

exports.getNearbyShops = async (req, res) => {
  try {
    const { lng, lat, radius } = req.query;
    const shops = await shopService.getNearbyShops(lng, lat, radius);
    res.status(200).json(shops);
  } catch (error) {
    const status = error.message.includes('required') ? 400 : 500;
    res.status(status).json({ message: error.message });
  }
};

exports.getShopDetails = async (req, res) => {
  try {
    const shop = await Shop.findById(req.params.id).select(SHOP_PUBLIC_FIELDS);
    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    res.status(200).json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyShop = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    res.status(200).json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateMyShop = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const allowedFields = [
      'shopName',
      'category',
      'addressText',
      'location',
      'gstin',
      'fssaiLicense',
      'drugLicense',
      'bankDetails',
      'bannerUrl',
      'deliveryRadiusKm',
      'minOrderValue'
    ];
    const updateData = Object.fromEntries(
      allowedFields
        .filter((field) => Object.prototype.hasOwnProperty.call(req.body, field))
        .map((field) => [field, req.body[field]])
    );
    if (updateData.location && (!Array.isArray(updateData.location.coordinates)
      || updateData.location.coordinates.length !== 2)) {
      return res.status(400).json({ message: 'Valid shop coordinates are required' });
    }

    const updatedShop = await Shop.findByIdAndUpdate(shop._id, updateData, {
      new: true,
      runValidators: true
    });
    const io = req.app.get('socketio');
    if (io) io.emit('shop_updated', { shopId: updatedShop._id, shop: updatedShop });
    res.status(200).json(updatedShop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateShopStatus = async (req, res) => {
  try {
    const { isOpen } = req.body;
    if (typeof isOpen !== 'boolean') {
      return res.status(400).json({ message: 'isOpen must be boolean' });
    }
    const shop = await Shop.findOneAndUpdate(
      { ownerId: req.user.id },
      { isOpen },
      { new: true, runValidators: true }
    );
    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    const io = req.app.get('socketio');
    if (io) io.emit('shop_status_changed', { shopId: shop._id, isOpen });
    res.status(200).json(shop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.toggleDelivery = async (req, res) => {
  try {
    const { shopId, status } = req.body;
    if (typeof status !== 'boolean') {
      return res.status(400).json({ message: 'status must be boolean' });
    }
    const shop = await Shop.findById(shopId);

    if (!shop) {
      return res.status(404).json({ message: 'Shop not found' });
    }

    if (shop.ownerId.toString() !== req.user.id) {
      return res.status(403).json({ message: 'You are not authorized to modify this shop' });
    }

    const updatedShop = await Shop.findByIdAndUpdate(shopId, { deliveryEnabled: status }, { new: true });

    const io = req.app.get('socketio');
    if (io) {
      io.emit('shop_delivery_status_changed', { shopId, deliveryEnabled: status });
    }

    res.status(200).json(updatedShop);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getDashboardStats = async (req, res) => {
  try {
    const stats = await shopService.getDashboardStats(req.user.id);
    res.status(200).json(stats);
  } catch (error) {
    const status = error.message.includes('not found') ? 404 : 500;
    res.status(status).json({ message: error.message });
  }
};

exports.getAnalytics = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const weeklyRevenue = await Order.aggregate([
      { $match: { shopId: shop._id, createdAt: { $gte: sevenDaysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          revenue: { $sum: "$grandTotal" }
        }
      },
      { $sort: { "_id": 1 } }
    ]);

    const orderDistribution = await Order.aggregate([
      { $match: { shopId: shop._id } },
      {
        $group: {
          _id: "$orderType",
          count: { $sum: 1 }
        }
      }
    ]);

    res.status(200).json({
      weeklyRevenue,
      orderDistribution
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.broadcastAnnouncement = async (req, res) => {
  try {
    const { message } = req.body;
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const io = req.app.get('socketio');
    if (io) {
      // Broadcast to all users in the shop's vicinity or followers
      // For now, we broadcast a generic 'shop_announcement' event
      io.emit('shop_announcement', {
        shopId: shop._id,
        shopName: shop.shopName,
        message: message
      });
    }

    res.status(200).json({ message: 'Broadcast sent successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
