const mongoose = require('mongoose');
const multer = require('multer');
const GridFsStorage = require('multer-gridfs-storage').GridFsStorage;
const Grid = require('gridfs-stream');
const config = require('../config'); // Your MongoDB config

// Create mongoose connection
const conn = mongoose.createConnection(config.mongoURL, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Init gfs
let gfs;
conn.once('open', () => {
  gfs = Grid(conn.db, mongoose.mongo);
  gfs.collection('videos'); // Collection name for videos
});

// Create storage engine
const storage = new GridFsStorage({
  url: config.mongoURL,
  options: { useNewUrlParser: true, useUnifiedTopology: true },
  file: (req, file) => {
    return {
      bucketName: 'videos', // Setting collection name, same as gfs.collection name
      filename: `video_${Date.now()}_${file.originalname}`, // File name to store
    };
  },
});

const upload = multer({ storage });

const uploadVideo = (req, res) => {
  upload.single('video')(req, res, (err) => {
    if (err) {
      return res.status(500).json(err);
    }
    return res.status(201).json({ file: req.file });
  });
};

const getVideoById = (req, res) => {
  const { id } = req.params;
  console.log(`Attempting to retrieve video with ID: ${id}`);

  const bucket = new mongoose.mongo.GridFSBucket(conn.db, {
    bucketName: 'videos'
  });

  let downloadStream = bucket.openDownloadStream(new mongoose.Types.ObjectId(id));

  downloadStream.on('data', (chunk) => {
    console.log(`Received ${chunk.length} bytes of data.`);
  });

  downloadStream.on('error', function (error) {
    console.error('Error streaming file:', error);
    return res.status(404).json({ err: 'Error retrieving file' });
  });

  downloadStream.on('end', () => {
    console.log('Stream ended');
  });

  // Set the proper content type
  res.set('Content-Type', 'video/mp4');
  downloadStream.pipe(res);
};



const deleteVideo = (req, res) => {
  const { id } = req.params;

  gfs.remove({ _id: mongoose.Types.ObjectId(id), root: 'videos' }, (err, gridStore) => {
    if (err) {
      return res.status(404).json({ err: 'No file exists' });
    }

    res.status(200).json({ success: true });
  });
};

module.exports = { uploadVideo, getVideoById, deleteVideo };
