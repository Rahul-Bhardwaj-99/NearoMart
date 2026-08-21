import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/arguments/arguments.dart';

class ProductDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final RxBool isLoading = false.obs;
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final args = ProductArguments.fromGetArguments(Get.arguments);
    if (args != null) {
      if (args.productData != null) {
        product.value = ProductModel.fromJson(args.productData!);
      } else {
        _fetchProductDetails(args.productId);
      }
    }
  }

  Future<void> _fetchProductDetails(String productId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('${ApiConstants.products}/$productId');
      if (response.statusCode == 200) {
        product.value = ProductModel.fromJson(response.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product details');
    } finally {
      isLoading.value = false;
    }
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }
}
