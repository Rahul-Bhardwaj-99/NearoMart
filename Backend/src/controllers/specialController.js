const Special = require('../models/Special');
const Shop = require('../models/Shop');

exports.createSpecial = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const special = new Special({
      ...req.body,
      shopId: shop._id
    });
    await special.save();
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('special_created', { special });
      io.to(`public_shop:${shop._id}`).emit('special_created', { special });
    }
    res.status(201).json(special);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMySpecials = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const specials = await Special.find({ shopId: shop._id }).sort({ createdAt: -1 });
    res.status(200).json(specials);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteSpecial = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const special = await Special.findOneAndDelete({ _id: req.params.id, shopId: shop._id });
    if (!special) return res.status(404).json({ message: 'Special not found' });
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('special_deleted', { specialId: req.params.id });
      io.to(`public_shop:${shop._id}`).emit('special_deleted', { specialId: req.params.id });
    }
    res.status(200).json({ message: 'Special deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateSpecial = async (req, res) => {
  try {
    const shop = await Shop.findOne({ ownerId: req.user.id });
    if (!shop) return res.status(404).json({ message: 'Shop not found' });

    const allowedFields = ['type', 'title', 'imageUrl', 'price', 'expiresAt'];
    const updateData = Object.fromEntries(
      allowedFields
        .filter((field) => Object.prototype.hasOwnProperty.call(req.body, field))
        .map((field) => [field, req.body[field]])
    );
    const special = await Special.findOneAndUpdate(
      { _id: req.params.id, shopId: shop._id },
      updateData,
      { new: true, runValidators: true }
    );

    if (!special) return res.status(404).json({ message: 'Special not found' });
    const io = req.app.get('socketio');
    if (io) {
      io.to(shop._id.toString()).emit('special_updated', { special });
      io.to(`public_shop:${shop._id}`).emit('special_updated', { special });
    }
    res.status(200).json(special);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
