const Special = require('../models/Special');

exports.getActiveBanners = async (req, res) => {
  try {
    const banners = await Special.find({
      type: 'SPECIAL_OFFER',
      expiresAt: { $gt: new Date() }
    }).populate('shopId', 'shopName');

    res.status(200).json(banners);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createBanner = async (req, res) => {
  try {
    const banner = new Special(req.body);
    await banner.save();
    res.status(201).json(banner);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
