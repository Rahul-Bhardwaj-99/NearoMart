import 'package:flutter/material.dart';
import '../../core/values/colors.dart';
import '../../core/values/app_sizes.dart';
import 'common_text.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;

  const CommonCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StoreCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String rating;
  final String distance;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CommonCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
              child: Image.network(
                imageUrl,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120.h,
                  color: AppColors.background,
                  child: Icon(Icons.store, color: AppColors.textSecondary, size: 24.sp),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    name,
                    type: TextType.body,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.primary, size: 16.sp),
                      SizedBox(width: 4.w),
                      CommonText(rating, type: TextType.caption),
                      SizedBox(width: 12.w),
                      Icon(Icons.location_on, color: AppColors.textSecondary, size: 16.sp),
                      SizedBox(width: 4.w),
                      CommonText(distance, type: TextType.caption),
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

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.shopping_bag_outlined, size: 40.sp, color: AppColors.textSecondary),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          CommonText(
            name,
            type: TextType.body,
            fontWeight: FontWeight.w600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                price,
                type: TextType.body,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Icon(Icons.add, color: AppColors.surface, size: 20.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
