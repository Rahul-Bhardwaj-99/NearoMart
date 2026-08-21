const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  productName: { type: String, required: true },
  quantity: { type: Number, required: true },
  unitPrice: { type: Number, required: true },
  replacement: {
    status: { type: String, enum: ['PROPOSED', 'ACCEPTED', 'REJECTED'] },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    productName: { type: String },
    unitPrice: { type: Number },
    proposedAt: { type: Date },
    respondedAt: { type: Date }
  }
});

const orderSchema = new mongoose.Schema({
  orderNumber: { type: String, unique: true, required: true },
  buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
  riderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  orderType: {
    type: String,
    enum: ['DELIVERY', 'PICKUP_CHAT'],
    required: true
  },
  items: [orderItemSchema],
  itemTotal: { type: Number, required: true },
  deliveryFee: { type: Number, default: 0 },
  platformFee: { type: Number, default: 0 },
  grandTotal: { type: Number, required: true },
  paymentMethod: {
    type: String,
    enum: ['RAZORPAY', 'COD', 'CASH_AT_STORE'],
    default: 'COD'
  },
  paymentStatus: {
    type: String,
    enum: ['PENDING', 'PAID', 'FAILED'],
    default: 'PENDING'
  },
  orderStatus: {
    type: String,
    enum: ['PLACED', 'ACCEPTED', 'PACKED', 'DISPATCHED', 'DELIVERED', 'CANCELLED'],
    default: 'PLACED'
  },
  riderEarnings: { type: Number, default: 0 },
  totalDistance: { type: Number, default: 0 },
  deliveryOtp: { type: String },
  pickupOtp: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);
