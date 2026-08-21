import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/common/common_button.dart';
import '../../../widgets/common/common_text.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      backgroundColor: Colors.white,
      isLoading: controller.isLoading.value,
      leading: controller.isOtpSent.value
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => controller.isOtpSent.value = false,
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isOtpSent.value
                          ? Icons.verified_user_outlined
                          : Icons.smartphone_outlined,
                      size: 60.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  CommonText(
                    controller.isOtpSent.value
                        ? AppStrings.verifyOtp
                        : AppStrings.enterMobile,
                    type: TextType.header,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  CommonText(
                    controller.isOtpSent.value
                        ? "${AppStrings.otpSentDesc}+91 ${controller.phoneController.text}"
                        : AppStrings.sendOtpDesc,
                    type: TextType.body,
                    textAlign: TextAlign.center,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 50.h),
                  if (!controller.isOtpSent.value)
                    _buildPhoneInput()
                  else
                    _buildOtpInput(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: CommonButton(
              onPressed: () => controller.login(),
              text: controller.isOtpSent.value
                  ? AppStrings.verifyAndContinue
                  : AppStrings.sendOtp,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPhoneInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CommonText(
            AppStrings.inPlus91,
            type: TextType.body,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(width: 15.w),
          Container(width: 1.w, height: 30.h, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          SizedBox(width: 15.w),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.w,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppStrings.phoneHint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  letterSpacing: 0,
                  fontSize: 18.sp,
                ),
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        TextField(
          onChanged: (val) => controller.otpCode.value = val,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 10.w,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: "0 0 0 0 0 0",
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              letterSpacing: 10.w,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            fillColor: Colors.transparent,
          ),
        ),
        SizedBox(height: 20.h),
        CommonText(
          "Enter the 6-digit code",
          type: TextType.caption,
        ),
      ],
    );
  }
}
