/// Arguments for shop-related navigation
class ShopArguments {
  final String shopId;
  final Map<String, dynamic>? shopData;

  ShopArguments({
    required this.shopId,
    this.shopData,
  });

  /// Create from shop ID
  static ShopArguments fromId(String id) => ShopArguments(shopId: id);

  /// Create from full shop data (accepts a Map or an object with toJson)
  static ShopArguments fromData(dynamic data) {
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : data.toJson() as Map<String, dynamic>);
    return ShopArguments(
      shopId: map['_id'] as String? ?? map['id'] as String,
      shopData: map,
    );
  }

  /// Serialize to map
  Map<String, dynamic> toMap() => {
    'shopId': shopId,
    'shopData': shopData,
  };

  /// Deserialize from arguments
  static ShopArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is ShopArguments) return args;
    if (args is String) return ShopArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return ShopArguments(
        shopId: args['shopId'] as String? ?? args['_id'] as String? ?? args['id'] as String,
        shopData: args,
      );
    }
    return null;
  }
}
