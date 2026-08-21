import '../services/api_service.dart';
import '../models/shop_model.dart';
import '../../core/values/api_constants.dart';
import 'package:get/get.dart';

class HomeRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<ShopModel>> getNearbyShops(double lat, double lng) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.shops}/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': 10,
        },
      );
      
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ShopModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
