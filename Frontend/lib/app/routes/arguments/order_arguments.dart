/// Arguments for order-related navigation
class OrderArguments {
  final String orderId;
  final Map<String, dynamic>? orderData;

  OrderArguments({
    required this.orderId,
    this.orderData,
  });

  /// Create from a string ID (when coming from list item)
  static OrderArguments fromId(String id) => OrderArguments(orderId: id);

  /// Create from full order data
  static OrderArguments fromData(Map<String, dynamic> data) => OrderArguments(
    orderId: data['_id'] as String,
    orderData: data,
  );

  /// Serialize to map for Get.toNamed
  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'orderData': orderData,
  };

  /// Deserialize from arguments passed to route
  static OrderArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is OrderArguments) return args;
    if (args is String) return OrderArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return OrderArguments(
        orderId: args['orderId'] as String? ?? args['_id'] as String,
        orderData: args,
      );
    }
    return null;
  }
}
