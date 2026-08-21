const Chat = require('../models/Chat');
const Shop = require('../models/Shop');

const chatAccessFilter = async (userId) => {
  const ownedShops = await Shop.find({ ownerId: userId }).select('_id');
  return {
    $or: [
      { buyerId: userId },
      { shopId: { $in: ownedShops.map((shop) => shop._id) } }
    ]
  };
};

exports.getChatList = async (req, res) => {
  try {
    const userId = req.user.id;
    const isBuyer = req.user.role === 'BUYER';
    const listFilter = await chatAccessFilter(userId);
    if (isBuyer) listFilter.status = 'ACTIVE';
    const chats = await Chat.find(listFilter)
    .populate('shopId', 'shopName bannerUrl')
    .populate('buyerId', 'name')
    .sort({ updatedAt: -1 });

    const chatList = chats.map((chat) => {
      const unreadCount = chat.messages.filter((message) =>
        message.senderId.toString() !== userId
        && !message.readBy.some((readerId) => readerId.toString() === userId)
      ).length;
      const data = chat.toObject();
      data.unreadCount = unreadCount;
      delete data.messages;
      return data;
    });

    res.status(200).json(chatList);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getChatHistory = async (req, res) => {
  try {
    const { chatId } = req.params;
    const limit = Math.min(Math.max(Number.parseInt(req.query.limit, 10) || 50, 1), 100);
    const before = req.query.before ? new Date(req.query.before) : null;
    const accessFilter = await chatAccessFilter(req.user.id);
    const chat = await Chat.findOne({ _id: chatId, ...accessFilter })
      .populate('shopId', 'shopName bannerUrl isOpen')
      .populate('buyerId', 'name');

    if (!chat) return res.status(404).json({ message: 'Chat not found' });

    const allMessages = chat.messages
      .filter((message) => !before || message.timestamp < before)
      .sort((first, second) => first.timestamp - second.timestamp);
    const messages = allMessages.slice(Math.max(0, allMessages.length - limit));
    const data = chat.toObject();
    data.messages = messages;
    data.pagination = {
      hasMore: allMessages.length > messages.length,
      nextBefore: messages.length > 0 ? messages[0].timestamp : null
    };
    res.status(200).json(data);
  } catch (error) {
    if (error.code === 11000) {
      const activeChat = await Chat.findOne({ shopId: req.body.shopId, buyerId: req.user.id, status: 'ACTIVE' });
      if (activeChat) return res.status(200).json(activeChat);
      return res.status(409).json({ message: 'An active chat already exists' });
    }
    res.status(500).json({ message: error.message });
  }
};

exports.markChatRead = async (req, res) => {
  try {
    const accessFilter = await chatAccessFilter(req.user.id);
    const chat = await Chat.findOne({ _id: req.params.chatId, ...accessFilter });
    if (!chat) return res.status(404).json({ message: 'Chat not found' });

    for (const message of chat.messages) {
      if (message.senderId.toString() !== req.user.id
        && !message.readBy.some((readerId) => readerId.toString() === req.user.id)) {
        message.readBy.push(req.user.id);
      }
    }
    await chat.save();
    res.status(200).json({ message: 'Chat marked as read' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createChat = async (req, res) => {
  try {
    const { shopId } = req.body;
    const buyerId = req.user.id;
    const shop = await Shop.findById(shopId).select('ownerId');

    if (!shop) return res.status(404).json({ message: 'Shop not found' });
    if (shop.ownerId.toString() === buyerId) {
      return res.status(400).json({ message: 'Shop owners cannot create buyer chats with their own shop' });
    }

    let chat = await Chat.findOne({ shopId, buyerId, status: 'ACTIVE' });

    if (!chat) {
      chat = new Chat({ shopId, buyerId, messages: [] });
      await chat.save();
    }

    res.status(201).json(chat);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.endChat = async (req, res) => {
  try {
    const chat = await Chat.findOne({
      _id: req.params.chatId,
      buyerId: req.user.id,
      status: 'ACTIVE'
    });

    if (!chat) return res.status(404).json({ message: 'Active chat not found' });

    chat.status = 'CLOSED';
    chat.endedAt = new Date();
    chat.endedBy = req.user.id;
    chat.updatedAt = chat.endedAt;
    await chat.save();

    const shop = await Shop.findById(chat.shopId).select('ownerId');
    const event = { chatId: chat._id, status: chat.status, endedAt: chat.endedAt, endedBy: chat.endedBy };
    const io = req.app.get('socketio');
    io?.to(chat._id.toString()).emit('chat_session_ended', event);
    io?.to(chat.buyerId.toString()).emit('chat_session_ended', event);
    if (shop) io?.to(shop.ownerId.toString()).emit('chat_session_ended', event);

    res.status(200).json(chat);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
