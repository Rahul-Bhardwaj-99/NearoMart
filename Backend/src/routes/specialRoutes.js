const express = require('express');
const router = express.Router();
const specialController = require('../controllers/specialController');
const auth = require('../middleware/authMiddleware');

router.post('/', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), specialController.createSpecial);
router.get('/my', auth, specialController.getMySpecials);
router.put('/:id', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), specialController.updateSpecial);
router.delete('/:id', auth, auth.requireRole('SHOPKEEPER', 'ADMIN'), specialController.deleteSpecial);

module.exports = router;
