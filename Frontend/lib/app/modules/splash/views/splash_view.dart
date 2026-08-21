import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../widgets/common/common_text.dart';
import '../../../widgets/common/app_logo.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = controller;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFFFF5722)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50.h,
              left: -50.w,
              child: _buildBubble(200.w, Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
              top: 100.h,
              right: -30.w,
              child: _buildBubble(150.w, Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
              bottom: 150.h,
              left: 20.w,
              child: _buildBubble(100.w, Colors.white.withValues(alpha: 0.05)),
            ),
            Positioned(
              bottom: -20.h,
              right: 40.w,
              child: _buildBubble(180.w, Colors.white.withValues(alpha: 0.1)),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30.w),
                    ),
                    child: AppLogo(
                      size: 80.w,
                      borderRadius: 20.w,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CommonText(
                    AppStrings.appName,
                    type: TextType.header,
                    color: AppColors.surface,
                    fontSize: 40.sp,
                    letterSpacing: 1.2,
                  ),
                  SizedBox(height: 8.h),
                  CommonText(
                    AppStrings.splashSlogan,
                    type: TextType.body,
                    color: AppColors.surface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Center(
                child: CommonText(
                  AppStrings.splashVersion,
                  type: TextType.caption,
                  color: AppColors.surface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
