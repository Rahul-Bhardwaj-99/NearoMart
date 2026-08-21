import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/widgets/common/common_text.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final Color color;
  final double? width;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 105.w,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          CommonText(
            value,
            type: TextType.title,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 5.h),
          CommonText(
            label,
            type: TextType.caption,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            CommonText(
              subtitle!,
              type: TextType.caption,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ],
        ],
      ),
    );
  }
}

class QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(height: 12.h),
              CommonText(
                label,
                type: TextType.caption,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
