import 'package:get/get.dart';
import '../controllers/address_setup_controller.dart';

class AddressSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressSetupController>(() => AddressSetupController());
  }
}
