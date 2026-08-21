import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/app_sizes.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final product = controller.product.value;
        if (product == null)
          return const Center(child: Text('Product not found'));

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(product),
                  _buildProductInfo(product),
                  _buildStoreCard(product),
                  _buildTabs(),
                  _buildTabContent(product),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            _buildTopBar(),
            _buildBottomBar(product),
          ],
        );
      }),
    );
  }

  Widget _buildHeroImage(dynamic product) {
    return Container(
      width: double.infinity,
      height: 350.h,
      color: AppColors.lightOrange.withValues(alpha: 0.5),
      padding: EdgeInsets.all(50.w),
      child: Center(
        child: product.imageUrl != null
            ? Image.network(product.imageUrl!)
            : Icon(
                Icons.bakery_dining_outlined,
                size: 150.sp,
                color: AppColors.primary,
              ),
      ),
    );
  }

  Widget _buildProductInfo(dynamic product) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Product Name',
                      style: TextStyle(
                        fontSize: AppSizes.fontDisplay,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${product.unit ?? ''} • ${product.category ?? ''}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${product.discountPrice ?? product.price}',
                    style: TextStyle(
                      fontSize: AppSizes.fontDisplay,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.discountPrice != null)
                    Text(
                      '₹${product.price}',
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingLg),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              SizedBox(width: 8.w),
              Text(
                '${product.rating ?? '4.5'} (${product.reviewCount ?? '0'})',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Text(
                  product.stockQuantity > 0
                      ? '${AppStrings.inStock} (${product.stockQuantity} left)'
                      : 'Out of Stock',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(dynamic product) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl),
      child: Text(
        product.description ?? 'No description available for this product.',
        style: const TextStyle(color: Colors.grey, height: 1.5),
      ),
    );
  }

  Widget _buildBottomBar(dynamic product) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100.h,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.decrementQuantity,
                    icon: const Icon(Icons.remove),
                  ),
                  Obx(
                    () => Text(
                      '${controller.quantity.value}',
                      style: TextStyle(
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.incrementQuantity,
                    icon: const Icon(Icons.add, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.paddingLg),
            Expanded(
              child: ElevatedButton(
                onPressed: product.stockQuantity > 0 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(0, AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.w),
                  ),
                ),
                child: Text(
                  AppStrings.addToCart,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXl,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50.h,
      left: AppSizes.paddingXl,
      right: AppSizes.paddingXl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
              onPressed: () => Get.back(),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.favorite_border,
                color: AppColors.secondary,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(dynamic product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.store_outlined, color: AppColors.secondary),
          ),
          SizedBox(width: AppSizes.paddingLg),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharma Kirana Store',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '4.8 • 400m • 15 min delivery',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              AppStrings.chat,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [AppStrings.details, AppStrings.nutrition, AppStrings.reviews];
    return Padding(
      padding: EdgeInsets.only(top: 25.h, left: AppSizes.paddingXl),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == AppStrings.details; // Temporary
          return Container(
            margin: EdgeInsets.only(right: AppSizes.paddingLg),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
