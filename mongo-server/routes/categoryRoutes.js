const express = require('express');
const router = express.Router();
const {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
} = require('../controllers/categoryController');

// Categories CRUD routes
router.get('/', async (req, res) => {
  try {
    const categories = await getAllCategories();
    res.json(categories);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.get('/:id', async (req, res) => {
  try {
    const category = await getCategoryById(Number(req.params.id));
    res.json(category);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.post('/', async (req, res) => {
  try {
    const newCategory = await createCategory(req.body);
    res.json(newCategory);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.put('/:id', async (req, res) => {
  try {
    const updatedCategory = await updateCategory(Number(req.params.id), req.body);
    res.json(updatedCategory);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await deleteCategory(Number(req.params.id));
    res.send('Category deleted successfully');
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
});

module.exports = router;
