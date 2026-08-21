import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/role_selection_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    AppStrings.whoAreYou,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    AppStrings.roleSelectionDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  SizedBox(height: 40.h),
                  _buildRoleCard(
                    'BUYER',
                    AppStrings.buyerTitle,
                    AppStrings.buyerDesc,
                    Icons.shopping_cart_outlined,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF2196F3),
                  ),
                  SizedBox(height: 20.h),
                  _buildRoleCard(
                    'SHOPKEEPER',
                    AppStrings.merchantTitle,
                    AppStrings.merchantDesc,
                    Icons.store_outlined,
                    const Color(0xFFFFF3E0),
                    AppColors.primary,
                  ),
                  SizedBox(height: 20.h),
                  _buildRoleCard(
                    'RIDER',
                    AppStrings.riderTitle,
                    AppStrings.riderDesc,
                    Icons.delivery_dining_outlined,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: Obx(() => ElevatedButton(
              onPressed: controller.selectedRole.value == null ? null : () => controller.onContinue(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
              ),
              child: Text(
                controller.selectedRole.value == null 
                    ? AppStrings.selectRole 
                    : '${AppStrings.continueAs}${controller.selectedRole.value} →',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    String role,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == role;
      return GestureDetector(
        onTap: () => controller.selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.w),
            border: Border.all(
              color: isSelected ? iconColor : Colors.grey.shade200,
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: Icon(icon, color: iconColor, size: 30.sp),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: iconColor, size: 24.sp)
              else
                Icon(Icons.circle_outlined, color: Colors.grey, size: 24.sp),
            ],
          ),
        ),
      );
    });
  }
}
