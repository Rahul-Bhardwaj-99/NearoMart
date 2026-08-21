class ReviewModel {
  final String? id;
  final int rating;
  final String? comment;
  final String? buyerName;
  final String? createdAt;

  ReviewModel({this.id, required this.rating, this.comment, this.buyerName, this.createdAt});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyerId'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['_id']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      buyerName: buyer?['name'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}