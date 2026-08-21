const Shop = require('../models/Shop');
const Order = require('../models/Order');
const User = require('../models/User');
const { SHOP_PUBLIC_FIELDS } = require('../utils/projections');

class ShopService {
  async createShop(ownerId, shopData) {
    const {
      shopName,
      category,
      addressText,
      location,
      gstin,
      fssaiLicense,
      drugLicense,
      bankDetails,
      coordinates,
      lat,
      lng
    } = shopData;

    if (!shopName || !addressText) {
      throw new Error('Shop name and address are required');
    }

    let normalizedLocation = location;
    if (!normalizedLocation && Array.isArray(coordinates) && coordinates.length === 2) {
      normalizedLocation = { type: 'Point', coordinates };
    } else if (!normalizedLocation && lat !== undefined && lng !== undefined) {
      normalizedLocation = { type: 'Point', coordinates: [Number(lng), Number(lat)] };
    }

    if (!normalizedLocation || !Array.isArray(normalizedLocation.coordinates) || normalizedLocation.coordinates.length !== 2) {
      throw new Error('Valid shop coordinates are required');
    }

    const shop = new Shop({
      ownerId,
      shopName,
      category: Array.isArray(category)
        ? category
        : (category ? category.split(',').map((c) => c.trim()).filter(Boolean) : []),
      addressText,
      location: normalizedLocation,
      gstin,
      fssaiLicense,
      drugLicense,
      bankDetails,
      kycStatus: 'PENDING',
      deliveryEnabled: false,
      isOpen: true
    });

    await shop.save();
    await User.findByIdAndUpdate(ownerId, { isOnboarded: true, role: 'SHOPKEEPER' });
    return shop;
  }

  async getNearbyShops(lng, lat, radius = 5) {
    if (!lng || !lat) {
      throw new Error('Longitude and Latitude are required');
    }

    return await Shop.find({
      location: {
        $nearSphere: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)]
          },
          $maxDistance: radius * 1000
        }
      }
    }).select(SHOP_PUBLIC_FIELDS);
  }

  async getDashboardStats(ownerId) {
    const shop = await Shop.findOne({ ownerId });
    if (!shop) throw new Error('Shop not found');

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const stats = await Order.aggregate([
      { $match: { shopId: shop._id, createdAt: { $gte: today } } },
      {
        $group: {
          _id: null,
          todayRevenue: { $sum: '$grandTotal' },
          totalOrders: { $sum: 1 },
          pendingOrders: {
            $sum: { $cond: [{ $in: ['$orderStatus', ['PLACED', 'ACCEPTED', 'PACKED']] }, 1, 0] }
          }
        }
      }
    ]);

    const result = stats.length > 0 ? stats[0] : { todayRevenue: 0, totalOrders: 0, pendingOrders: 0 };

    return {
      ...result,
      rating: shop.rating,
      reviewCount: shop.reviewCount
    };
  }
}

module.exports = new ShopService();
