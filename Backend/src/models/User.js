const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  label: { type: String, required: true },
  isDefault: { type: Boolean, default: false },
  addressText: { type: String, required: true },
  fullName: { type: String },
  phoneNumber: { type: String },
  flatDetail: { type: String },
  location: {
    type: { type: String },
    coordinates: { type: [Number], index: '2dsphere' }
  }
});

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true },
  firebaseUid: { type: String },
  role: {
    type: String,
    enum: ['BUYER', 'SHOPKEEPER', 'RIDER', 'ADMIN']
  },
  name: { type: String },
  email: { type: String },
  profilePic: { type: String },
  fcmToken: { type: String },
  isAvailable: { type: Boolean, default: false },
  lastLocation: {
    type: { type: String },
    coordinates: { type: [Number] }
  },
  addresses: [addressSchema],
  followedShops: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Shop' }],
  riderProfile: {
    vehicleType: { type: String, enum: ['BIKE', 'SCOOTER', 'CYCLE', 'OTHER'] },
    vehicleNumber: { type: String },
    licenseNumber: { type: String },
    kycStatus: { type: String, enum: ['NONE', 'PENDING', 'APPROVED', 'REJECTED'], default: 'NONE' }
  },
  wallet: {
    balance: { type: Number, default: 0 },
    totalEarned: { type: Number, default: 0 },
    transactions: [{
      amount: { type: Number },
      type: { type: String, enum: ['CREDIT', 'DEBIT'] },
      reason: { type: String },
      orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
      date: { type: Date, default: Date.now }
    }]
  },
  bankDetails: {
    accountNumber: { type: String },
    ifsc: { type: String },
    bankName: { type: String },
    accountHolder: { type: String }
  },
  isVerified: { type: Boolean, default: false },
  isOnboarded: { type: Boolean, default: false },
  invalidatedAt: { type: Date },
  updateOtp: { type: String },
  tempEmail: { type: String },
  tempPhone: { type: String },
  createdAt: { type: Date, default: Date.now }
});

userSchema.index({ lastLocation: '2dsphere' });

module.exports = mongoose.model('User', userSchema);
