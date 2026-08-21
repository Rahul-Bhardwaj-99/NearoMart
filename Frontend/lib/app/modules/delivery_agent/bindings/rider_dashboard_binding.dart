import 'package:get/get.dart';
import '../controllers/rider_dashboard_controller.dart';

class RiderDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiderDashboardController>(() => RiderDashboardController());
  }
}
