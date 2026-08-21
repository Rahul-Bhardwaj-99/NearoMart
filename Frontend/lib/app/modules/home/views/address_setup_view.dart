import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../../../core/utils/size_config.dart';
import '../controllers/address_setup_controller.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/strings.dart';

class AddressSetupView extends GetView<AddressSetupController> {
  const AddressSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(AppStrings.addNewAddress, style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.selectedLocation.value,
                initialZoom: 15,
                  onPointerDown: (_, _) => controller.isMapMoving.value = true,
                  onPointerUp: (_, _) => controller.isMapMoving.value = false,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    controller.updateLocation(position.center);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nearomart.app',
                ),
              ],
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.h),
              child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: controller.isMapMoving.value ? 20.h : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8.w)),
                      child: Text(AppStrings.placePinExactLocation, style: TextStyle(color: AppColors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    ),
                    Icon(Icons.location_on, color: Colors.black, size: 45.sp),
                  ],
                ),
              )),
            ),
          ),

          Positioned(
            bottom: 220.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => controller.getCurrentLocation(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(30.w), 
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.blue, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(AppStrings.useMyCurrentLocation, style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.w), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(AppStrings.searchByArea, style: TextStyle(color: AppColors.grey, fontSize: 14.sp)),
                ],
              ),
            ),
          ),

          Obx(() => _buildBottomSheet()),

          Obx(() {
            if (controller.currentStep.value == AddressSetupStep.SELECT_LOCATION) {
              return Container(
                color: Colors.black54,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25.w),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppStrings.deliverOrderQuestion, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        SizedBox(height: 10.h),
                        Text(AppStrings.mapLocationHelp, style: TextStyle(color: AppColors.grey, fontSize: 14.sp)),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                          onPressed: () => controller.currentStep.value = AddressSetupStep.CONFIRM_LOCATION,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: Size(double.infinity, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                          child: Text(AppStrings.awayFromMyLocation, style: TextStyle(color: AppColors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 15.h),
                        OutlinedButton(
                          onPressed: () => controller.getCurrentLocation(),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: Size(double.infinity, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.my_location, color: AppColors.primary, size: 20.sp),
                              SizedBox(width: 10.w),
                              Text(AppStrings.useCurrentLocation, style: TextStyle(color: AppColors.primary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    switch (controller.currentStep.value) {
      case AddressSetupStep.CONFIRM_LOCATION:
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver To', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.w), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.secondary, size: 24.sp),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.addressLine1.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            Text(controller.addressLine2.value, style: TextStyle(color: Colors.grey, fontSize: 13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      TextButton(onPressed: () => controller.currentStep.value = AddressSetupStep.SELECT_LOCATION, child: const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => controller.goToDetails(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: Size(double.infinity, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                  child: Text('Add address Details', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      case AddressSetupStep.ENTER_DETAILS:
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 600.h,
            width: double.infinity,
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliver To', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => controller.currentStep.value = AddressSetupStep.CONFIRM_LOCATION, icon: const Icon(Icons.close)),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10.w)),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
                              SizedBox(width: 10.w),
                              Expanded(child: Text('Ensure your address details are accurate for a smooth delivery experience', style: TextStyle(color: Colors.orange.shade800, fontSize: 12.sp))),
                            ],
                          ),
                        ),
                        SizedBox(height: 25.h),
                        _buildInputField('Flat/House/building name *', controller.flatDetailController),
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12.w)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Area / Sector / Locality', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                                    Text(controller.addressLine1.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                    Text(controller.addressLine2.value, style: TextStyle(color: Colors.black87, fontSize: 14.sp)),
                                  ],
                                ),
                              ),
                              TextButton(onPressed: () => controller.currentStep.value = AddressSetupStep.CONFIRM_LOCATION, child: const Text('Change')),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _buildInputField('Enter your full name *', controller.nameController),
                        SizedBox(height: 20.h),
                        _buildInputField('10-digit mobile number *', controller.phoneController),
                        SizedBox(height: 20.h),
                        _buildInputField('Alternate phone number (Optional)', controller.altPhoneController),
                        SizedBox(height: 25.h),
                        Text('Type of address', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _labelChip('Home', Icons.home_outlined),
                            SizedBox(width: 15.w),
                            _labelChip('Work', Icons.business_outlined),
                          ],
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => controller.saveAddress(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: Size(double.infinity, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                  child: Text('Save address', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputField(String label, TextEditingController textController) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _labelChip(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.addressLabel.value == label;
      return GestureDetector(
        onTap: () => controller.updateLabel(label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white, borderRadius: BorderRadius.circular(10.w), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300)),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.black, size: 18.sp),
              SizedBox(width: 8.w),
              Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.black, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ],
          ),
        ),
      );
    });
  }
}
