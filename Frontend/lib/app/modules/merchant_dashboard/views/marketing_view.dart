import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';
import '../../../core/utils/size_config.dart';
import '../controllers/merchant_dashboard_controller.dart';

class MarketingView extends GetView<MerchantDashboardController> {
  const MarketingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(AppStrings.specialsAndBroadcast, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            _buildQrSection(),
            SizedBox(height: 30.h),
            _buildBroadcastSection(),
            SizedBox(height: 30.h),
            _buildSpecialsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Text(AppStrings.shopQrCode, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
          SizedBox(height: 8.h),
          Text(AppStrings.shopQrCodeDesc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          SizedBox(height: 30.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: const Color(0xFF1A1C2E), borderRadius: BorderRadius.circular(20.w)),
            child: Icon(Icons.qr_code_2, size: 150.sp, color: Colors.white),
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.print_outlined, size: 18.sp, color: Colors.white),
                  label: const Text('Print PDF', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download_outlined, size: 18.sp, color: AppColors.primary),
                  label: const Text('Download', style: TextStyle(color: AppColors.primary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastSection() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(25.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, color: Colors.pink, size: 24.sp),
              SizedBox(width: 10.w),
              Text('Broadcast Notification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          Text('Send push alert to all followers', style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.w), border: Border.all(color: Colors.grey.shade200)),
            child: TextField(
              controller: controller.broadcastController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your announcement... (e.g. 20% OFF on all Dairy products today!)',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => controller.broadcastMessage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
            ),
            child: const Text('Send Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily Specials & Stories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
            ElevatedButton(
              onPressed: () {
                // Implement Create Special Logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              ),
              child: Text('+ Create', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Obx(() {
          if (controller.specials.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Text('No active specials', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              ),
            );
          }
          return Column(
            children: controller.specials.map((s) => _specialItem(
              s['title'],
              '₹${s['price']}',
              '₹${(s['price'] ?? 0) + 20}', // Placeholder old price
              '2h 30m left' // Should be calculated
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _specialItem(String name, String price, String old, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(15.w)),
            child: Icon(Icons.restaurant, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Row(
                  children: [
                    Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16.sp)),
                    SizedBox(width: 10.w),
                    Text(old, style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 13.sp)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10.w)),
            child: Text(time, style: TextStyle(color: Colors.pink, fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
