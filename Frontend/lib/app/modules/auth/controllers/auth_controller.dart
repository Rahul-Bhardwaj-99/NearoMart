import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/user_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/socket_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final SocketService _socketService = Get.find<SocketService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final verificationId = ''.obs;
  final otpCode = ''.obs;

  Future<void> login() async {
    if (phoneController.text.length < 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit phone number');
      return;
    }

    if (isOtpSent.value) {
      await verifyOtp();
    } else {
      await sendOtp();
    }
  }

  Future<void> sendOtp() async {
    try {
      isLoading.value = true;
      await _storageService.removeToken();
      await _storageService.saveOnboarded(false);
      String phoneNumber = "+91${phoneController.text}";

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _syncWithBackend();
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar('Auth Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verId, int? resendToken) {
          isLoading.value = false;
          verificationId.value = verId;
          isOtpSent.value = true;
          Get.snackbar('Success', 'OTP sent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to send OTP: $e');
    }
  }

  Future<void> verifyOtp() async {
    if (otpCode.value.length < 6) {
      Get.snackbar('Error', 'Please enter the 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpCode.value,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _syncWithBackend();
      }
    } catch (e) {
      isLoading.value = false;
      String message = 'Invalid OTP. Please try again.';
      if (e is FirebaseAuthException) {
        message = e.message ?? message;
      }
      Get.snackbar('Error', message);
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) throw Exception('Firebase user not found');

      final idToken = await firebaseUser.getIdToken();

      final response = await _apiService.post(ApiConstants.verifyOtp, {
        'idToken': idToken,
        'phone': firebaseUser.phoneNumber,
        'firebaseUid': firebaseUser.uid,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'] as String?;
        final userData = response.data['user'] as Map<String, dynamic>? ?? {};
        final rawRole = userData['role'];
        final normalizedRole = ((rawRole ?? '')
            .toString()
            .trim()
            .toUpperCase() == 'MERCHANT'
            ? 'SHOPKEEPER'
            : (rawRole ?? '').toString().trim().toUpperCase());
        final isOnboarded = userData['isOnboarded'] ?? false;

        if (token == null || token.isEmpty) {
          throw Exception('Authentication token missing from server response');
        }

        await _storageService.saveToken(token);
        await _storageService.saveOnboarded(isOnboarded);

        if (normalizedRole.isNotEmpty) {
          await _storageService.saveRole(normalizedRole);
        }

        _socketService.reconnect();
        _socketService.authenticateUser(userData['_id']);

        // Refresh the shared user profile after login so UserService is in sync.
        await Get.find<UserService>().refreshProfile();

        if (!isOnboarded) {
          Get.offAllNamed(Routes.ROLE_SELECTION);
          return;
        }

        if (normalizedRole == 'BUYER') {
          Get.offAllNamed(Routes.HOME);
        } else if (normalizedRole == 'SHOPKEEPER') {
          Get.offAllNamed(Routes.MERCHANT_DASHBOARD);
        } else if (normalizedRole == 'RIDER') {
          Get.offAllNamed(Routes.RIDER_DASHBOARD);
        } else {
          Get.offAllNamed(Routes.ROLE_SELECTION);
        }
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Backend sync failed',
        );
      }
    } catch (e) {
      String errorMessage = 'Connection failed. Is the server running?';
      if (e is DioException) {
        errorMessage = 'Server error: ${e.message}';
      }
      Get.snackbar('Error', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
