import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common/app_card.dart';
import '../../../core/values/app_sizes.dart';
import '../controllers/shop_detail_controller.dart';
import '../../../widgets/product/product_card.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class ShopDetailView extends GetView<ShopDetailController> {
  const ShopDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final shop = controller.shop.value;
        if (shop == null) return const Center(child: CircularProgressIndicator());
        
        return CustomScrollView(
          slivers: [
            _buildAppBar(shop),
            SliverToBoxAdapter(child: _buildShopInfo(shop)),
            SliverToBoxAdapter(child: _buildReviewsSection()),
            SliverToBoxAdapter(child: _buildCategoryTabs()),
            _buildProductsList(),
          ],
        );
      }),
      bottomNavigationBar: _buildCartSummary(),
    );
  }

  Widget _buildAppBar(dynamic shop) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (shop.bannerUrl != null)
              Image.network(shop.bannerUrl!, fit: BoxFit.cover)
            else
              Container(color: AppColors.primary),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo(dynamic shop) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  shop.shopName ?? 'Store Name',
                  style: TextStyle(fontSize: AppSizes.fontDisplay, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSm, vertical: AppSizes.paddingXs),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.green, size: AppSizes.iconSm),
                    Text(' ${shop.rating ?? '0.0'}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: AppSizes.fontMd)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingXs),
          Text(
            shop.category?.join(', ') ?? AppStrings.generalStore,
            style: TextStyle(color: Colors.grey, fontSize: AppSizes.fontMd),
          ),
          SizedBox(height: AppSizes.spacingMd),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey, size: AppSizes.iconSm),
              SizedBox(width: AppSizes.paddingXs),
              Expanded(child: Text(shop.addressText ?? 'Address not available', style: TextStyle(color: Colors.grey, fontSize: AppSizes.fontSm))),
            ],
          ),
          SizedBox(height: AppSizes.spacingLg),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      child: Row(
        children: [
          _categoryChip('All', true),
          _categoryChip(AppStrings.dairy, false),
          _categoryChip(AppStrings.bakery, false),
          _categoryChip('Snacks', false),
          _categoryChip('Beverages', false),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Obx(() {
      if (controller.reviews.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl, vertical: AppSizes.paddingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('What shoppers say', style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.bold)),
                Text('${controller.reviews.length} reviews', style: TextStyle(color: Colors.grey, fontSize: AppSizes.fontSm)),
              ],
            ),
            SizedBox(height: AppSizes.spacingMd),
            ...controller.reviews.take(3).map((review) => AppCard(
              margin: EdgeInsets.only(bottom: AppSizes.spacingSm),
              padding: EdgeInsets.all(AppSizes.paddingMd),
              color: Colors.grey.shade50,
              radius: AppSizes.radiusMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(review.buyerName ?? 'Verified shopper', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('${review.rating} ★', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if ((review.comment ?? '').isNotEmpty) ...[
                    SizedBox(height: AppSizes.spacingXs),
                    Text(review.comment!, style: TextStyle(color: Colors.grey.shade700, fontSize: AppSizes.fontMd)),
                  ],
                ],
              ),
            )),
            const Divider(),
          ],
        ),
      );
    });
  }

  Widget _categoryChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: AppSizes.paddingMd),
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg, vertical: AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: AppSizes.fontMd,
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
      }
      if (controller.products.isEmpty) {
        return SliverFillRemaining(
          child: EmptyStateWidget(
            title: AppStrings.noProductsAvailable,
            icon: Icons.inventory_2_outlined,
          ),
        );
      }
      return SliverPadding(
        padding: EdgeInsets.all(AppSizes.paddingXl),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = controller.products[index];
              return Obx(() {
                final itemInCart = controller.cartService.items.firstWhereOrNull((item) => item.product.id == product.id);
                return ProductCard(
                  product: product,
                  mode: ProductCardMode.list,
                  quantity: itemInCart?.quantity ?? 0,
                  onAdd: () => controller.cartService.addToCart(product, controller.shop.value!),
                  onRemove: () => controller.cartService.removeFromCart(product),
                );
              });
            },
            childCount: controller.products.length,
          ),
        ),
      );
    });
  }

  Widget _buildCartSummary() {
    return Obx(() {
      if (controller.cartService.items.isEmpty) return const SizedBox.shrink();
      
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/cart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${controller.cartService.totalItems} ${AppStrings.items}', style: TextStyle(color: Colors.white70, fontSize: AppSizes.fontXs, fontWeight: FontWeight.bold)),
                  Text('₹${controller.cartService.subtotal}', style: TextStyle(color: Colors.white, fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text(AppStrings.viewCart, style: TextStyle(color: Colors.white, fontSize: AppSizes.fontMd, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5.w),
                  Icon(Icons.shopping_cart_outlined, color: Colors.white, size: AppSizes.fontXl),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
