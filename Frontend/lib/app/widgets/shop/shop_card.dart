import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/core/values/strings.dart';

class ShopCard extends StatelessWidget {
  final dynamic shop;
  final VoidCallback onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: shop.bannerUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15.w),
                      child: Image.network(shop.bannerUrl!, fit: BoxFit.cover),
                    )
                  : Icon(Icons.store_outlined, color: AppColors.primary, size: 30.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.shopName ?? 'Store Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (shop.minOrderValue != null && shop.minOrderValue > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: Text(
                            '₹${shop.minOrderValue} Min',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    shop.category?.join(' • ') ?? AppStrings.generalStore,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.primary, size: 14.sp),
                      Text(
                        ' ${shop.rating ?? '0.0'}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                      ),
                      Text(
                        '10-15 min',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                      ),
                      SizedBox(width: 10.w),
                      if (shop.isOpen ?? true)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined, color: AppColors.success, size: 12.sp),
                              SizedBox(width: 4.w),
                              Text(
                                AppStrings.open,
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
