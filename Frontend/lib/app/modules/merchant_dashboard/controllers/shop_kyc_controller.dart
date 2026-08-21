import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/location_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/app_pages.dart';

class ShopKycController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final LocationService _locationService = Get.find<LocationService>();

  final currentStep = 0.obs;
  final isLoading = false.obs;
  final selectedBanner = Rxn<File>();
  final ImagePicker _imagePicker = ImagePicker();

  final shopNameController = TextEditingController();
  final shopCategoryController = TextEditingController();
  final shopAddressController = TextEditingController();

  final gstinController = TextEditingController();
  final fssaiController = TextEditingController();
  final drugLicenseController = TextEditingController();

  final accountHolderNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();

  Future<void> pickBanner() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 900,
      imageQuality: 80,
    );
    if (image != null) selectedBanner.value = File(image.path);
  }

  Future<String?> _uploadBanner() async {
    final image = selectedBanner.value;
    if (image == null) return null;
    final fileName = image.path.split(Platform.pathSeparator).last;
    final response = await _apiService.post('/uploads/files', {
      'fileName': fileName,
      'fileType': 'image/jpeg',
      'folder': 'shops',
      'data': base64Encode(await image.readAsBytes()),
    });
    if (response.statusCode != 201) return null;
    final fileUrl = response.data['fileUrl'] as String?;
    return fileUrl == null ? null : '${ApiConstants.baseUrl.replaceFirst('/api', '')}$fileUrl';
  }

  Future<void> nextStep() async {
    if (currentStep.value < 2) {
      currentStep.value++;
      return;
    }

    await submitKyc();
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> submitKyc() async {
    if (!_validateFields()) return;

    try {
      isLoading.value = true;
      final bannerUrl = await _uploadBanner();

      Position? position;
      try {
        position = await _locationService.getCurrentPosition();
      } catch (_) {
        position = null;
      }

      final payload = {
        'shopName': shopNameController.text.trim(),
        'category': shopCategoryController.text,
        'addressText': shopAddressController.text.trim(),
        'gstin': gstinController.text.trim(),
        'fssaiLicense': fssaiController.text.trim(),
        'drugLicense': drugLicenseController.text.trim(),
        'bankDetails': {
          'accountHolderName': accountHolderNameController.text.trim(),
          'bankName': bankNameController.text.trim(),
          'accountNumber': accountNumberController.text.trim(),
          'ifscCode': ifscCodeController.text.trim(),
        }
      };

      if (position != null) {
        payload['coordinates'] = [position.longitude, position.latitude];
        payload['lat'] = position.latitude;
        payload['lng'] = position.longitude;
      }
      if (bannerUrl != null) payload['bannerUrl'] = bannerUrl;

      final response = await _apiService.post(ApiConstants.shops, payload);

      if (response.statusCode == 201) {
        Get.offAllNamed(Routes.MERCHANT_DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit KYC. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateFields() {
    if (shopNameController.text.trim().isEmpty || shopAddressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all required shop info');
      return false;
    }
    if (accountNumberController.text.trim().isEmpty || ifscCodeController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill required bank details');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    shopNameController.dispose();
    shopCategoryController.dispose();
    shopAddressController.dispose();
    gstinController.dispose();
    fssaiController.dispose();
    drugLicenseController.dispose();
    accountHolderNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    super.onClose();
  }
}
