import '../services/api_service.dart';
import '../../core/values/api_constants.dart';
import 'package:get/get.dart';

class AddressModel {
  final String? id;
  final String label;
  final String addressText;
  final String? fullName;
  final String? phoneNumber;
  final String? flatDetail;
  final List<double> coordinates;
  final bool isDefault;

  AddressModel({
    this.id, 
    required this.label, 
    required this.addressText, 
    this.fullName,
    this.phoneNumber,
    this.flatDetail,
    required this.coordinates,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      label: json['label'],
      addressText: json['addressText'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      flatDetail: json['flatDetail'],
      coordinates: List<double>.from(json['location']['coordinates']),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'addressText': addressText,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'flatDetail': flatDetail,
    'coordinates': coordinates,
    'isDefault': isDefault,
  };
}

class AddressRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiService.get(ApiConstants.addresses);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => AddressModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await _apiService.post(ApiConstants.addresses, address.toJson());
      return AddressModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _apiService.delete('${ApiConstants.addresses}/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    final response = await _apiService.put('${ApiConstants.addresses}/$id', address.toJson());
    return AddressModel.fromJson(response.data);
  }

  Future<AddressModel> setDefaultAddress(String id) async {
    final response = await _apiService.put('${ApiConstants.addresses}/$id/default', {});
    return AddressModel.fromJson(response.data);
  }
}
