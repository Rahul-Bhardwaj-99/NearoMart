const mongoose = require('mongoose');

const specialSchema = new mongoose.Schema({
  shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
  type: {
    type: String,
    enum: ['SPECIAL_OFFER', 'STORY'],
    required: true
  },
  title: { type: String },
  imageUrl: { type: String, required: true },
  price: { type: Number },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true }
});

specialSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('Special', specialSchema);
