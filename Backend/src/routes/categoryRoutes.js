const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const auth = require('../middleware/authMiddleware');

router.get('/', categoryController.getCategories);
router.post('/', auth, auth.requireRole('ADMIN'), categoryController.createCategory);

module.exports = router;
