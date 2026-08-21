const Chat = require('../models/Chat');
const Shop = require('../models/Shop');
const User = require('../models/User');
const Order = require('../models/Order');
const jwt = require('jsonwebtoken');

const getToken = (socket) => {
  const authToken = socket.handshake.auth?.token;
  const queryToken = socket.handshake.query?.token;
  const header = socket.handshake.headers.authorization;
  return authToken || queryToken || header?.replace(/^Bearer\s+/i, '');
};

const canAccessChat = async (chatId, userId) => {
  const chat = await Chat.findById(chatId).select('buyerId shopId status');
  if (!chat) return null;

  if (chat.buyerId.toString() === userId) return chat;

  const shop = await Shop.findOne({ _id: chat.shopId, ownerId: userId }).select('_id');
  return shop ? chat : null;
};

const socketService = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = getToken(socket);
      if (!token) return next(new Error('Authentication required'));
      socket.user = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(socket.user.id).select('invalidatedAt');
      if (!user || (user.invalidatedAt && socket.user.iat * 1000 < user.invalidatedAt.getTime())) {
        return next(new Error('Session has expired'));
      }
      next();
    } catch (error) {
      next(new Error('Invalid socket token'));
    }
  });

  io.on('connection', (socket) => {

    socket.on('join_chat', async ({ chatId }) => {
      const chat = await canAccessChat(chatId, socket.user.id);
      if (!chat || chat.status !== 'ACTIVE') {
        socket.emit('message_error', { message: 'This chat session has ended' });
        return;
      }
      socket.join(chatId);
    });

    socket.on('join_shop', async ({ shopId }) => {
      const shop = await Shop.findOne({ _id: shopId, ownerId: socket.user.id }).select('_id');
      if (!shop) return;
      socket.join(shopId);
    });

    socket.on('join_public_shop', async ({ shopId }) => {
      const shop = await Shop.findById(shopId).select('_id');
      if (!shop) return;
      socket.join(`public_shop:${shopId}`);
    });

    socket.on('join_user', ({ userId }) => {
      if (userId !== socket.user.id) return;
      socket.join(userId);

      // If user is a rider, also join the riders room
      if (socket.user.role === 'RIDER') {
        socket.join('riders');
      }
    });

    socket.on('update_location', async ({ lat, lng }) => {
      if (socket.user.role !== 'RIDER') return;

      try {
        await User.findByIdAndUpdate(socket.user.id, {
          lastLocation: { type: 'Point', coordinates: [lng, lat] }
        });

        // Find active orders for this rider and notify buyer
        const activeOrder = await Order.findOne({
          riderId: socket.user.id,
          orderStatus: 'DISPATCHED'
        });

        if (activeOrder) {
          io.to(activeOrder.buyerId.toString()).emit('rider_location_changed', {
            orderId: activeOrder._id,
            lat,
            lng
          });
        }
      } catch (error) {
        console.error('Location update failed:', error);
      }
    });

    socket.on('send_message', async (data) => {
      const { chatId, messageType, content, mediaUrl, metadata } = data;

      if (!await canAccessChat(chatId, socket.user.id)) return;

      const senderRole = socket.user.role;
      if (!['BUYER', 'SHOPKEEPER'].includes(senderRole)) return;
      const allowedMessageTypes = ['TEXT', 'IMAGE', 'AUDIO', 'ORDER_SUMMARY_CARD', 'BARGAIN_REQUEST'];
      if (!allowedMessageTypes.includes(messageType)) return;
      if (messageType === 'BARGAIN_REQUEST' && (senderRole !== 'BUYER'
        || !Number.isFinite(Number(metadata?.offerAmount))
        || Number(metadata.offerAmount) <= 0)) return;

      const message = {
        messageId: Date.now().toString(),
        chatId,
        senderId: socket.user.id,
        senderRole,
        messageType,
        content,
        mediaUrl,
        metadata,
        timestamp: new Date()
      };

      try {
        await Chat.findByIdAndUpdate(chatId, {
          $push: { messages: message },
          $set: { lastMessage: content || messageType, updatedAt: new Date() }
        });

        io.to(chatId).emit('receive_message', message);
      } catch (error) {
        socket.emit('message_error', { message: 'Message could not be sent' });
      }
    });

    socket.on('bargain_action', async ({ chatId, messageId, action, counterAmount }) => {
      if (!['ACCEPTED', 'REJECTED', 'COUNTERED'].includes(action)) return;
      const accessibleChat = await canAccessChat(chatId, socket.user.id);
      if (!accessibleChat || accessibleChat.status !== 'ACTIVE') return;

      const chat = await Chat.findById(chatId).select('messages buyerId shopId');
      const message = chat?.messages.find((item) => item.messageId === messageId);
      if (!message || message.messageType !== 'BARGAIN_REQUEST') return;

      const shop = await Shop.findOne({ _id: chat.shopId, ownerId: socket.user.id }).select('_id');
      const isShopkeeper = Boolean(shop);
      const isBuyer = chat.buyerId.toString() === socket.user.id;
      if (!isShopkeeper && !isBuyer) return;
      if (isBuyer && action !== 'COUNTERED') return;
      if (action === 'COUNTERED' && (!Number.isFinite(Number(counterAmount)) || Number(counterAmount) <= 0)) return;

      const metadataUpdate = {
        ...message.metadata,
        status: action,
        ...(action === 'COUNTERED' ? { counterAmount: Number(counterAmount) } : {}),
        updatedBy: socket.user.id,
        updatedAt: new Date()
      };
      await Chat.updateOne(
        { _id: chatId, 'messages.messageId': messageId },
        { $set: { 'messages.$.metadata': metadataUpdate, updatedAt: new Date() } }
      );
      io.to(chatId).emit('bargain_updated', { chatId, messageId, metadata: metadataUpdate });
    });

    socket.on('mark_chat_read', async ({ chatId }) => {
      const chat = await canAccessChat(chatId, socket.user.id);
      if (!chat) return;

      await Chat.updateOne(
        { _id: chatId },
        { $addToSet: { 'messages.$[message].readBy': socket.user.id } },
        {
          arrayFilters: [{ 'message.senderId': { $ne: socket.user.id } }]
        }
      );
      io.to(chatId).emit('chat_read', { chatId, userId: socket.user.id });
    });

    const relayTyping = (event) => async ({ chatId }) => {
      const chat = await canAccessChat(chatId, socket.user.id);
      if (!chat || chat.status !== 'ACTIVE') return;
      socket.to(chatId).emit(event, { chatId, userId: socket.user.id });
    };

    socket.on('typing_started', relayTyping('typing_started'));
    socket.on('typing_stopped', relayTyping('typing_stopped'));

    socket.on('order_status_update', async ({ orderId, status }) => {
      const order = await Order.findById(orderId).select('buyerId riderId shopId orderStatus');
      if (!order) return;

      const shop = await Shop.findOne({ _id: order.shopId, ownerId: socket.user.id }).select('_id');
      const isAuthorized = order.riderId?.toString() === socket.user.id || Boolean(shop);
      if (!isAuthorized || order.orderStatus !== status) return;

      io.to(order.buyerId.toString()).emit('order_status_changed', {
        orderId: order._id,
        status: order.orderStatus
      });
    });

    socket.on('disconnect', () => {
    });
  });
};

module.exports = socketService;
