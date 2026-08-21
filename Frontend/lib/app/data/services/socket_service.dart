import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/values/api_constants.dart';
import '../../core/values/socket_events.dart';
import 'storage_service.dart';

class SocketService extends GetxService {
  io.Socket? socket;
  final StorageService _storageService = Get.find<StorageService>();
  String? _userId;
  final Set<String> _chatRooms = <String>{};
  String? _shopRoom;
  bool _isConnecting = false;
  bool _isClosing = false;

  Future<SocketService> init() async {
    _connect();
    return this;
  }

  void _connect() {
    if (_isConnecting || (socket?.connected ?? false)) return;

    final token = _storageService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('Socket: No token found, skipping connection');
      return;
    }
    
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    debugPrint('Socket: Connecting to $baseUrl');
    _isConnecting = true;
    _isClosing = false;

    final nextSocket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'reconnection': true,
      'reconnectionAttempts': double.infinity,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 10000,
      'timeout': 10000,
      'extraHeaders': {
        'Authorization': 'Bearer $token'
      },
      'query': {
        'token': token
      }
    });
    socket = nextSocket;

    nextSocket.onConnect((_) {
      _isConnecting = false;
      debugPrint('Socket connected');
      if (_userId != null) nextSocket.emit(SocketEvents.joinUser, {'userId': _userId});
      if (_shopRoom != null) nextSocket.emit(SocketEvents.joinShop, {'shopId': _shopRoom});
      for (final chatId in _chatRooms) {
        nextSocket.emit(SocketEvents.joinChat, {'chatId': chatId});
      }
    });

    nextSocket.onDisconnect((_) {
      _isConnecting = false;
      if (_isClosing) return;
      debugPrint('Socket disconnected');
    });

    nextSocket.onConnectError((err) {
      _isConnecting = false;
      debugPrint('Socket Connect Error: $err');
    });

    nextSocket.onError((err) {
      debugPrint('Socket Error: $err');
    });

    nextSocket.connect();
  }

  void reconnect() {
    if (socket?.connected ?? false) {
      debugPrint('Socket: Already connected');
      return;
    }
    debugPrint('Socket: Reconnecting...');
    _connect();
  }

  void authenticateUser(String userId) {
    _userId = userId;
    if (socket != null && socket!.connected) {
      socket?.emit(SocketEvents.joinUser, {'userId': userId});
    }
  }

  void disconnect() {
    debugPrint('Socket: Disconnecting and clearing state');
    _isClosing = true;
    _isConnecting = false;
    _userId = null;
    _shopRoom = null;
    _chatRooms.clear();
    try {
      socket?.dispose();
      socket = null;
    } catch (e) {
      debugPrint('Socket: Disconnect error: $e');
    }
  }

  void joinChat(String chatId) {
    _chatRooms.add(chatId);
    if (socket != null && socket!.connected) {
      socket?.emit(SocketEvents.joinChat, {'chatId': chatId});
    }
  }

  void joinShop(String shopId) {
    _shopRoom = shopId;
    if (socket != null && socket!.connected) {
      socket?.emit(SocketEvents.joinShop, {'shopId': shopId});
    }
  }

  void joinPublicShop(String shopId) {
    if (socket != null && socket!.connected) {
      socket?.emit(SocketEvents.joinPublicShop, {'shopId': shopId});
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (socket != null && socket!.connected) {
      socket?.emit(SocketEvents.sendMessage, data);
    } else {
      debugPrint('Socket: Cannot send message, socket not connected');
    }
  }

  void on(String event, Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  void emit(String event, dynamic data) {
    socket?.emit(event, data);
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }
}
