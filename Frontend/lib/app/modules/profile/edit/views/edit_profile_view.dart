import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/values/colors.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(25.w),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60.w,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: controller.profileImage.value != null
                            ? FileImage(controller.profileImage.value!) as ImageProvider
                            : (controller.profileImageUrl.value.isNotEmpty
                                ? NetworkImage(controller.profileImageUrl.value)
                                : null),
                        child: controller.profileImage.value == null && controller.profileImageUrl.value.isEmpty
                            ? Icon(Icons.person, size: 60.sp, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _showImageSourceSheet(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                _buildField('Full Name', controller.nameController, Icons.person_outline),
                SizedBox(height: 20.h),
                _buildField('Email Address', controller.emailController, Icons.email_outlined, isReadOnly: true, suffix: _buildVerifyButton('Change Email', () => controller.saveProfile())),
                SizedBox(height: 20.h),
                _buildField('Phone Number', controller.phoneController, Icons.phone_android_outlined, isReadOnly: true, suffix: _buildVerifyButton('Change Phone', () => controller.saveProfile())),
                SizedBox(height: 40.h),
                ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 55.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
                  ),
                  child: Text('Save Name & Photo', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      )),
    );
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Profile Photo', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildField(String label, TextEditingController textController, IconData icon, {bool isReadOnly = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        TextField(
          controller: textController,
          readOnly: isReadOnly,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.w), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          ),
        ),
      ],
    );
  }
}
