import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';
import '../../../core/utils/size_config.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  String? get _orderId {
    final args = OrderArguments.fromGetArguments(Get.arguments);
    return args?.orderId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Success Animation
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: Colors.teal, size: 80.sp),
            ),
            SizedBox(height: 40.h),
            Text(
              'Order Placed! 🎉',
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: const Color(0xFF263238)),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your order has been sent to the store',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16.sp),
            ),
            SizedBox(height: 40.h),
            
            // Order Summary Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20.w),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text('Order Number', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  Text('#ORD-2026-8921', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFFFF9800))),
                  Divider(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryItem('Amount Paid', '₹452.00'),
                      _summaryItem('Payment', 'UPI'),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryItem('Delivery ETA', '15-20 min'),
                      _summaryItem('Delivery To', 'Sector 17'),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            ElevatedButton(
              onPressed: () => Get.toNamed(
                Routes.ORDER_TRACKING,
                arguments: OrderArguments.fromId(_orderId ?? ''),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
              ),
              child: Text('Track Order', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
            ),
            SizedBox(height: 15.h),
            TextButton(
              onPressed: () => Get.offAllNamed(Routes.HOME),
              child: Text('Continue Shopping', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      ],
    );
  }
}
