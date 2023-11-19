const { getImagesCollection } = require('./mongoService');

const getAllImagesService = async () => {
  try {
    const imagesCollection = await getImagesCollection();
    return imagesCollection.find({}).toArray();
  } catch (error) {
    console.error('Error getting all images:', error.message);
    throw error;
  }
};

const getImageByIdService = async (imageId) => {
  try {
    const imagesCollection = await getImagesCollection();
    return imagesCollection.findOne({ id: imageId });
  } catch (error) {
    console.error('Error getting image by ID:', error.message);
    throw error;
  }
};

const createImageService = async (image) => {
  try {
    const imagesCollection = await getImagesCollection();
    const result = await imagesCollection.insertOne(image);
    return result;
  } catch (error) {
    console.error('Error creating image:', error.message);
    throw error;
  }
};

const updateImageService = async (imageId, updatedImage) => {
  try {
    const imagesCollection = await getImagesCollection();
    const result = await imagesCollection.updateOne({ id: imageId }, { $set: updatedImage });
    return result.modifiedCount > 0;
  } catch (error) {
    console.error('Error updating image:', error.message);
    throw error;
  }
};

const deleteImageService = async (imageId) => {
  try {
    const imagesCollection = await getImagesCollection();
    const result = await imagesCollection.deleteOne({ id: imageId });
    return result.deletedCount > 0;
  } catch (error) {
    console.error('Error deleting image:', error.message);
    throw error;
  }
};

module.exports = {
  getAllImagesService,
  getImageByIdService,
  createImageService,
  updateImageService,
  deleteImageService,
};
