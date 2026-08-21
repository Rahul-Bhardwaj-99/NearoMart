const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  messageId: { type: String, required: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  senderRole: { type: String, enum: ['BUYER', 'SHOPKEEPER'], required: true },
  messageType: {
    type: String,
    enum: ['TEXT', 'IMAGE', 'AUDIO', 'ORDER_SUMMARY_CARD', 'BARGAIN_REQUEST'],
    default: 'TEXT'
  },
  content: { type: String },
  mediaUrl: { type: String },
  metadata: { type: mongoose.Schema.Types.Mixed },
  readBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  timestamp: { type: Date, default: Date.now }
});

const chatSchema = new mongoose.Schema({
  shopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Shop', required: true },
  buyerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  status: { type: String, enum: ['ACTIVE', 'CLOSED'], default: 'ACTIVE', index: true },
  startedAt: { type: Date, default: Date.now },
  endedAt: { type: Date },
  endedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  messages: [messageSchema],
  lastMessage: { type: String },
  unreadCount: { type: Number, default: 0 },
  updatedAt: { type: Date, default: Date.now }
});

chatSchema.index(
  { shopId: 1, buyerId: 1 },
  { unique: true, partialFilterExpression: { status: 'ACTIVE' } }
);

module.exports = mongoose.model('Chat', chatSchema);
