const videoService = require('../services/formatService');

exports.uploadVideo = async (req, res) => {
    try {
        const videoFile = req.file;
        const result = await videoService.processAndSaveVideo(videoFile);
        res.json({ message: 'Video uploaded and processed successfully', result });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error processing video' });
    }
};

exports.getVideo = (req, res) => {
    const { id, format } = req.params;
    try {
        const videoPath = videoService.getVideoPath(id, format);
        if (videoPath) {
            res.sendFile(videoPath);
        } else {
            res.status(404).json({ message: 'Resolution not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(404).json({ message: 'Video not found' });
    }
};
