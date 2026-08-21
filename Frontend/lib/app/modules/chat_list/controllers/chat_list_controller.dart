import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/values/socket_events.dart';

class ChatListController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  final SocketService _socketService = Get.find<SocketService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxList chats = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _socketService.socket?.on(SocketEvents.chatSessionEnded, _handleChatSessionEnded);
    fetchChats();
  }

  void _handleChatSessionEnded(dynamic data) {
    if (data is! Map) return;
    final chatId = data['chatId']?.toString();
    final index = chats.indexWhere((chat) => chat['_id']?.toString() == chatId);
    if (index == -1) return;

    if (_storageService.getRole() == 'BUYER') {
      chats.removeAt(index);
      return;
    }

    chats[index] = {
      ...Map<String, dynamic>.from(chats[index]),
      'status': 'CLOSED',
      'endedAt': data['endedAt'],
      'endedBy': data['endedBy'],
      'updatedAt': data['endedAt'],
    };
    chats.refresh();
  }

  Future<void> fetchChats({bool force = false}) async {
    try {
      isLoading.value = true;
      final fetchedChats = await _chatService.getChats(force: force);
      chats.assignAll(fetchedChats);
    } catch (e) {
      debugPrint('Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh chats by clearing cache and fetching fresh data
  Future<void> refreshChats() => fetchChats(force: true);

  @override
  void onClose() {
    _socketService.socket?.off(SocketEvents.chatSessionEnded, _handleChatSessionEnded);
    super.onClose();
  }
}
