const Product = require('../models/Product');
const Shop = require('../models/Shop');

exports.addProduct = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const product = new Product({
      ...req.body,
      shopId: shop._id
    });
    await product.save();
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('product_created', { product });
      io.to(`public_shop:${shop._id}`).emit('product_created', { product });
    }
    res.status(201).json(product);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getShopProducts = async (req, res) => {
  try {
    const products = await Product.find({ shopId: req.params.shopId });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMyProducts = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const { filter } = req.query;
    let query = { shopId: shop._id };

    if (filter === 'IN_STOCK') {
      query.stockQuantity = { $gt: 5 };
      query.isAvailable = true;
    } else if (filter === 'LOW_STOCK') {
      query.stockQuantity = { $gt: 0, $lte: 5 };
    } else if (filter === 'OUT_OF_STOCK') {
      query.stockQuantity = 0;
    }

    const products = await Product.find(query).sort({ createdAt: -1 });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop || product.shopId.toString() !== shop._id.toString()) {
      return res.status(403).json({ message: 'You are not authorized to update this product' });
    }

    const allowedFields = [
      'name',
      'brand',
      'description',
      'category',
      'price',
      'discountPrice',
      'unit',
      'stockQuantity',
      'lowStockThreshold',
      'isAvailable',
      'imageUrl',
      'tags'
    ];
    const updateData = Object.fromEntries(
      allowedFields
        .filter((field) => Object.prototype.hasOwnProperty.call(req.body, field))
        .map((field) => [field, req.body[field]])
    );

    const updatedProduct = await Product.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true
    });
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('product_updated', { product: updatedProduct });
      io.to(`public_shop:${shop._id}`).emit('product_updated', { product: updatedProduct });
    }
    res.status(200).json(updatedProduct);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop || product.shopId.toString() !== shop._id.toString()) {
      return res.status(403).json({ message: 'You are not authorized to delete this product' });
    }

    await Product.findByIdAndDelete(req.params.id);
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('product_deleted', { productId: req.params.id });
      io.to(`public_shop:${shop._id}`).emit('product_deleted', { productId: req.params.id });
    }
    res.status(200).json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.searchProducts = async (req, res) => {
  try {
    const { query } = req.query;
    const products = await Product.find({ $text: { $search: query } });
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getInventoryStats = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const allCount = await Product.countDocuments({ shopId: shop._id });
    const inStock = await Product.countDocuments({ shopId: shop._id, stockQuantity: { $gt: 5 }, isAvailable: true });
    const lowStock = await Product.countDocuments({ shopId: shop._id, stockQuantity: { $gt: 0, $lte: 5 } });
    const outOfStock = await Product.countDocuments({ shopId: shop._id, stockQuantity: 0 });

    res.status(200).json({ allCount, inStock, lowStock, outOfStock });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
