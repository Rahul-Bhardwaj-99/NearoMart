const mongoose = require('mongoose');

const shopSchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  shopName: { type: String, required: true },
  category: [{ type: String }],
  deliveryEnabled: { type: Boolean, default: false },
  deliveryRadiusKm: { type: Number, default: 5.0 },
  minOrderValue: { type: Number, default: 0 },
  kycStatus: {
    type: String,
    enum: ['PENDING', 'APPROVED', 'REJECTED'],
    default: 'PENDING'
  },
  // Documents
  gstin: { type: String },
  fssaiLicense: { type: String },
  drugLicense: { type: String },

  // Bank Details
  bankDetails: {
    accountHolderName: { type: String },
    bankName: { type: String },
    accountNumber: { type: String },
    ifscCode: { type: String }
  },

  location: {
    type: { type: String, default: 'Point' },
    coordinates: { type: [Number], required: true }
  },
  addressText: { type: String, required: true },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  bannerUrl: { type: String },
  qrCodeUrl: { type: String },
  isOpen: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

shopSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Shop', shopSchema);
