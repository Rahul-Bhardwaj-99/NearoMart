import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/shop/shop_card.dart';
import '../../../widgets/common/common_text.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/layout/custom_bottom_nav.dart';
import '../../../widgets/common/app_card.dart';
import '../../../core/values/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationHeader(),
              _buildSearchSection(),
              _buildCategories(),
              _buildPromoBanner(),
              _buildQuickServices(),
              _buildNearbyStoresHeader(),
              _buildStoresList(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Get.offAllNamed(Routes.DISCOVER);
          if (index == 2) Get.toNamed(Routes.SEARCH_COMPARISON);
          if (index == 3) Get.offAllNamed(Routes.PROFILE);
          if (index == 4) Get.toNamed(Routes.CART);
        },
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),
          SizedBox(width: AppSizes.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonText(AppStrings.deliveringTo, type: TextType.caption),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: AppSizes.iconSm,
                    ),
                  ],
                ),
                Obx(
                  () => CommonText(
                    controller.currentAddress.value,
                    type: TextType.body,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingSm + 2.w),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: AppColors.secondary,
                  size: AppSizes.iconLg,
                ),
              ),
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: AppSizes.paddingMd),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: Obx(() {
              final user = controller.userService.currentUser.value;
              return CircleAvatar(
                radius: AppSizes.profileAvatarRadius,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    (user?.profilePic != null && user!.profilePic!.isNotEmpty)
                    ? NetworkImage(user.profilePic!)
                    : null,
                child: (user?.profilePic == null || user!.profilePic!.isEmpty)
                    ? Text(
                        controller.userService.userNameInitial,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.fontLg,
                        ),
                      )
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.SEARCH_COMPARISON),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLg, vertical: AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconMd,
                    ),
                    SizedBox(width: AppSizes.paddingSm),
                    CommonText(AppStrings.searchHint, type: TextType.caption),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingMd),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: AppColors.surface,
              size: AppSizes.iconLg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXxl),
      child: SizedBox(
        height: 100.h,
        child: Obx(
          () => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Padding(
                padding: EdgeInsets.only(right: AppSizes.paddingXl),
                child: Column(
                  children: [
                    Container(
                      width: 65.w,
                      height: 65.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5.w,
                        ),
                      ),
                      padding: EdgeInsets.all(AppSizes.paddingMd),
                      child: Icon(
                        category.icon,
                        color: AppColors.primary,
                        size: AppSizes.iconXl,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingSm),
                    CommonText(
                      category.name,
                      type: TextType.caption,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Obx(() {
      if (controller.banners.isEmpty) return const SizedBox.shrink();

      final banner = controller.banners.first;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
        width: double.infinity,
        height: AppSizes.bannerHeight,
        decoration: BoxDecoration(
          image: banner.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(banner.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: banner.imageUrl.isEmpty
              ? LinearGradient(
                  colors: [AppColors.promoGradientStart, AppColors.promoGradientEnd],
                )
              : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        ),
        child: Stack(
          children: [
            if (banner.imageUrl.isEmpty)
              Positioned(
                right: -20.w,
                bottom: -20.h,
                child: Icon(
                  Icons.delivery_dining,
                  size: 150.sp,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingXxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonText(
                    banner.title,
                    type: TextType.title,
                    color: AppColors.surface,
                    fontSize: 22.sp,
                  ),
                  if (banner.shopName != null)
                    CommonText(
                      'At ${banner.shopName}',
                      type: TextType.caption,
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickServices() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
      child: Row(
        children: [
          _quickBox(
            AppStrings.grocery,
            Icons.shopping_cart_outlined,
            const Color(0xFFE3F2FD),
            const Color(0xFF2196F3),
          ),
          SizedBox(width: 15.w),
          _quickBox(
            AppStrings.dairy,
            Icons.water_drop_outlined,
            const Color(0xFFE3F2FD),
            const Color(0xFF2196F3),
          ),
          SizedBox(width: 15.w),
          _quickBox(
            AppStrings.bakery,
            Icons.bakery_dining_outlined,
            const Color(0xFFFFF3E0),
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _quickBox(String label, IconData icon, Color bg, Color iconColor) {
    return Expanded(
      child: AppCard(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingLg),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: AppSizes.iconLg),
            SizedBox(height: AppSizes.spacingSm),
            CommonText(
              label,
              type: TextType.caption,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyStoresHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingXl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => CommonText(
              '${AppStrings.nearbyStores} (${controller.nearbyShops.length})',
              type: TextType.title,
            ),
          ),
          Row(
            children: [
              Icon(Icons.map_outlined, color: AppColors.primary, size: AppSizes.iconSm),
              SizedBox(width: AppSizes.paddingXs),
              CommonText(
                AppStrings.mapView,
                type: TextType.caption,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingXl),
      child: Obx(() {
        if (controller.isShopsLoading.value && controller.nearbyShops.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.nearbyShops.isEmpty) {
          return EmptyStateWidget(
            title: AppStrings.noStoresFound,
            icon: Icons.storefront_outlined,
          );
        }
        return Column(
          children: controller.nearbyShops
              .map(
                (shop) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacingLg),
                  child: ShopCard(
                    shop: shop,
                    onTap: () =>
                        Get.toNamed(Routes.SHOP_DETAIL, arguments: ShopArguments.fromData(shop)),
                  ),
                ),
              )
              .toList(),
        );
      }),
    );
  }
}
