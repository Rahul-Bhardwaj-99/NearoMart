class ProductModel {
  String? id;
  String? shopId;
  String? name;
  String? description;
  String? category;
  double? price;
  double? discountPrice;
  String? unit;
  int? stockQuantity;
  int? lowStockThreshold;
  bool? isAvailable;
  String? imageUrl;
  List<String>? tags;

  ProductModel({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.category,
    this.price,
    this.discountPrice,
    this.unit,
    this.stockQuantity,
    this.lowStockThreshold,
    this.isAvailable,
    this.imageUrl,
    this.tags,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    shopId = json['shopId'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
    price = json['price']?.toDouble();
    discountPrice = json['discountPrice']?.toDouble();
    unit = json['unit'];
    stockQuantity = json['stockQuantity'];
    lowStockThreshold = json['lowStockThreshold'];
    isAvailable = json['isAvailable'];
    imageUrl = json['imageUrl'];
    tags = json['tags']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['shopId'] = shopId;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    data['price'] = price;
    data['discountPrice'] = discountPrice;
    data['unit'] = unit;
    data['stockQuantity'] = stockQuantity;
    data['lowStockThreshold'] = lowStockThreshold;
    data['isAvailable'] = isAvailable;
    data['imageUrl'] = imageUrl;
    data['tags'] = tags;
    return data;
  }
}
