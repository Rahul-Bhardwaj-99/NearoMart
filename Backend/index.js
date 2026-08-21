const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const http = require('http');
const { Server } = require('socket.io');
const dns = require('dns');

dns.setServers(['8.8.8.8', '8.8.4.4']);

const socketService = require('./src/services/socketService');
require('./src/config/firebase-config');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  }
});

app.set('socketio', io);
socketService(io);

const authRoutes = require('./src/routes/authRoutes');
const shopRoutes = require('./src/routes/shopRoutes');
const productRoutes = require('./src/routes/productRoutes');
const uploadRoutes = require('./src/routes/uploadRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const bannerRoutes = require('./src/routes/bannerRoutes');
const categoryRoutes = require('./src/routes/categoryRoutes');
const chatRoutes = require('./src/routes/chatRoutes');
const specialRoutes = require('./src/routes/specialRoutes');

app.use(cors());
app.use(express.json({ limit: '12mb' }));

app.use('/api/auth', authRoutes);
app.use('/api/shops', shopRoutes);
app.use('/api/products', productRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/chats', chatRoutes);
app.use('/api/specials', specialRoutes);

const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI;

mongoose.connect(MONGODB_URI, {
  serverSelectionTimeoutMS: 5000
})
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch(err => {
    console.error('Could not connect to MongoDB:', err);
  });

io.on('connection', (socket) => {
  socket.on('disconnect', () => {
  });
});

app.get('/', (req, res) => {
  res.send('NearoMart Backend is running');
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
