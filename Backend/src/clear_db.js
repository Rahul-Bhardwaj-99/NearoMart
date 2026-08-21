const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

const Shop = require('./models/Shop');
const Product = require('./models/Product');
const User = require('./models/User');
const Category = require('./models/Category');
const Special = require('./models/Special');

dotenv.config({ path: path.join(__dirname, '../.env') });

const MONGODB_URI = process.env.MONGODB_URI;

const clearData = async () => {
  try {
    if (!MONGODB_URI) {
      throw new Error('MONGODB_URI is not defined in .env');
    }

    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data
    await Category.deleteMany({});
    await Shop.deleteMany({});
    await Product.deleteMany({});
    await Special.deleteMany({});

    console.log('Successfully cleared: Categories, Shops, Products, Specials');
    process.exit(0);
  } catch (error) {
    console.error('Clear failed:', error);
    process.exit(1);
  }
};

clearData();
