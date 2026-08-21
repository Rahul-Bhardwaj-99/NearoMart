import 'package:get/get.dart';
import '../../../data/services/order_service.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  final RxList orders = [].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool force = false}) async {
    try {
      isLoading.value = true;
      final fetchedOrders = await _orderService.getMyOrders(force: force);
      orders.assignAll(fetchedOrders);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh orders by clearing cache and fetching fresh data
  Future<void> refreshOrders() => fetchOrders(force: true);
}
