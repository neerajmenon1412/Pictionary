const { getCategoryCollection } = require('./mongoService');

const getAllCategoriesService = async () => {
  try {
    const categoriesCollection = await getCategoryCollection();
    return categoriesCollection.find({}).toArray();
  } catch (error) {
    console.error('Error getting all categories:', error.message);
    throw error;
  }
};

const getCategoryByIdService = async (categoryId) => {
  try {
    const categoriesCollection = await getCategoryCollection();
    return categoriesCollection.findOne({ id: categoryId });
  } catch (error) {
    console.error('Error getting category by ID:', error.message);
    throw error;
  }
};

const createCategoryService = async (category) => {
  try {
    const categoriesCollection = await getCategoryCollection();
    const result = await categoriesCollection.insertOne(category);
    console.log(result);
    return result;
  } catch (error) {
    console.error('Error creating category:', error.message);
    throw error;
  }
};

const updateCategoryService = async (categoryId, updatedCategory) => {
  try {
    const categoriesCollection = await getCategoryCollection();
    console.log(updatedCategory);
    const result = await categoriesCollection.updateOne({ id: categoryId }, { $set: updatedCategory });
    return result;
  } catch (error) {
    console.error('Error updating category:', error.message);
    throw error;
  }
};

const deleteCategoryService = async (categoryId) => {
  try {
    const categoriesCollection = await getCategoryCollection();
    const result = await categoriesCollection.deleteOne({ id: categoryId });
    return result.deletedCount > 0;
  } catch (error) {
    console.error('Error deleting category:', error.message);
    throw error;
  }
};

module.exports = {
  getAllCategoriesService,
  getCategoryByIdService,
  createCategoryService,
  updateCategoryService,
  deleteCategoryService,
};
