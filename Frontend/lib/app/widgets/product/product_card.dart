import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/core/values/strings.dart';
import 'package:nearomart/app/widgets/common/common_text.dart';

enum ProductCardMode { list, grid, cart }

class ProductCard extends StatelessWidget {
  final dynamic product;
  final ProductCardMode mode;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final int quantity;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.mode = ProductCardMode.list,
    this.onAdd,
    this.onRemove,
    this.quantity = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ProductCardMode.list:
        return _buildListMode();
      case ProductCardMode.grid:
        return _buildGridMode();
      case ProductCardMode.cart:
        return _buildCartMode();
    }
  }

  Widget _buildListMode() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            _buildImage(80.w),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    product.name ?? 'Product Name',
                    type: TextType.body,
                    fontWeight: FontWeight.bold,
                  ),
                  CommonText(
                    product.unit ?? 'Unit',
                    type: TextType.caption,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        '₹${product.price}',
                        type: TextType.title,
                        color: AppColors.primary,
                      ),
                      _buildQuantitySelector(),
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

  Widget _buildGridMode() {
    // Basic implementation for grid
    return Container(); 
  }

  Widget _buildCartMode() {
     return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface, 
        borderRadius: BorderRadius.circular(20.w), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ),
      child: Row(
        children: [
          _buildImage(60.w),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(product.name ?? 'Product', type: TextType.body, fontWeight: FontWeight.bold),
                SizedBox(height: 5.h),
                CommonText('₹${product.price}', type: TextType.body, color: AppColors.primary, fontWeight: FontWeight.bold),
              ],
            ),
          ),
          _buildQuantitySelector(),
        ],
      ),
    );
  }

  Widget _buildImage(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: product.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: Image.network(product.imageUrl!, fit: BoxFit.cover),
            )
          : Icon(Icons.shopping_bag_outlined, color: AppColors.textSecondary, size: size * 0.4),
    );
  }

  Widget _buildQuantitySelector() {
    if (quantity > 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.remove, size: 18.sp, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            CommonText(
              '$quantity',
              type: TextType.body,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onAdd,
              child: Icon(Icons.add, size: 18.sp, color: AppColors.primary),
            ),
          ],
        ),
      );
    }
    return ElevatedButton(
      onPressed: onAdd,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: Size(70.w, 32.h),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
      ),
      child: CommonText(
        AppStrings.add,
        type: TextType.caption,
        color: AppColors.surface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
