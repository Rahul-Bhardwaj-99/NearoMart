import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rider_navigation_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';

class RiderNavigationView extends GetView<RiderNavigationController> {
  const RiderNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            _buildFakeMap(),
            _buildHeader(),
            _buildInstructionBanner(),
            _buildOrderDetailsCard(),
          ],
        );
      }),
    );
  }

  Widget _buildFakeMap() {
    return Container(
      color: Colors.blue.shade50,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 100.sp, color: Colors.blue.withValues(alpha: 0.2)),
            Text('Live Navigation Map', style: TextStyle(color: Colors.blue.shade200, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 50.h, 20.w, 15.h),
        color: const Color(0xFF1A1F36),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.tripStatus.value == 'TO_STORE' ? 'Navigating to Pickup' : 'Navigating to Delivery',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                  Text(
                    controller.order.value?['shopId']?['shopName'] ?? 'Store',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10.w)),
              child: Text(
                controller.tripStatus.value.replaceAll('_', ' '),
                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Positioned(
      top: 110.h, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20.w),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15.w)),
              child: Icon(Icons.turn_right, color: Colors.white, size: 30.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Go straight on Main Market Rd', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Text('for 400m, then turn right', style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                ],
              ),
            ),
            Text('400m', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    final order = controller.order.value;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.all(25.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order Details', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _detailRow('Order', '#${order?['orderNumber'] ?? ''}'),
            _detailRow('Items', '${order?['items']?.length ?? 0} (Atta, Oil, Butter)'),
            _detailRow('Order Value', '₹${order?['grandTotal'] ?? 0}'),
            _detailRow('Payment', '${order?['paymentStatus'] ?? ''} via ${order?['paymentMethod'] ?? ''}'),
            SizedBox(height: 25.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    String buttonText = "Arrived at Shop";
    VoidCallback? onPressed;

    switch (controller.tripStatus.value) {
      case 'TO_STORE':
        buttonText = "Arrived at Shop";
        onPressed = () => controller.updateTripStatus('AT_STORE');
        break;
      case 'AT_STORE':
        buttonText = "Picked Up Order";
        onPressed = () => controller.updateTripStatus('TO_BUYER');
        break;
      case 'TO_BUYER':
        buttonText = "Arrived at Customer";
        onPressed = () => controller.updateTripStatus('AT_BUYER');
        break;
      case 'AT_BUYER':
        buttonText = "Complete Delivery (Enter OTP)";
        onPressed = () => controller.goToOtp();
        break;
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
            ),
            child: Text(buttonText, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(width: 15.w),
        Container(
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15.w)),
          child: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
