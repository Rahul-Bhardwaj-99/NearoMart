class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? shopName;

  BannerModel({required this.id, required this.title, required this.imageUrl, this.shopName});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      shopName: json['shopId'] is Map ? json['shopId']['shopName'] : null,
    );
  }
}
