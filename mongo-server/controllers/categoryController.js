const { getCategoryCount } = require('../services/statService');
const { getAllCategoriesService, getCategoryByIdService, createCategoryService, updateCategoryService, deleteCategoryService } = require('../services/categoryService');

const getAllCategories = async () => {
  try {
    const categories = await getAllCategoriesService();
    return categories;
  } catch (error) {
    console.error('Error fetching categories:', error.message);
    throw error;
  }
};

const getCategoryById = async (id) => {
  try {
    const category = await getCategoryByIdService(id);
    return category;
  } catch (error) {
    console.error('Error fetching category by ID:', error.message);
    throw error;
  }
};

const createCategory = async (categoryData) => {
  try {
    const newCategory = await createCategoryService(categoryData);
    return newCategory;
  } catch (error) {
    console.error('Error creating category:', error.message);
    throw error;
  }
};

const updateCategory = async (id, categoryData) => {
  try {
    console.log(id, categoryData, typeof(id));
    const updatedCategory = await updateCategoryService(id, categoryData);
    return updatedCategory;
  } catch (error) {
    console.error('Error updating category:', error.message);
    throw error;
  }
};

const deleteCategory = async (id) => {
  try {
    await deleteCategoryService(id);
  } catch (error) {
    console.error('Error deleting category:', error.message);
    throw error;
  }
};

module.exports = { getAllCategories, getCategoryById, createCategory, updateCategory, deleteCategory };
