import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_product_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';

class AddProductView extends GetView<AddProductController> {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already present
    if (!Get.isRegistered<AddProductController>()) {
      Get.put(AddProductController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Product' : 'Add New Product',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20.sp),
        )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoUpload(),
            SizedBox(height: 30.h),
            _buildLabel('Product Name *'),
            _buildTextField(controller.nameController, 'e.g. Aashirvaad Shudh Chakki Atta'),
            
            SizedBox(height: 20.h),
            _buildLabel('Brand (Optional)'),
            _buildTextField(controller.brandController, 'e.g. Aashirvaad'),
            
            SizedBox(height: 20.h),
            _buildLabel('Category *'),
            _buildCategoryDropdown(),
            
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Price (₹) *'),
                      _buildTextField(controller.priceController, '0.00', isNumber: true),
                    ],
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Unit'),
                      _buildTextField(controller.unitController, 'e.g. 5kg, 1L'),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            _buildLabel('Initial Stock Quantity'),
            _buildTextField(controller.stockController, '0', isNumber: true),
            
            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => controller.saveProduct(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                    ),
                    child: controller.isLoading.value 
                      ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          controller.isEditMode.value ? 'Update Product' : 'Save Product',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25.w),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), style: BorderStyle.solid, width: 2.w),
      ),
      child: Obx(() => controller.selectedImage.value != null || controller.imageUrl.value.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(23.w),
            child: controller.selectedImage.value != null
                ? Image.file(controller.selectedImage.value!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                : Image.network(controller.imageUrl.value, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          )
        : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: Colors.orange, size: 40.sp),
          SizedBox(height: 12.h),
          Text('Upload Product Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.orange)),
          SizedBox(height: 4.h),
          Text('Tap to take photo or browse gallery', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text('Auto-compressed before upload', style: TextStyle(color: Colors.grey.shade400, fontSize: 10.sp)),
        ],
      )),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.textSecondary)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15.w), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp), border: InputBorder.none),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15.w), border: Border.all(color: Colors.grey.shade200)),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedCategory.value,
          hint: Text('Select Category', style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: controller.categories.map((String cat) {
            return DropdownMenuItem<String>(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (val) => controller.selectedCategory.value = val,
        ),
      )),
    );
  }
}
