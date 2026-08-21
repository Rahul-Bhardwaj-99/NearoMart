/// Arguments for chat-related navigation
class ChatArguments {
  final String chatId;
  final String? profileId;
  final String? orderId;
  final Map<String, dynamic>? chatData;

  ChatArguments({
    required this.chatId,
    this.profileId,
    this.orderId,
    this.chatData,
  });

  /// Create with minimal info
  static ChatArguments fromId(String id) => ChatArguments(chatId: id);

  /// Create with chat thread data
  static ChatArguments fromData(Map<String, dynamic> data) => ChatArguments(
    chatId: data['_id'] as String,
    profileId: data['profileId'] as String?,
    orderId: data['orderId'] as String?,
    chatData: data,
  );

  /// Serialize to map
  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'profileId': profileId,
    'orderId': orderId,
    'chatData': chatData,
  };

  /// Deserialize from arguments
  static ChatArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is ChatArguments) return args;
    if (args is String) return ChatArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return ChatArguments(
        chatId: args['chatId'] as String? ?? args['_id'] as String,
        profileId: args['profileId'] as String?,
        orderId: args['orderId'] as String?,
        chatData: args,
      );
    }
    return null;
  }
}
