import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/saved_addresses_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/strings.dart';
import '../../../routes/arguments/arguments.dart';
import '../../../routes/app_pages.dart';

class SavedAddressesView extends GetView<SavedAddressesController> {
  const SavedAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(AppStrings.savedAddresses, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.ADDRESS_SETUP),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15.w),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 24.sp),
                    SizedBox(width: 15.w),
                    Text(AppStrings.addNew, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16.sp),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(AppStrings.savedAddressesLabel, style: TextStyle(color: AppColors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (controller.addresses.isEmpty) {
                return Center(child: Text(AppStrings.noSavedAddresses, style: TextStyle(color: AppColors.grey, fontSize: 14.sp)));
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  return _buildAddressCard(address);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(dynamic address) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.w)),
            child: Icon(_getIcon(address.label), color: AppColors.secondary, size: 24.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(address.fullName ?? 'Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.sp),
                      onPressed: () => Get.toNamed(
                        Routes.ADDRESS_SETUP,
                        arguments: AddressArguments.fromData(address, isEditing: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(address.addressText, style: TextStyle(color: Colors.grey, fontSize: 13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (address.phoneNumber != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(address.phoneNumber!, style: TextStyle(color: Colors.black87, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String label) {
    if (label.toLowerCase() == 'home') return Icons.home_outlined;
    if (label.toLowerCase() == 'work') return Icons.business_outlined;
    return Icons.location_on_outlined;
  }
}
