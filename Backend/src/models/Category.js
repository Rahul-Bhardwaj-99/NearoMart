const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  icon: { type: String },
  isActive: { type: Boolean, default: true },
  displayOrder: { type: Number, default: 0 }
});

module.exports = mongoose.model('Category', categorySchema);
