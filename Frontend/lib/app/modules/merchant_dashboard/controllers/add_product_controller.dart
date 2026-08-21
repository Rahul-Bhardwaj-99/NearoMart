import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../routes/arguments/arguments.dart';
import 'merchant_dashboard_controller.dart';

class AddProductController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isEditMode = false.obs;
  final selectedImage = Rxn<File>();
  final imageUrl = ''.obs;
  String? editingProductId;
  final ImagePicker _imagePicker = ImagePicker();

  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController();
  final stockController = TextEditingController();
  
  final selectedCategory = RxnString();
  final isLoading = false.obs;

  final categories = [
    'Grocery',
    'Dairy',
    'Bakery',
    'Fruits',
    'Vegetables',
    'Medicines',
    'Electronics',
    'Household'
  ];

  @override
  void onInit() {
    super.onInit();
    // Parse typed arguments from ProductArguments
    final args = ProductArguments.fromGetArguments(Get.arguments);
    if (args != null && args.productData != null) {
      final product = args.productData!;
      editingProductId = args.productId;

      if (editingProductId != null && editingProductId!.isNotEmpty) {
        isEditMode.value = true;
        nameController.text = product['name'] ?? '';
        brandController.text = product['brand'] ?? '';
        priceController.text = (product['price'] ?? '').toString();
        unitController.text = product['unit'] ?? '';
        stockController.text = (product['stockQuantity'] ?? 0).toString();
        selectedCategory.value = product['category'];
        imageUrl.value = product['imageUrl'] ?? '';
      }
    }
  }

  Future<void> pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (image != null) selectedImage.value = File(image.path);
  }

  Future<String?> _uploadImage(File image) async {
    final fileName = image.path.split(Platform.pathSeparator).last;
    final bytes = await image.readAsBytes();
    final response = await _apiService.post('/uploads/files', {
      'fileName': fileName,
      'fileType': 'image/jpeg',
      'folder': 'products',
      'data': base64Encode(bytes),
    });
    if (response.statusCode != 201) return null;
    final fileUrl = response.data['fileUrl'] as String?;
    return fileUrl == null ? null : '${ApiConstants.baseUrl.replaceFirst('/api', '')}$fileUrl';
  }

  void saveProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategory.value == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    final parsedPrice = double.tryParse(priceController.text);
    if (parsedPrice == null) {
      Get.snackbar('Error', 'Please enter a valid price');
      return;
    }

    try {
      isLoading.value = true;
      if (selectedImage.value != null) {
        final uploadedUrl = await _uploadImage(selectedImage.value!);
        if (uploadedUrl != null) imageUrl.value = uploadedUrl;
      }
      final payload = {
        'name': nameController.text,
        'brand': brandController.text,
        'category': selectedCategory.value,
        'price': parsedPrice,
        'unit': unitController.text.isEmpty ? '1 unit' : unitController.text,
        'stockQuantity': int.tryParse(stockController.text) ?? 0,
        'isAvailable': true,
        if (imageUrl.value.isNotEmpty) 'imageUrl': imageUrl.value,
      };

      final response = isEditMode.value && editingProductId != null
          ? await _apiService.put('${ApiConstants.products}/$editingProductId', payload)
          : await _apiService.post(ApiConstants.products, payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.find<MerchantDashboardController>().fetchInventory();
        Get.find<MerchantDashboardController>().fetchInventoryStats();
        Get.back();
        Get.snackbar('Success', isEditMode.value ? 'Product updated successfully' : 'Product added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', isEditMode.value ? 'Failed to update product' : 'Failed to add product');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    unitController.dispose();
    stockController.dispose();
    super.onClose();
  }
}
