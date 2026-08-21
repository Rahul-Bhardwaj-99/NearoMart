import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/widgets/common/common_text.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            SizedBox(height: 20.h),
            CommonText(
              title,
              type: TextType.title,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              CommonText(
                subtitle!,
                type: TextType.caption,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: 30.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
