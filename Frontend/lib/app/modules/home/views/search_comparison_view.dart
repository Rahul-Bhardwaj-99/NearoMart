import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/search_comparison_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class SearchComparisonView extends GetView<SearchComparisonController> {
  const SearchComparisonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: _buildSearchBar(),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isMapView.value ? Icons.list : Icons.map_outlined, color: AppColors.primary, size: 24.sp),
            onPressed: () => controller.toggleView(),
          )),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() => controller.isMapView.value ? _buildMapView() : _buildListView()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() => Text(
              controller.searchQuery.value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            _filterChip(AppStrings.relevance, isSelected: true),
            _filterChip(AppStrings.nearest),
            _filterChip(AppStrings.priceLowHigh),
            _filterChip(AppStrings.priceHighLow),
            _filterChip(AppStrings.rating),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 1.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (controller.products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_outlined, size: 64.sp, color: Colors.grey.shade300),
              SizedBox(height: 16.h),
              Text(AppStrings.noProductsFound, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return _comparisonCard(product);
        },
      );
    });
  }

  Widget _comparisonCard(dynamic product) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12.w)),
            child: Icon(Icons.store_outlined, color: AppColors.secondary, size: 24.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name ?? 'Store Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Row(
                  children: [
                    Text('400m away', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${product.price}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(60.w, 30.h),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
                ),
                child: Text(AppStrings.add, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(initialCenter: controller.userLocation.value, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.nearomart.app',
        ),
        MarkerLayer(
          markers: controller.products.map((p) => _priceMarker(controller.userLocation.value, '₹${p.price}')).toList(),
        ),
      ],
    );
  }

  Marker _priceMarker(dynamic point, String price) {
    return Marker(
      point: point,
      width: 60.w,
      height: 40.h,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(color: AppColors.primary, width: 2.w),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12.sp)),
      ),
    );
  }
}
