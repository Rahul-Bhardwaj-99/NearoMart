import 'package:get/get.dart';
import '../controllers/shop_kyc_controller.dart';

class ShopKycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopKycController>(() => ShopKycController());
  }
}
