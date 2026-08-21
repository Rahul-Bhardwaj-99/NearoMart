import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/socket_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/socket_events.dart';
import '../../../routes/arguments/arguments.dart';

class ChatController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  final ChatService _chatService = Get.find<ChatService>();

  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxString chatId = ''.obs;
  final RxMap chatData = {}.obs;
  final RxBool isEnded = false.obs;
  final RxBool isEnding = false.obs;
  final RxBool hasOlderMessages = false.obs;
  final RxBool isLoadingOlder = false.obs;
  final isOtherUserTyping = false.obs;

  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from ChatArguments
    final args = ChatArguments.fromGetArguments(Get.arguments);
    if (args != null) {
      chatId.value = args.chatId;
      if (args.chatData != null) {
        chatData.value = args.chatData!;
        isEnded.value = args.chatData!['status'] == 'CLOSED';
      }
      _socketService.joinChat(chatId.value);
      fetchChatHistory();
    }

    _socketService.socket?.on(SocketEvents.receiveMessage, _handleReceiveMessage);
    _socketService.socket?.on(SocketEvents.typingStarted, _handleTypingStarted);
    _socketService.socket?.on(SocketEvents.typingStopped, _handleTypingStopped);
    _socketService.socket?.on(SocketEvents.bargainUpdated, _handleBargainUpdated);
    _socketService.socket?.on(SocketEvents.chatSessionEnded, _handleChatSessionEnded);
  }

  void _handleReceiveMessage(dynamic data) {
    if (data is Map && data['chatId']?.toString() == chatId.value) {
      messages.add(data);
    }
  }

  void _handleTypingStarted(dynamic data) {
    if (data is Map && data['chatId']?.toString() == chatId.value) {
      isOtherUserTyping.value = true;
    }
  }

  void _handleTypingStopped(dynamic data) {
    if (data is Map && data['chatId']?.toString() == chatId.value) {
      isOtherUserTyping.value = false;
    }
  }

  void _handleBargainUpdated(dynamic data) {
    if (data is! Map || data['chatId']?.toString() != chatId.value) return;
    final messageId = data['messageId']?.toString();
    final index = messages.indexWhere((message) =>
        message['messageId']?.toString() == messageId
        || message['_id']?.toString() == messageId);
    if (index == -1) return;
    messages[index] = {
      ...Map<String, dynamic>.from(messages[index]),
      'metadata': data['metadata'],
    };
    messages.refresh();
  }

  void _handleChatSessionEnded(dynamic data) {
    if (data is Map && data['chatId']?.toString() == chatId.value) {
      isEnded.value = true;
      chatData['status'] = 'CLOSED';
      chatData['endedAt'] = data['endedAt'];
      chatData['endedBy'] = data['endedBy'];
      chatData.refresh();
    }
  }

  Future<void> fetchChatHistory() async {
    try {
      isLoading.value = true;
      final chat = await _chatService.getChat(chatId.value);
      chatData.value = chat;
      isEnded.value = chat['status'] == 'CLOSED';
      messages.assignAll(chat['messages']);
      hasOlderMessages.value = chat['pagination']?['hasMore'] == true;
        if (!isEnded.value) markChatRead();
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingOlder.value || !hasOlderMessages.value || messages.isEmpty) return;
    try {
      isLoadingOlder.value = true;
      final oldest = messages.first['timestamp']?.toString();
      if (oldest == null) return;
      final chat = await _chatService.getChat(chatId.value, before: oldest, limit: 50);
        final older = List<dynamic>.from(chat['messages'] ?? const []);
        messages.insertAll(0, older);
        hasOlderMessages.value = chat['pagination']?['hasMore'] == true;
    } catch (e) {
      debugPrint('Failed to load older messages: $e');
    } finally {
      isLoadingOlder.value = false;
    }
  }

  void sendMessage() {
    if (isEnded.value || messageController.text.trim().isEmpty) return;

    final messageData = {
      'chatId': chatId.value,
      'messageType': 'TEXT',
      'content': messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socketService.sendMessage(messageData);
    messageController.clear();
  }

  void sendBargain(double offerAmount, {double? originalAmount}) {
    if (isEnded.value || offerAmount <= 0 || chatId.value.isEmpty) return;
    _socketService.sendMessage({
      'chatId': chatId.value,
      'messageType': 'BARGAIN_REQUEST',
      'content': 'Offer: ₹${offerAmount.toStringAsFixed(2)}',
      'metadata': {
        'offerAmount': offerAmount,
        ...?originalAmount == null ? null : {'originalAmount': originalAmount},
        'status': 'PENDING',
      },
    });
  }

  void updateBargain(String messageId, String action, {double? counterAmount}) {
    if (isEnded.value) return;
    _socketService.emit('bargain_action', {
      'chatId': chatId.value,
      'messageId': messageId,
      'action': action,
      ...?counterAmount == null ? null : {'counterAmount': counterAmount},
    });
  }

  void setTyping(bool isTyping) {
    if (isEnded.value || chatId.value.isEmpty) return;
    _socketService.emit(isTyping ? 'typing_started' : 'typing_stopped', {
      'chatId': chatId.value,
    });
  }

  Future<void> markChatRead() async {
    if (chatId.value.isEmpty) return;
    try {
      await _chatService.markRead(chatId.value);
    } catch (e) {
      debugPrint('Failed to mark chat as read: $e');
    }
  }

  Future<void> endChat() async {
    if (isEnded.value || isEnding.value || chatId.value.isEmpty) return;
    try {
      isEnding.value = true;
      chatData.value = await _chatService.endChat(chatId.value);
      isEnded.value = true;
    } catch (e) {
      Get.snackbar('Chat', AppStrings.chatEndFailed);
      debugPrint('Failed to end chat: $e');
    } finally {
      isEnding.value = false;
    }
  }

  @override
  void onClose() {
    _socketService.socket?.off(SocketEvents.receiveMessage, _handleReceiveMessage);
    _socketService.socket?.off(SocketEvents.typingStarted, _handleTypingStarted);
    _socketService.socket?.off(SocketEvents.typingStopped, _handleTypingStopped);
    _socketService.socket?.off(SocketEvents.bargainUpdated, _handleBargainUpdated);
    _socketService.socket?.off(SocketEvents.chatSessionEnded, _handleChatSessionEnded);
    messageController.dispose();
    super.onClose();
  }
}
