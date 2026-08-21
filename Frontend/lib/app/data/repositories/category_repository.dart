import '../services/api_service.dart';
import '../models/category_model.dart';
import '../../core/values/api_constants.dart';
import 'package:get/get.dart';

class CategoryRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.categories);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => CategoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
