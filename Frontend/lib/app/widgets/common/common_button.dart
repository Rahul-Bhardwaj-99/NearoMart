import 'package:flutter/material.dart';
import '../../core/values/colors.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/values/app_sizes.dart';

import 'common_text.dart';

enum ButtonType { solid, outlined, ghost }

class CommonButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double? width;
  final bool isLoading;
  final ButtonType type;
  final Color? color;

  const CommonButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.isLoading = false,
    this.type = ButtonType.solid,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? context.widthPct(0.9);
    final primaryColor = color ?? AppColors.primary;

    switch (type) {
      case ButtonType.solid:
        return SizedBox(
          width: effectiveWidth,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.controlRadius)),
            ),
            child: _buildContent(context, Colors.white),
          ),
        );
      case ButtonType.outlined:
        return SizedBox(
          width: effectiveWidth,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.controlRadius)),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: _buildContent(context, primaryColor),
          ),
        );
      case ButtonType.ghost:
        return SizedBox(
          width: effectiveWidth,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: _buildContent(context, primaryColor),
          ),
        );
    }
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20.sp, color: type == ButtonType.solid ? AppColors.surface : textColor),
          SizedBox(width: 8.w),
        ],
        CommonText(
          text,
          type: TextType.button,
          color: type == ButtonType.solid ? AppColors.surface : textColor,
        ),
      ],
    );
  }
}
