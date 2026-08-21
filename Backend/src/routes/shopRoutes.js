const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shopController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), shopController.createShop);
router.get('/nearby', shopController.getNearbyShops);
router.get('/my-shop', auth, shopController.getMyShop);
router.put('/my-shop', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), shopController.updateMyShop);
router.put('/my-shop/status', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), shopController.updateShopStatus);
router.get('/dashboard-stats', auth, shopController.getDashboardStats);
router.get('/analytics', auth, shopController.getAnalytics);
router.post('/broadcast', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), shopController.broadcastAnnouncement);
router.get('/:id', shopController.getShopDetails);
router.put('/toggle-delivery', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), shopController.toggleDelivery);

module.exports = router;
