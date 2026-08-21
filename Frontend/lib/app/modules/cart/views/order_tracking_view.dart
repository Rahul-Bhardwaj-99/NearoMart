import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../core/utils/size_config.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrderTrackingController>()) {
      Get.put(OrderTrackingController());
    }

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF263238), size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${controller.order.value?['orderNumber'] ?? 'Loading...'}', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
            Text('Live Tracking', style: TextStyle(color: const Color(0xFF263238), fontWeight: FontWeight.bold, fontSize: 18.sp)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Map Section
          FlutterMap(
            options: const MapOptions(initialCenter: LatLng(30.7333, 76.7794), initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nearomart.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(30.7333, 76.7794),
                    width: 50.w,
                    height: 50.w,
                    child: Icon(Icons.location_on, color: Colors.red, size: 40.sp),
                  ),
                  Marker(
                    point: const LatLng(30.7350, 76.7810),
                    width: 50.w,
                    height: 50.w,
                    child: Icon(Icons.delivery_dining, color: const Color(0xFFFF9800), size: 40.sp),
                  ),
                ],
              ),
            ],
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusStepper(),
                  Divider(height: 40.h),
                  if (controller.order.value?['orderStatus'] == 'DELIVERED')
                    _buildReviewButton(context),
                  _buildReplacementRequests(),
                  _buildRiderCard(),
                  SizedBox(height: 20.h),
                  _buildDeliveryOtp(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatusStepper() {
    final stages = ['Placed', 'Accepted', 'Packed', 'On Way', 'Done'];
    final currentStep = controller.currentStep;

    return Row(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentStep;
        final isActive = index == currentStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 4.h, color: index == 0 ? Colors.transparent : (isCompleted ? const Color(0xFFFF9800) : Colors.grey.shade200))),
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFFFF9800) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isCompleted ? const Color(0xFFFF9800) : Colors.grey.shade300, width: 2.w),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : (isActive ? Icon(Icons.radio_button_checked, color: const Color(0xFFFF9800), size: 16.sp) : null),
                  ),
                  Expanded(child: Container(height: 4.h, color: index == stages.length - 1 ? Colors.transparent : (index < currentStep ? const Color(0xFFFF9800) : Colors.grey.shade200))),
                ],
              ),
              SizedBox(height: 8.h),
              Text(stages[index], style: TextStyle(fontSize: 10.sp, fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, color: isCompleted ? const Color(0xFF263238) : Colors.grey)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRiderCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20.w), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(radius: 25.w, backgroundColor: const Color(0xFFFF9800), child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp))),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(controller.order.value?['riderId']?['name'] ?? 'Rider not assigned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Text(controller.order.value?['riderId'] == null ? 'Your rider will appear here after dispatch' : 'Delivery partner', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.chat_bubble_outline, color: const Color(0xFFFF9800), size: 24.sp)),
          IconButton(onPressed: () {}, icon: Icon(Icons.phone_outlined, color: const Color(0xFFFF9800), size: 24.sp)),
        ],
      ),
    );
  }

  Widget _buildReplacementRequests() {
    final items = (controller.order.value?['items'] as List?) ?? [];
    final pending = items.where((item) => item['replacement']?['status'] == 'PROPOSED').toList();
    if (pending.isEmpty) return const SizedBox.shrink();
    final replacement = pending.first['replacement'];
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Replacement available', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5.h),
          Text('${pending.first['productName']} → ${replacement['productName']}'),
          SizedBox(height: 10.h),
          Row(
            children: [
              OutlinedButton(onPressed: () => controller.respondToReplacement('REJECTED'), child: const Text('Keep original')),
              SizedBox(width: 10.w),
              ElevatedButton(onPressed: () => controller.respondToReplacement('ACCEPTED'), child: const Text('Accept replacement')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showReviewDialog(context),
          icon: const Icon(Icons.star_outline),
          label: const Text('Rate this shop'),
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    final commentController = TextEditingController();
    var rating = 5;
    Get.dialog(AlertDialog(
      title: const Text('Rate your experience'),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: rating,
              items: [1, 2, 3, 4, 5].map((value) => DropdownMenuItem(value: value, child: Text('$value stars'))).toList(),
              onChanged: (value) => setState(() => rating = value ?? 5),
            ),
            TextField(controller: commentController, maxLines: 3, decoration: const InputDecoration(hintText: 'Share your experience')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.submitReview(rating, commentController.text.trim());
          },
          child: const Text('Submit review'),
        ),
      ],
    ));
  }

  Widget _buildDeliveryOtp() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: const Color(0xFF263238), borderRadius: BorderRadius.circular(20.w)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery OTP (share with rider)', style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
              SizedBox(height: 4.h),
              Text((controller.order.value?['deliveryOtp'] ?? '----').toString().split('').join(' '), style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold, letterSpacing: 8.w)),
            ],
          ),
          Icon(Icons.lock_open_outlined, color: const Color(0xFFFF9800), size: 40.sp),
        ],
      ),
    );
  }
}
