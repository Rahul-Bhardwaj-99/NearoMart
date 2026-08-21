import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';

class SearchComparisonController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isMapView = false.obs;
  final searchQuery = 'Amul Taaza Milk 1 Liter'.obs;
  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final userLocation = const LatLng(30.7333, 76.7794).obs;

  @override
  void onInit() {
    super.onInit();
    searchProducts();
  }

  Future<void> searchProducts() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get(
        '${ApiConstants.products}/search',
        queryParameters: {'q': searchQuery.value},
      );
      if (response.statusCode == 200) {
        products.assignAll(
          (response.data as List).map((e) => ProductModel.fromJson(e)).toList()
        );
      }
    } catch (e) {
        debugPrint('Failed to search products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleView() {
    isMapView.value = !isMapView.value;
  }
}
