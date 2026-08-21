/// Arguments for rider navigation and OTP flows
class RiderOrderArguments {
  final String orderId;
  final Map<String, dynamic>? orderData;

  RiderOrderArguments({
    required this.orderId,
    this.orderData,
  });

  /// Create from a string ID (when coming from list item)
  static RiderOrderArguments fromId(String id) => RiderOrderArguments(orderId: id);

  /// Create from full order data
  static RiderOrderArguments fromData(Map<String, dynamic> data) => RiderOrderArguments(
    orderId: data['_id'] as String,
    orderData: data,
  );

  /// Serialize to map for Get.toNamed
  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'orderData': orderData,
  };

  /// Deserialize from arguments passed to route
  static RiderOrderArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is RiderOrderArguments) return args;
    if (args is String) return RiderOrderArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return RiderOrderArguments(
        orderId: args['orderId'] as String? ?? args['_id'] as String,
        orderData: args,
      );
    }
    return null;
  }
}