const express = require('express');
const router = express.Router();
const {
  getAllImages,
  getImageById,
  createImage,
  updateImage,
  deleteImage,
} = require('../controllers/imageController');

// Images CRUD routes
router.get('/', async (req, res) => {
  try {
    const images = await getAllImages();
    res.json(images);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.get('/:id', async (req, res) => {
  try {
    const image = await getImageById(Number(req.params.id));
    res.json(image);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.post('/', async (req, res) => {
  try {
    const newImage = await createImage(req.body);
    res.json(newImage);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.put('/:id', async (req, res) => {
  try {
    const updatedImage = await updateImage(Number(req.params.id), req.body);
    res.json(updatedImage);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await deleteImage(Number(req.params.id));
    res.send('Image deleted successfully');
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

module.exports = router;
