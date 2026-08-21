import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../home/controllers/home_controller.dart';

class DiscoverController extends GetxController {
  final MapController mapController = MapController();
  final HomeController homeController = Get.find<HomeController>();

  final Rx<LatLng> currentCenter = const LatLng(30.7333, 76.7794).obs;

  @override
  void onInit() {
    super.onInit();
    if (homeController.currentPosition.value != null) {
      currentCenter.value = LatLng(
        homeController.currentPosition.value!.latitude,
        homeController.currentPosition.value!.longitude,
      );
    }
  }
}
