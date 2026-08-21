class ShopModel {
  String? id;
  String? ownerId;
  String? shopName;
  List<String>? category;
  bool? deliveryEnabled;
  double? deliveryRadiusKm;
  double? minOrderValue;
  String? kycStatus;
  String? gstin;
  String? fssaiLicense;
  Location? location;
  String? addressText;
  double? rating;
  int? reviewCount;
  String? bannerUrl;
  String? qrCodeUrl;
  bool? isOpen;

  ShopModel({
    this.id,
    this.ownerId,
    this.shopName,
    this.category,
    this.deliveryEnabled,
    this.deliveryRadiusKm,
    this.minOrderValue,
    this.kycStatus,
    this.gstin,
    this.fssaiLicense,
    this.location,
    this.addressText,
    this.rating,
    this.reviewCount,
    this.bannerUrl,
    this.qrCodeUrl,
    this.isOpen,
  });

  ShopModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    ownerId = json['ownerId'];
    shopName = json['shopName'];
    category = json['category']?.cast<String>();
    deliveryEnabled = json['deliveryEnabled'];
    deliveryRadiusKm = json['deliveryRadiusKm']?.toDouble();
    minOrderValue = json['minOrderValue']?.toDouble();
    kycStatus = json['kycStatus'];
    gstin = json['gstin'];
    fssaiLicense = json['fssaiLicense'];
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    addressText = json['addressText'];
    rating = json['rating']?.toDouble();
    reviewCount = json['reviewCount'];
    bannerUrl = json['bannerUrl'];
    qrCodeUrl = json['qrCodeUrl'];
    isOpen = json['isOpen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['ownerId'] = ownerId;
    data['shopName'] = shopName;
    data['category'] = category;
    data['deliveryEnabled'] = deliveryEnabled;
    data['deliveryRadiusKm'] = deliveryRadiusKm;
    data['minOrderValue'] = minOrderValue;
    data['kycStatus'] = kycStatus;
    data['gstin'] = gstin;
    data['fssaiLicense'] = fssaiLicense;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['addressText'] = addressText;
    data['rating'] = rating;
    data['reviewCount'] = reviewCount;
    data['bannerUrl'] = bannerUrl;
    data['qrCodeUrl'] = qrCodeUrl;
    data['isOpen'] = isOpen;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates']?.cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}
