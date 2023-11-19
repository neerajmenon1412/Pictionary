const express = require('express');
const router = express.Router();
const {
  getCategoryCount,
  getImageCount,
  getImagesByCategory,
} = require('./../services/statService.js');

router.get('/categories/count', async (req, res) => {
  try {
    const count = await getCategoryCount();
    res.json({ count });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/images/count', async (req, res) => {
  try {
    const count = await getImageCount();
    res.json({ count });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/images/:categoryId', async (req, res) => {
  const categoryId = Number(req.params.categoryId);
  try {
    const images = await getImagesByCategory(categoryId);
    res.json(images);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
