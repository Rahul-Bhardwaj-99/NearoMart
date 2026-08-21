import 'package:get/get.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/arguments/arguments.dart';

import '../../../data/services/cart_service.dart';
import '../../../data/services/socket_service.dart';

class ShopDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final CartService cartService = Get.find<CartService>();
  final SocketService _socketService = Get.find<SocketService>();
  
  final Rxn<ShopModel> shop = Rxn<ShopModel>();
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from ShopArguments
    final args = ShopArguments.fromGetArguments(Get.arguments);
    if (args != null) {
      // Try to get shopData first, fallback to creating from ID
      if (args.shopData != null) {
        // Convert map to ShopModel if not already
        shop.value = args.shopData is ShopModel 
            ? args.shopData as ShopModel
            : ShopModel.fromJson(args.shopData!);
      } else if (args.shopId.isNotEmpty) {
        // If we only have ID, we might fetch full details
        _fetchShopDetails(args.shopId);
      }
      
      if (shop.value != null) {
        _socketService.joinPublicShop(shop.value!.id!);
        _socketService.on('product_created', _handleCatalogChange);
        _socketService.on('product_updated', _handleCatalogChange);
        _socketService.on('product_deleted', _handleCatalogChange);
        _socketService.on('review_created', _handleReviewChange);
        _socketService.on('shop_rating_changed', _handleReviewChange);
        fetchShopProducts();
        fetchReviews();
      }
    }
  }

  Future<void> _fetchShopDetails(String shopId) async {
    try {
      final response = await _apiService.get('${ApiConstants.shops}/$shopId');
      if (response.statusCode == 200) {
        shop.value = ShopModel.fromJson(response.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop details');
    }
  }

  void _handleCatalogChange(dynamic data) {
    fetchShopProducts();
  }

  void _handleReviewChange(dynamic data) {
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    if (shop.value?.id == null) return;
    try {
      final response = await _apiService.get('${ApiConstants.orders}/shop/${shop.value!.id}/reviews');
      if (response.statusCode == 200) {
        reviews.assignAll((response.data as List).map((item) => ReviewModel.fromJson(item)));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop reviews');
    }
  }

  @override
  void onClose() {
    _socketService.socket?.off('product_created', _handleCatalogChange);
    _socketService.socket?.off('product_updated', _handleCatalogChange);
    _socketService.socket?.off('product_deleted', _handleCatalogChange);
    _socketService.socket?.off('review_created', _handleReviewChange);
    _socketService.socket?.off('shop_rating_changed', _handleReviewChange);
    super.onClose();
  }

  Future<void> fetchShopProducts() async {
    if (shop.value?.id == null) return;
    
    try {
      isLoading.value = true;
      final response = await _apiService.get('${ApiConstants.products}/shop/${shop.value!.id}');
      if (response.statusCode == 200) {
        products.assignAll(
          (response.data as List).map((e) => ProductModel.fromJson(e)).toList()
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop products');
    } finally {
      isLoading.value = false;
    }
  }
}
