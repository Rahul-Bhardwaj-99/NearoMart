import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/widgets/common/common_text.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? profilePic;
  final String initial;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.profilePic,
    required this.initial,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50.w,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: (profilePic != null && profilePic!.isNotEmpty)
                  ? NetworkImage(profilePic!)
                  : null,
              child: (profilePic == null || profilePic!.isEmpty)
                  ? CommonText(
                      initial,
                      type: TextType.header,
                      color: AppColors.primary,
                      fontSize: 40.sp,
                    )
                  : null,
            ),
            if (onEdit != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, color: AppColors.surface, size: 16.sp),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 15.h),
        CommonText(
          name,
          type: TextType.header,
          fontSize: 22.sp,
        ),
        if (subtitle != null)
          CommonText(
            subtitle!,
            type: TextType.caption,
          ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final effectiveIconColor = iconColor ?? (isDestructive ? AppColors.error : AppColors.primary);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: effectiveIconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: effectiveIconColor,
          size: 20.sp,
        ),
      ),
      title: CommonText(
        title,
        type: TextType.body,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: AppColors.textSecondary.withValues(alpha: 0.5)),
    );
  }
}

class WalletWidget extends StatelessWidget {
  final String balance;
  final VoidCallback onWithdraw;
  final Color? color;

  const WalletWidget({
    super.key,
    required this.balance,
    required this.onWithdraw,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.secondary;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.w),
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(25.w),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                'Wallet Balance',
                type: TextType.caption,
                color: AppColors.surface.withValues(alpha: 0.7),
              ),
              CommonText(
                '₹$balance',
                type: TextType.header,
                color: AppColors.surface,
                fontSize: 28.sp,
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onWithdraw,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.w),
              ),
            ),
            child: CommonText(
              'Withdraw',
              type: TextType.caption,
              color: themeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
