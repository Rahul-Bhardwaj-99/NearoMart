const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), productController.addProduct);
router.get('/my-products', auth, productController.getMyProducts);
router.get('/inventory-stats', auth, productController.getInventoryStats);
router.get('/shop/:shopId', productController.getShopProducts);
router.get('/search', productController.searchProducts);
router.put('/:id', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), productController.updateProduct);
router.delete('/:id', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), productController.deleteProduct);

module.exports = router;
