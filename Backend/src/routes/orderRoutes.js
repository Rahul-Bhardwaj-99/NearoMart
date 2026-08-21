const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth, auth.requireRole('BUYER'), orderController.createOrder);
router.get('/shop', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), orderController.getShopOrders);
router.get('/my', auth, auth.requireRole('BUYER'), orderController.getMyOrders);
router.get('/available-deliveries', auth, auth.requireRole('RIDER'), orderController.getAvailableDeliveries);
router.get('/my-deliveries', auth, auth.requireRole('RIDER'), orderController.getMyDeliveries);
router.get('/rider/stats', auth, auth.requireRole('RIDER'), orderController.getRiderStats);
router.get('/rider/history', auth, auth.requireRole('RIDER'), orderController.getRiderHistory);
router.get('/rider/wallet', auth, auth.requireRole('RIDER'), orderController.getRiderWallet);
router.put('/rider/availability', auth, auth.requireRole('RIDER'), orderController.updateRiderAvailability);
router.put('/:id/accept-delivery', auth, auth.requireRole('RIDER'), orderController.acceptDelivery);
router.get('/:id', auth, orderController.getOrderDetails);
router.put('/:id/status', auth, orderController.updateOrderStatus);
router.put('/:id/replacements', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), orderController.proposeReplacement);
router.put('/:id/replacements/respond', auth, auth.requireRole('BUYER'), orderController.respondToReplacement);
router.post('/:id/review', auth, auth.requireRole('BUYER'), orderController.createReview);
router.get('/shop/:shopId/reviews', orderController.getShopReviews);

module.exports = router;
