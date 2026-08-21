import 'package:flutter/material.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/core/values/strings.dart';
import 'package:nearomart/app/core/utils/size_config.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline, size: 24.sp),
            activeIcon: Icon(Icons.play_circle_fill, size: 24.sp),
            label: AppStrings.discover,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined, size: 24.sp),
            activeIcon: Icon(Icons.grid_view, size: 24.sp),
            label: AppStrings.categories,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon: Icon(Icons.person, size: 24.sp),
            label: AppStrings.account,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 24.sp),
                if (true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
            activeIcon: Icon(Icons.shopping_cart, size: 24.sp),
            label: AppStrings.myCart,
          ),
        ],
      ),
    );
  }
}
