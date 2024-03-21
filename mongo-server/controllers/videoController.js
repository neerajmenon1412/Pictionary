const videoService = require('../services/videoServices');

const getAllVideos = async (req, res) => {
  try {
    const videos = await videoService.getAllVideos();
    res.json(videos);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

const getVideoById = async (req, res) => {
  try {
    const video = await videoService.getVideoById(req.params.id);
    if (!video) {
      return res.status(404).send('Video not found');
    }
    res.json(video);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

const uploadVideo = (req, res) => {
  videoService.uploadVideo(req, res);
};

const deleteVideo = async (req, res) => {
  try {
    const success = await videoService.deleteVideo(req.params.id);
    if (!success) {
      return res.status(404).send('Video not found');
    }
    res.send('Video deleted successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};

module.exports = { getAllVideos, getVideoById, uploadVideo, deleteVideo };
