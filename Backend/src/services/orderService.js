const Order = require('../models/Order');
const Shop = require('../models/Shop');
const Product = require('../models/Product');
const mongoose = require('mongoose');

class OrderService {
  async createOrder(buyerId, orderData) {
    const { shopId, items, orderType, paymentMethod } = orderData;
    const reservedItems = [];

    try {
      // 1. Validate Shop
      const shop = await Shop.findById(shopId);
      if (!shop) throw new Error('Shop not found');
      if (orderType === 'DELIVERY' && !shop.deliveryEnabled) {
        throw new Error('Delivery is currently disabled by this shop');
      }

      // 2. Normalize and Validate Items
      const productIds = items.map((item) => item.productId);
      const products = await Product.find({ _id: { $in: productIds }, shopId });
      const productById = new Map(products.map((p) => [p._id.toString(), p]));

      const normalizedItems = [];
      for (const item of items) {
        const product = productById.get(String(item.productId));
        const quantity = Number(item.quantity);

        if (!product || !Number.isInteger(quantity) || quantity <= 0) {
          throw new Error('One or more order items are invalid');
        }

        if (!product.isAvailable || product.stockQuantity < quantity) {
          throw new Error(`${product.name} is unavailable or out of stock`);
        }

        normalizedItems.push({
          productId: product._id,
          productName: product.name,
          quantity,
          unitPrice: product.discountPrice ?? product.price
        });
      }

      // 3. Reserve Stock (Atomic)
      for (const item of normalizedItems) {
        const reservedProduct = await Product.findOneAndUpdate(
          {
            _id: item.productId,
            isAvailable: true,
            stockQuantity: { $gte: item.quantity }
          },
          { $inc: { stockQuantity: -item.quantity } },
          { new: true }
        );

        if (!reservedProduct) {
          // Rollback previous reservations
          await this._rollbackStock(reservedItems);
          throw new Error('Stock changed. Please review your cart and try again.');
        }
        reservedItems.push(item);
      }

      // 4. Calculate Totals
      const itemTotal = normalizedItems.reduce((acc, item) => acc + (item.unitPrice * item.quantity), 0);
      const deliveryFee = orderType === 'DELIVERY' ? 25 : 0;
      const platformFee = 5;
      const grandTotal = itemTotal + deliveryFee + platformFee;

      // 5. Create Order
      const order = new Order({
        orderNumber: `ORD-${Date.now()}`,
        buyerId,
        shopId,
        items: normalizedItems,
        orderType,
        itemTotal,
        deliveryFee,
        platformFee,
        grandTotal,
        paymentMethod,
        deliveryOtp: Math.floor(1000 + Math.random() * 9000).toString(),
        pickupOtp: Math.floor(1000 + Math.random() * 9000).toString(),
      });

      await order.save();
      return order;

    } catch (error) {
      await this._rollbackStock(reservedItems);
      throw error;
    }
  }

  async _rollbackStock(items) {
    for (const item of items) {
      await Product.updateOne(
        { _id: item.productId },
        { $inc: { stockQuantity: item.quantity } }
      );
    }
  }

  async getShopOrders(ownerId, status) {
    const shop = await Shop.findOne({ ownerId });
    if (!shop) throw new Error('Shop not found');

    let filter = { shopId: shop._id };
    if (status === 'NEW') filter.orderStatus = 'PLACED';
    else if (status === 'ACTIVE') filter.orderStatus = { $in: ['ACCEPTED', 'PACKED', 'DISPATCHED'] };
    else if (status === 'DONE') filter.orderStatus = { $in: ['DELIVERED', 'CANCELLED'] };

    return await Order.find(filter)
      .select('-deliveryOtp -pickupOtp')
      .populate('buyerId', 'name phone')
      .sort({ createdAt: -1 });
  }
}

module.exports = new OrderService();
