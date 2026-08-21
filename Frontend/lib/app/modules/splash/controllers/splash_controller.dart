import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/socket_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    debugPrint('Splash: Starting navigation check...');
    await Future.delayed(const Duration(seconds: 3));

    final storage = Get.find<StorageService>();
    final profileService = Get.find<ProfileService>();
    final socket = Get.find<SocketService>();
    final token = storage.getToken();

    debugPrint(
      'Splash: Stored token: ${token != null ? "FOUND" : "NOT FOUND"}',
    );

    if (token == null || token.isEmpty) {
      debugPrint('Splash: No token, redirecting to Auth');
      Get.offAllNamed(Routes.AUTH);
      return;
    }

    try {
      debugPrint('Splash: Fetching profile...');
      final user = await profileService.getProfile();
      final role = (user['role'] ?? '').toString().toUpperCase();
      final onboarding = Map<String, dynamic>.from(user['onboarding'] ?? {});
      final nextStep = (onboarding['nextStep'] ?? '').toString().toUpperCase();

      debugPrint(
        'Splash: User Profile Loaded. Role: $role, Next Step: $nextStep',
      );

      await storage.saveRole(role);
      socket.reconnect();
      socket.authenticateUser(user['_id'].toString());

      switch (nextStep) {
        case 'ROLE_SELECTION':
          Get.offAllNamed(Routes.ROLE_SELECTION);
          break;
        case 'ADDRESS_SETUP':
          Get.offAllNamed(Routes.ADDRESS_SETUP);
          break;
        case 'MERCHANT_KYC':
          Get.offAllNamed(Routes.MERCHANT_KYC);
          break;
        case 'READY':
          if (role == 'BUYER') {
            Get.offAllNamed(Routes.HOME);
          } else if (role == 'SHOPKEEPER') {
            Get.offAllNamed(Routes.MERCHANT_DASHBOARD);
          } else if (role == 'RIDER') {
            Get.offAllNamed(Routes.RIDER_DASHBOARD);
          } else {
            debugPrint(
              'Splash: Unknown role: $role, redirecting to Role Selection',
            );
            Get.offAllNamed(Routes.ROLE_SELECTION);
          }
          break;
        default:
          debugPrint('Splash: Unknown nextStep: $nextStep, defaulting to Auth');
          await storage.clearAll();
          Get.offAllNamed(Routes.AUTH);
      }
    } on DioException catch (e) {
      debugPrint('Splash: Dio Error: ${e.type} - ${e.message}');
      if (e.response?.statusCode == 401) {
        debugPrint(
          'Splash: 401 Unauthorized, clearing storage and redirecting to Auth',
        );
        await storage.clearAll();
        Get.offAllNamed(Routes.AUTH);
      } else {
        debugPrint('Splash: Network error, showing retry snackbar');
        Get.snackbar(
          'Connection Error',
          'Could not connect to server. Please check your internet.',
          mainButton: TextButton(
            onPressed: () => _navigateToNext(),
            child: const Text('Retry'),
          ),
          duration: const Duration(days: 1),
        );
      }
    } catch (e) {
      debugPrint('Splash: Unexpected Error: $e');
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    }
  }
}
