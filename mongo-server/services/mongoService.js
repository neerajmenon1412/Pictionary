const { MongoClient } = require('mongodb');
const config = require('../config');

let client;

const connectToDatabase = async () => {
  try {
    if (!client) {
      client = new MongoClient(config.mongoURL, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
      await client.connect();
      console.log('Connected to MongoDB');
    }
    return client;
  } catch (error) {
    console.error('Error connecting to MongoDB:', error.message);
    throw error;
  }
};

const getCategoryCollection = async () => {
  try {
    const client = await connectToDatabase();
    const database = client.db(config.dbName);
    return database.collection('categories');
  } catch (error) {
    console.error('Error getting category collection:', error.message);
    throw error;
  }
};

const getImagesCollection = async () => {
  try {
    const client = await connectToDatabase();
    const database = client.db(config.dbName);
    return database.collection('images');
  } catch (error) {
    console.error('Error getting images collection:', error.message);
    throw error;
  }
};

const getVideosCollection = async () => {
  try {
    const client = await connectToDatabase();
    const database = client.db(config.dbName);
    return database.collection('videos');
  } catch (error) {
    console.error('Error getting videos collection:', error.message);
    throw error;
  }
};

module.exports = { connectToDatabase, getCategoryCollection, getImagesCollection, getVideosCollection };


