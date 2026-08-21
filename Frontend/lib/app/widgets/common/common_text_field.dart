import 'package:flutter/material.dart';
import '../../core/values/colors.dart';
import '../../core/values/app_sizes.dart';
import '../../core/values/strings.dart';


class CommonTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const CommonTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary.withValues(alpha: 0.6)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        fillColor: AppColors.background,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}

class CommonSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterPressed;
  final ValueChanged<String>? onSearch;

  const CommonSearchBar({
    super.key,
    this.hintText = AppStrings.searchHint,
    this.controller,
    this.onFilterPressed,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSearch,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
                fillColor: AppColors.surface,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.controlRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onFilterPressed,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(Icons.tune, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}
