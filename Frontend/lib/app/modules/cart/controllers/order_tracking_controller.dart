import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/values/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../routes/arguments/arguments.dart';

class OrderTrackingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  final order = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  String? orderId;

  final riderLocation = Rxn<Map<String, double>>();

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from OrderArguments
    final args = OrderArguments.fromGetArguments(Get.arguments);
    if (args != null && args.orderId.isNotEmpty) {
      orderId = args.orderId;
      // Pre-populate order if full data was passed
      if (args.orderData != null) {
        order.value = args.orderData;
      }
      fetchOrder();
      _socketService.on('order_status_update', _handleStatusUpdate);
      _socketService.on('replacement_proposed', _handleReplacementUpdate);
      _socketService.on('replacement_decided', _handleReplacementUpdate);
      _socketService.on('rider_location_changed', _handleRiderLocation);
    }
  }

  void _handleRiderLocation(dynamic data) {
    if (data is! Map || data['orderId']?.toString() != orderId) return;
    riderLocation.value = {
      'lat': (data['lat'] as num).toDouble(),
      'lng': (data['lng'] as num).toDouble(),
    };
  }

  Future<void> fetchOrder() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('${ApiConstants.orders}/$orderId');
      if (response.statusCode == 200) {
        order.value = Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleStatusUpdate(dynamic data) {
    if (data is! Map ||
        data['orderId']?.toString() != orderId ||
        order.value == null) {
      return;
    }
    order.value = {...order.value!, 'orderStatus': data['status']};
  }

  void _handleReplacementUpdate(dynamic data) {
    if (data is! Map || data['orderId']?.toString() != orderId) return;
    fetchOrder();
  }

  Future<void> respondToReplacement(String decision) async {
    if (orderId == null) return;
    try {
      final response = await _apiService.put(
        '${ApiConstants.orders}/$orderId/replacements/respond',
        {'decision': decision},
      );
      if (response.statusCode == 200) {
        order.value = Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update replacement decision');
    }
  }

  Future<void> submitReview(int rating, String comment) async {
    if (orderId == null) return;
    try {
      final response = await _apiService.post(
        '${ApiConstants.orders}/$orderId/review',
        {'rating': rating, 'comment': comment},
      );
      if (response.statusCode == 201) {
        Get.snackbar('Thank you', 'Your review helps other shoppers');
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to submit review');
    }
  }

  int get currentStep {
    const steps = ['PLACED', 'ACCEPTED', 'PACKED', 'DISPATCHED', 'DELIVERED'];
    final status = order.value?['orderStatus'];
    final index = steps.indexOf(status);
    return index < 0 ? 0 : index;
  }

  @override
  void onClose() {
    _socketService.socket?.off('order_status_update', _handleStatusUpdate);
    _socketService.socket?.off(
      'replacement_proposed',
      _handleReplacementUpdate,
    );
    _socketService.socket?.off('replacement_decided', _handleReplacementUpdate);
    debugPrint('Order tracking listener removed');
    super.onClose();
  }
}
