const { getAllCategoriesService } = require('./categoryService');
const { getAllImagesService } = require('./imageService');

const getCategoryCount = async () => {
  try {
    const categories = await getAllCategoriesService();
    return categories.length;
  } catch (error) {
    console.error('Error getting category count:', error.message);
    throw error;
  }
};

const getImageCount = async () => {
  try {
    const images = await getAllImagesService();
    return images.length;
  } catch (error) {
    console.error('Error getting image count:', error.message);
    throw error;
  }
};

const getImagesByCategory = async (categoryId) => {
  try {
    const allImages = await getAllImagesService();
    return allImages.filter((image) => image.category === categoryId);
  } catch (error) {
    console.error('Error getting images by category:', error.message);
    throw error;
  }
};

module.exports = {
  getCategoryCount,
  getImageCount,
  getImagesByCategory,
};
