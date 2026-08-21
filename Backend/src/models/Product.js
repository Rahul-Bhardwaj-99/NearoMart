const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
  name: { type: String, required: true },
  brand: { type: String },
  description: { type: String },
  category: { type: String, required: true },
  price: { type: Number, required: true },
  discountPrice: { type: Number },
  unit: { type: String, required: true },
  stockQuantity: { type: Number, default: 0 },
  lowStockThreshold: { type: Number, default: 5 },
  isAvailable: { type: Boolean, default: true },
  imageUrl: { type: String },
  tags: [{ type: String }],
  createdAt: { type: Date, default: Date.now }
});

productSchema.index({ name: 'text', tags: 'text' });

module.exports = mongoose.model('Product', productSchema);
