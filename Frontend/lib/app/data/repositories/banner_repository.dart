import '../services/api_service.dart';
import '../models/banner_model.dart';
import '../../core/values/api_constants.dart';
import 'package:get/get.dart';

class BannerRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final response = await _apiService.get(ApiConstants.banners);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => BannerModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
