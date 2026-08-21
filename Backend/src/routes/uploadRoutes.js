const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const auth = require('../middleware/authMiddleware');

router.post('/presigned-url', auth, uploadController.getPresignedUrl);
router.post('/files', auth, uploadController.uploadToGridFs);
router.get('/files/:id', auth.optional, uploadController.getGridFsFile);

module.exports = router;
