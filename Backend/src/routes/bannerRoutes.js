const express = require('express');
const router = express.Router();
const bannerController = require('../controllers/bannerController');
const auth = require('../middleware/authMiddleware');

router.get('/', bannerController.getActiveBanners);
router.post('/', auth, auth.requireRole('ADMIN'), bannerController.createBanner);

module.exports = router;
