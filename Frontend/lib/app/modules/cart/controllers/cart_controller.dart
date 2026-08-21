import 'package:get/get.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class CartController extends GetxController {
  final CartService cartService = Get.find<CartService>();
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final selectedPaymentMethod = 'COD'.obs;

  Future<void> placeOrder() async {
    final shop = cartService.currentShop.value;
    if (shop?.id == null || cartService.items.isEmpty || isLoading.value) {
      Get.snackbar('Error', 'Your cart is empty or the shop is unavailable');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.post(ApiConstants.orders, {
        'shopId': shop!.id,
        'orderType': shop.deliveryEnabled == true ? 'DELIVERY' : 'PICKUP_CHAT',
        'paymentMethod': selectedPaymentMethod.value == 'COD' ? 'COD' : 'RAZORPAY',
        'items': cartService.items.map((item) => {
          'productId': item.product.id,
          'quantity': item.quantity,
        }).toList(),
      });

      if (response.statusCode == 201) {
        cartService.clearCart();
        Get.toNamed(Routes.ORDER_SUCCESS, arguments: OrderArguments.fromData(response.data));
      }
    } catch (e) {
      Get.snackbar('Order failed', 'We could not place your order. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
