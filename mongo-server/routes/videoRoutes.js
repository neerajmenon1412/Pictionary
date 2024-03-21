const express = require('express');
const router = express.Router();
const videoService = require('../services/videoServices.js');


router.post('/upload', (req, res) => {
  videoService.uploadVideo(req, res);
});

router.get('/:id', (req, res) => {
  videoService.getVideoById(req, res);
});

router.delete('/:id', (req, res) => {
  videoService.deleteVideo(req, res);
});

module.exports = router;
