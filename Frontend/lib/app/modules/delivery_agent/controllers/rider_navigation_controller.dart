import 'package:get/get.dart';
import '../../../core/values/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class RiderNavigationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final otpCode = ''.obs;
  final isLoading = false.obs;
  final order = Rxn<dynamic>();
  String? orderId;

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from RiderOrderArguments
    final args = RiderOrderArguments.fromGetArguments(Get.arguments);
    if (args != null && args.orderId.isNotEmpty) {
      orderId = args.orderId;
      if (args.orderData != null) {
        order.value = args.orderData;
      }
      fetchOrderDetails();
    }
  }

  Future<void> fetchOrderDetails() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('${ApiConstants.orders}/$orderId');
      if (response.statusCode == 200) {
        order.value = response.data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  void addDigit(String digit) {
    if (otpCode.value.length < 4) {
      otpCode.value += digit;
    }
  }

  void removeDigit() {
    if (otpCode.value.isNotEmpty) {
      otpCode.value = otpCode.value.substring(0, otpCode.value.length - 1);
    }
  }

  final tripStatus = 'TO_STORE'.obs; // TO_STORE, AT_STORE, TO_BUYER, AT_BUYER

  void updateTripStatus(String status) {
    tripStatus.value = status;
  }

  void goToOtp() {
    Get.toNamed(Routes.RIDER_OTP, arguments: RiderOrderArguments.fromId(orderId ?? ''));
  }

  Future<void> completeDelivery() async {
    if (orderId == null || otpCode.value.length != 4 || isLoading.value) {
      Get.snackbar('Error', 'Enter the 4-digit delivery OTP');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.put(
        '${ApiConstants.orders}/$orderId/status',
        {'status': 'DELIVERED', 'deliveryOtp': otpCode.value},
      );
      if (response.statusCode == 200) {
        Get.offAllNamed(Routes.RIDER_DASHBOARD);
        Get.snackbar('Success', 'Delivery completed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid delivery OTP');
    } finally {
      isLoading.value = false;
    }
  }
}
