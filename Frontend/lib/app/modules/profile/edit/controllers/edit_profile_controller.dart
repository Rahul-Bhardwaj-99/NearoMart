import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/user_service.dart';
import '../../../../core/values/api_constants.dart';
import '../../../../routes/arguments/arguments.dart';

class EditProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final UserService _userService = Get.find<UserService>();
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  
  final ImagePicker _picker = ImagePicker();

  EditProfileArguments? _args;

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from EditProfileArguments
    final args = EditProfileArguments.fromGetArguments(Get.arguments);
    _args = args;
    if (args != null) {
      nameController.text = args.name ?? '';
      emailController.text = args.email ?? '';
      phoneController.text = args.phone ?? '';
      profileImageUrl.value = args.profilePic ?? '';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final fileType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final bytes = await image.readAsBytes();

      final response = await _apiService.post('/uploads/files', {
        'fileName': fileName,
        'fileType': fileType,
        'folder': 'profiles',
        'data': base64Encode(bytes),
      });

      if (response.statusCode == 201) {
        final fileUrl = response.data['fileUrl'] as String?;
        if (fileUrl == null) return null;
        return '${ApiConstants.baseUrl.replaceFirst('/api', '')}$fileUrl';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      
      String? newProfilePic = profileImageUrl.value;
      if (profileImage.value != null) {
        final uploadedUrl = await _uploadImage(profileImage.value!);
        if (uploadedUrl != null) {
          newProfilePic = uploadedUrl;
        }
      }

      final updateData = {
        'name': nameController.text,
        'profilePic': newProfilePic,
      };

      bool emailChanged = emailController.text != (_args?.email ?? '');
      bool phoneChanged = phoneController.text != (_args?.phone ?? '');

      if (emailChanged || phoneChanged) {
        await _requestUpdateWithOtp(emailChanged ? emailController.text : null, phoneChanged ? phoneController.text : null);
      } else {
        final response = await _apiService.put('/auth/update-profile', updateData);
        if (response.statusCode == 200) {
          await _userService.refreshProfile();
          Get.back(result: true);
          Get.snackbar('Success', 'Profile updated successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _requestUpdateWithOtp(String? email, String? phone) async {
    try {
      final response = await _apiService.post('/auth/request-update-otp', {
        'email': email,
        'phone': phone
      });

      if (response.statusCode == 200) {
        _showOtpDialog();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request OTP: $e');
    }
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Verify OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A 6-digit code has been sent to your new contact info.'),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(hintText: 'Enter OTP'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (otpController.text.length == 6) {
                await _verifyUpdateOtp(otpController.text);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyUpdateOtp(String otp) async {
    try {
      final response = await _apiService.post('/auth/verify-update-otp', {'otp': otp});
      if (response.statusCode == 200) {
        await _userService.refreshProfile();
        Get.back();
        Get.back(result: true);
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
