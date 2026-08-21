const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { USER_SELF_FIELDS } = require('../utils/projections');

class AuthService {
  normalizeRole(role) {
    if (!role) return null;
    const normalized = String(role).trim().toUpperCase();
    const mappedRole = normalized === 'MERCHANT' ? 'SHOPKEEPER' : normalized;
    return ['BUYER', 'SHOPKEEPER', 'RIDER', 'ADMIN'].includes(mappedRole) ? mappedRole : null;
  }

  normalizePhone(phone) {
    if (!phone) return null;
    const digits = String(phone).replace(/\D/g, '');
    return digits.length >= 10 ? digits.slice(-10) : digits;
  }

  generateToken(user) {
    const role = this.normalizeRole(user.role);
    return jwt.sign(
      { id: user._id.toString(), role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );
  }

  async getProfile(userId) {
    const user = await User.findById(userId).select(USER_SELF_FIELDS);
    if (!user) throw new Error('User not found');

    const profile = user.toObject();
    if (!profile.name && user.addresses.length > 0) {
      const defaultAddress = user.addresses.find(addr => addr.isDefault) || user.addresses[0];
      if (defaultAddress && defaultAddress.fullName) {
        profile.name = defaultAddress.fullName;
      }
    }

    let nextStep = 'ROLE_SELECTION';
    let ready = false;

    if (user.role === 'BUYER') {
      const hasAddress = user.addresses.some((address) => address.addressText);
      nextStep = hasAddress ? 'READY' : 'ADDRESS_SETUP';
      ready = hasAddress;
    } else if (user.role === 'SHOPKEEPER') {
      const Shop = require('../models/Shop');
      const shop = await Shop.findOne({ ownerId: user._id }).select('_id kycStatus');
      nextStep = shop ? 'READY' : 'MERCHANT_KYC';
      ready = Boolean(shop);
    } else if (user.role === 'RIDER') {
      nextStep = 'READY';
      ready = true;
    }

    profile.onboarding = {
      roleSelected: Boolean(user.role),
      profileCreated: Boolean(user.name || user.phone),
      profileComplete: Boolean(user.name),
      addressComplete: user.addresses.length > 0,
      ready,
      nextStep
    };
    return profile;
  }
}

module.exports = new AuthService();
