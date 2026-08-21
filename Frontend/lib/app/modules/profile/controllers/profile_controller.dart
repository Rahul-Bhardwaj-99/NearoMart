import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final UserService userService = Get.find<UserService>();

  RxBool get isLoading => userService.isLoading;
  Rx<UserModel?> get currentUser => userService.currentUser;

  Future<void> fetchProfile() async {
    await userService.refreshProfile();
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      debugPrint('Logout request failed: $e');
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Firebase logout failed: $e');
    }
    _socketService.disconnect();
    await storageService.clearAll();
    
    // Clear cached user data and related services
    userService.clear();
    
    Get.offAllNamed(Routes.AUTH);
  }
}
