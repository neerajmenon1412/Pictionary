const express = require('express');
const cors = require('cors');
const app = express();
const categoryRouter = require('./routes/categoryRoutes.js');
const imageRouter = require('./routes/imageRoutes.js');
const statRouter = require('./routes/statRoutes.js');

const config = require('./config');
const { connectToDatabase } = require('./services/mongoService');

// Middleware
app.use(cors());
app.use(express.json());

// Database and collections creation if not exists
const initDatabase = async () => {
  try {
    const client = await connectToDatabase();
    const adminDb = client.db().admin(); // Get the admin database

    const databaseList = await adminDb.listDatabases();

    // Check if the database exists
    const isDatabaseExist = databaseList.databases.some((db) => db.name === config.dbName);

    if (!isDatabaseExist) {
      console.log(`Database "${config.dbName}" not found. Creating...`);
      await client.db(config.dbName).createCollection('categories');
      await client.db(config.dbName).createCollection('images');
    }
  } catch (error) {
    console.error('Error initializing database:', error.message);
    throw error;
  }
};


// Initialize the database
initDatabase();

// Routes
app.use('/categories', categoryRouter);
app.use('/images', imageRouter);
app.use('/stats', statRouter);

// Other configurations and error handling
const PORT = process.env.PORT || 3010;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
