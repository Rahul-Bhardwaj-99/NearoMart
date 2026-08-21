import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../data/services/socket_service.dart';

class RoleSelectionController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final selectedRole = RxnString();

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void onContinue() async {
    if (selectedRole.value == null) return;

    final role = selectedRole.value!.trim().toUpperCase();
    final normalizedRole = role == 'MERCHANT' ? 'SHOPKEEPER' : role;

    try {
      await _storageService.saveRole(normalizedRole);
      final response = await _apiService.put(ApiConstants.updateRole, {'role': normalizedRole});
      final refreshedToken = response.data['token'] as String?;
      if (refreshedToken != null && refreshedToken.isNotEmpty) {
        await _storageService.saveToken(refreshedToken);
      }

      final userData = response.data['user'] as Map<String, dynamic>? ?? {};
      _socketService.reconnect();
      if (userData['_id'] != null) {
        _socketService.authenticateUser(userData['_id']);
      }

      if (normalizedRole == 'BUYER') {
        Get.toNamed(Routes.ADDRESS_SETUP);
      } else if (normalizedRole == 'SHOPKEEPER') {
        Get.toNamed(Routes.MERCHANT_KYC);
      } else if (normalizedRole == 'RIDER') {
        Get.offAllNamed(Routes.RIDER_DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role. Please try again.');
    }
  }
}
