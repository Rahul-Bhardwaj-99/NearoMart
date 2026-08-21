import 'package:get/get.dart';
import '../../core/values/api_constants.dart';
import 'api_service.dart';

class ChatService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<dynamic> _cachedChats = <dynamic>[].obs;
  bool _hasLoadedChats = false;

  /// Get cached chats or fetch if not cached
  Future<List<dynamic>> getChats({bool force = false}) async {
    if (_hasLoadedChats && !force) {
      return _cachedChats;
    }

    try {
      final response = await _apiService.get(ApiConstants.chats);
      final chats = List<dynamic>.from(response.data as List);
      _cachedChats.assignAll(chats);
      _hasLoadedChats = true;
      return chats;
    } catch (e) {
      rethrow;
    }
  }

  /// Force refresh chats from API
  Future<List<dynamic>> refreshChats() => getChats(force: true);

  Future<Map<String, dynamic>> getChat(
    String chatId, {
    String? before,
    int? limit,
  }) async {
    final response = await _apiService.get(
      ApiConstants.chat(chatId),
      queryParameters: {
        ...?before == null ? null : {'before': before},
        ...?limit == null ? null : {'limit': limit},
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> markRead(String chatId) async {
    await _apiService.put(ApiConstants.chatRead(chatId), {});
    // Invalidate cache after read
    _hasLoadedChats = false;
  }

  Future<Map<String, dynamic>> endChat(String chatId) async {
    final response = await _apiService.post(ApiConstants.endChat(chatId), {});
    // Invalidate cache after end
    _hasLoadedChats = false;
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Clear cached chats
  void clear() {
    _cachedChats.clear();
    _hasLoadedChats = false;
  }
}
