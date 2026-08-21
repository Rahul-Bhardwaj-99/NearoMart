/// Arguments for product-related navigation
class ProductArguments {
  final String productId;
  final Map<String, dynamic>? productData;

  ProductArguments({
    required this.productId,
    this.productData,
  });

  /// Create from product ID
  static ProductArguments fromId(String id) => ProductArguments(productId: id);

  /// Create from full product data
  static ProductArguments fromData(Map<String, dynamic> data) => ProductArguments(
    productId: data['_id'] as String? ?? data['id'] as String,
    productData: data,
  );

  /// Serialize to map
  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productData': productData,
  };

  /// Deserialize from arguments
  static ProductArguments? fromGetArguments(dynamic args) {
    if (args == null) return null;
    if (args is ProductArguments) return args;
    if (args is String) return ProductArguments.fromId(args);
    if (args is Map<String, dynamic>) {
      return ProductArguments(
        productId: args['productId'] as String? ?? args['_id'] as String? ?? args['id'] as String,
        productData: args,
      );
    }
    return null;
  }
}
