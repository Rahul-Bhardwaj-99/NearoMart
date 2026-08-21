const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth, chatController.getChatList);
router.get('/:chatId', auth, chatController.getChatHistory);
router.put('/:chatId/read', auth, chatController.markChatRead);
router.post('/:chatId/end', auth, auth.requireRole('BUYER'), chatController.endChat);
router.post('/', auth, auth.requireRole('BUYER'), chatController.createChat);

module.exports = router;
