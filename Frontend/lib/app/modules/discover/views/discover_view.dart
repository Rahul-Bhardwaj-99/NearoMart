import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../controllers/discover_controller.dart';
import '../../../widgets/layout/custom_bottom_nav.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/strings.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.currentCenter.value,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nearomart.app',
              ),
              Obx(() => MarkerLayer(
                markers: controller.homeController.nearbyShops.map((shop) {
                  return Marker(
                    point: controller.currentCenter.value, // Placeholder, shop model should have coords
                    width: 60.w,
                    height: 60.h,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.SHOP_DETAIL, arguments: ShopArguments.fromData(shop)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                          border: Border.all(color: AppColors.primary, width: 2.w),
                        ),
                        child: Icon(Icons.store, color: AppColors.primary, size: 20.sp),
                      ),
                    ),
                  );
                }).toList(),
              )),
            ],
          ),
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(AppStrings.searchHint, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(Routes.HOME);
          if (index == 2) Get.toNamed(Routes.SEARCH_COMPARISON);
          if (index == 3) Get.offAllNamed(Routes.PROFILE);
          if (index == 4) Get.toNamed(Routes.CART);
        },
      ),
    );
  }
}
