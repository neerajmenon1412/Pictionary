const express = require('express');
const multer = require('multer');
const formatController = require('../controllers/formatController');

const router = express.Router();
const upload = multer({ dest: 'uploads/' });

router.post('/upload', upload.single('video'), formatController.uploadVideo);
router.get('/:id/:format', formatController.getVideo);

module.exports = router;
