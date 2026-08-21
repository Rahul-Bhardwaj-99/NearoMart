import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rider_navigation_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';

class RiderOtpView extends GetView<RiderNavigationController> {
  const RiderOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Delivery OTP Verification',
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 40.h),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_person_outlined, size: 60.sp, color: Colors.green),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            'Enter Delivery OTP',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Ask the customer for their 4-digit OTP to confirm delivery',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 40.h),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildOtpBox(index)),
          )),
          const Spacer(),
          _buildKeypad(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    String char = "";
    if (controller.otpCode.value.length > index) {
      char = controller.otpCode.value[index];
    }
    
    return Container(
      width: 65.w,
      height: 75.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(
          color: controller.otpCode.value.length == index ? AppColors.primary : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _keyButton('1'),
              _keyButton('2'),
              _keyButton('3'),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _keyButton('4'),
              _keyButton('5'),
              _keyButton('6'),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _keyButton('7'),
              _keyButton('8'),
              _keyButton('9'),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80, height: 60), // Placeholder
              _keyButton('0'),
              _actionButton(Icons.backspace_outlined, () => controller.removeDigit()),
            ],
          ),
          SizedBox(height: 30.h),
          Obx(() => ElevatedButton(
            onPressed: controller.otpCode.value.length == 4 ? () => controller.completeDelivery() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
            ),
            child: controller.isLoading.value 
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('Verify & Complete', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _keyButton(String text) {
    return InkWell(
      onTap: () => controller.addDigit(text),
      borderRadius: BorderRadius.circular(40.w),
      child: Container(
        width: 80.w,
        height: 60.h,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.w),
      child: Container(
        width: 80.w,
        height: 60.h,
        alignment: Alignment.center,
        child: Icon(icon, size: 28.sp),
      ),
    );
  }
}
