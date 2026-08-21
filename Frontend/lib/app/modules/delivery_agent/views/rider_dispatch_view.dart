import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../core/utils/size_config.dart';
import '../controllers/rider_dashboard_controller.dart';

class RiderDispatchView extends StatelessWidget {
  const RiderDispatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final riderController = Get.isRegistered<RiderDashboardController>()
      ? Get.find<RiderDashboardController>()
      : Get.put(RiderDashboardController());
    final deliveryId = riderController.availableDeliveries.isNotEmpty
      ? riderController.availableDeliveries.first['_id']?.toString()
      : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Background
          FlutterMap(
            options: const MapOptions(initialCenter: LatLng(30.7333, 76.7794), initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nearomart.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(point: const LatLng(30.7333, 76.7794), width: 40.w, height: 40.w, child: Icon(Icons.location_on, color: Colors.red, size: 30.sp)),
                  Marker(point: const LatLng(30.7350, 76.7810), width: 40.w, height: 40.w, child: Icon(Icons.store, color: const Color(0xFFFF9800), size: 30.sp)),
                ],
              ),
            ],
          ),

          // Request Overlay
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.all(25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.w),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEW DISPATCH', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 1.w, fontSize: 12.sp)),
                          Text('REQUEST!', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        width: 50.w,
                        height: 50.w,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                        child: const CircularProgressIndicator(value: 0.7, strokeWidth: 4, color: Colors.orange),
                      ),
                    ],
                  ),
                  Divider(height: 40.h),
                  _locationRow(Icons.store, 'Sharma Kirana Store', 'Pickup: Shop 14, Main Market, Sector 17', '0.6 km from you'),
                  SizedBox(height: 20.h),
                  _locationRow(Icons.home, 'House 102, Sector 17', 'Drop-off: Chandigarh', '1.8 km from store • Est. 12 min'),
                  Divider(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _detailItem('Order Value', '₹452'),
                      _detailItem('Your Earnings', '₹48'),
                      _detailItem('Total Distance', '2.4 km'),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(minimumSize: Size(0, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                          child: Text('✕ Decline', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: deliveryId == null
                              ? null
                              : () => riderController.acceptDispatch(deliveryId),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), minimumSize: Size(0, 55.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w))),
                          child: Text('✓ Accept Dispatch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, String title, String sub, String meta) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20.sp),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text(sub, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              SizedBox(height: 4.h),
              Text(meta, style: TextStyle(color: Colors.orange, fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      ],
    );
  }
}
