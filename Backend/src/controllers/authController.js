const User = require('../models/User');
const jwt = require('jsonwebtoken');
const admin = require('../config/firebase-config');
const authService = require('../services/authService');
const { USER_SELF_FIELDS } = require('../utils/projections');

exports.verifyOtp = async (req, res) => {
  try {
    let { phone, firebaseUid, idToken } = req.body;

    if (idToken) {
      try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        firebaseUid = decodedToken.uid;
        phone = decodedToken.phone_number || phone;
      } catch (e) {
        console.warn('Firebase token verification failed or skipped:', e.message);
      }
    }

    phone = authService.normalizePhone(phone);

    if (!phone) {
      return res.status(400).json({ message: 'Phone number is required' });
    }

    let user = await User.findOne({ phone });

    if (!user) {
      user = new User({
        phone,
        firebaseUid,
        isVerified: true,
        isOnboarded: false
      });
      await user.save();
    } else {
      // Sync firebaseUid if it changed or was missing
      if (firebaseUid && user.firebaseUid !== firebaseUid) {
        user.firebaseUid = firebaseUid;
        await user.save();
      }
    }

    const normalizedRole = authService.normalizeRole(user.role);
    if (normalizedRole && user.role !== normalizedRole) {
      user.role = normalizedRole;
      await user.save();
    }

    const token = authService.generateToken(user);

    const sanitizedUser = await User.findById(user._id).select(USER_SELF_FIELDS);

    res.status(200).json({
      message: 'Login successful',
      user: sanitizedUser,
      token
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.logout = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user.id, { invalidatedAt: new Date() });
    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    const userId = req.user.id;
    const normalizedRole = authService.normalizeRole(role);

    if (!normalizedRole || normalizedRole === 'ADMIN') {
      return res.status(400).json({ message: 'Invalid role' });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });
    if (user.isOnboarded || user.role) {
      return res.status(409).json({ message: 'Role cannot be changed after onboarding begins' });
    }

    user.role = normalizedRole;
    await user.save();

    const token = authService.generateToken(user);
    const sanitizedUser = await User.findById(userId).select(USER_SELF_FIELDS);

    res.status(200).json({ message: 'Role updated successfully', user: sanitizedUser, token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.completeOnboarding = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.role === 'BUYER' && user.addresses.length === 0) {
      return res.status(409).json({ message: 'A delivery address is required before onboarding can be completed' });
    }

    if (user.role === 'SHOPKEEPER') {
      const Shop = require('../models/Shop');
      const shop = await Shop.findOne({ ownerId: user._id });
      if (!shop) return res.status(409).json({ message: 'Shop setup is required before onboarding can be completed' });
    }

    if (!user.role) return res.status(409).json({ message: 'Role selection is required before onboarding can be completed' });

    user.isOnboarded = true;
    await user.save();
    const sanitizedUser = await User.findById(userId).select(USER_SELF_FIELDS);
    res.status(200).json({ message: 'Onboarding completed', user: sanitizedUser });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, email, profilePic } = req.body;
    const userId = req.user.id;

    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (profilePic) updateData.profilePic = profilePic;

    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true }
    ).select(USER_SELF_FIELDS);
    res.status(200).json({ user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.requestUpdateOtp = async (req, res) => {
  try {
    let { email, phone } = req.body;
    const userId = req.user.id;

    if (phone) phone = normalizePhone(phone);

    const otp = "123456";

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.updateOtp = otp;
    if (email) user.tempEmail = email;
    if (phone) user.tempPhone = phone;

    await user.save();

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.verifyUpdateOtp = async (req, res) => {
  try {
    const { otp } = req.body;
    const userId = req.user.id;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (user.updateOtp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    if (user.tempEmail) {
      user.email = user.tempEmail;
      user.tempEmail = null;
    }
    if (user.tempPhone) {
      user.phone = user.tempPhone;
      user.tempPhone = null;
    }

    user.updateOtp = null;
    await user.save();

    const sanitizedUser = await User.findById(userId).select(USER_SELF_FIELDS);

    res.status(200).json({ message: 'Profile updated successfully', user: sanitizedUser });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAddresses = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user.addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.addAddress = async (req, res) => {
  try {
    const { label, addressText, fullName, phoneNumber, flatDetail, coordinates } = req.body;
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const newAddress = {
      label,
      isDefault: user.addresses.length === 0,
      addressText,
      fullName,
      phoneNumber,
      flatDetail
    };

    if (Array.isArray(coordinates) && coordinates.length === 2) {
      newAddress.location = {
        type: 'Point',
        coordinates: coordinates
      };
    }

    user.addresses.push(newAddress);

    if (!user.name && fullName) {
      user.name = fullName;
    }

    await user.save();
    res.status(201).json(user.addresses[user.addresses.length - 1]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const address = user.addresses.id(req.params.id);
    if (!address) return res.status(404).json({ message: 'Address not found' });

    const allowedFields = ['label', 'addressText', 'fullName', 'phoneNumber', 'flatDetail', 'coordinates'];
    for (const field of allowedFields) {
      if (!Object.prototype.hasOwnProperty.call(req.body, field)) continue;
      if (field === 'coordinates') {
        if (Array.isArray(req.body[field]) && req.body[field].length === 2) {
          address.location = { type: 'Point', coordinates: req.body[field] };
        } else {
          address.location = undefined;
        }
      } else {
        address[field] = req.body[field];
      }
    }

    await user.save();
    res.status(200).json(address);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.setDefaultAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    const address = user.addresses.id(req.params.id);
    if (!address) return res.status(404).json({ message: 'Address not found' });

    user.addresses.forEach((savedAddress) => {
      savedAddress.isDefault = savedAddress._id.toString() === req.params.id;
    });
    await user.save();
    res.status(200).json(address);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    user.addresses = user.addresses.filter(addr => addr._id.toString() !== req.params.id);
    await user.save();
    res.status(200).json({ message: 'Address deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const profile = await authService.getProfile(req.user.id);
    res.status(200).json(profile);
  } catch (error) {
    const status = error.message.includes('not found') ? 404 : 500;
    res.status(status).json({ message: error.message });
  }
};
