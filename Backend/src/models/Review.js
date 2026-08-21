const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String },
  riderRating: { type: Number, min: 1, max: 5 },
  riderComment: { type: String },
  mediaUrls: [{ type: String }],
  createdAt: { type: Date, default: Date.now }
});

reviewSchema.index({ orderId: 1, buyerId: 1 }, { unique: true });

module.exports = mongoose.model('Review', reviewSchema);
