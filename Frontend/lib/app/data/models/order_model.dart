class OrderModel {
  final String id;
  final String orderNumber;
  final dynamic shopId; // Can be ID or Map
  final dynamic buyerId; // Can be ID or Map
  final List<OrderItemModel> items;
  final double grandTotal;
  final String orderStatus;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.shopId,
    this.buyerId,
    required this.items,
    required this.grandTotal,
    required this.orderStatus,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      shopId: json['shopId'],
      buyerId: json['buyerId'],
      items: (json['items'] as List?)
              ?.map((i) => OrderItemModel.fromJson(i))
              .toList() ??
          [],
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      orderStatus: json['orderStatus'] ?? 'PLACED',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
