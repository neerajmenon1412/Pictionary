const { getImageCount, getImagesByCategory } = require('../services/imageService');
const { getAllImagesService, getImageByIdService, createImageService, updateImageService, deleteImageService } = require('../services/imageService');

const getAllImages = async () => {
  try {
    const images = await getAllImagesService();
    return images;
  } catch (error) {
    console.error('Error fetching images:', error.message);
    throw error;
  }
};

const getImageById = async (id) => {
  try {
    const image = await getImageByIdService(id);
    return image;
  } catch (error) {
    console.error('Error fetching image by ID:', error.message);
    throw error;
  }
};

const createImage = async (imageData) => {
  try {
    const newImage = await createImageService(imageData);
    return newImage;
  } catch (error) {
    console.error('Error creating image:', error.message);
    throw error;
  }
};

const updateImage = async (id, imageData) => {
  try {
    const updatedImage = await updateImageService(id, imageData);
    return updatedImage;
  } catch (error) {
    console.error('Error updating image:', error.message);
    throw error;
  }
};

const deleteImage = async (id) => {
  try {
    await deleteImageService(id);
  } catch (error) {
    console.error('Error deleting image:', error.message);
    throw error;
  }
};

module.exports = { getAllImages, getImageById, createImage, updateImage, deleteImage };
