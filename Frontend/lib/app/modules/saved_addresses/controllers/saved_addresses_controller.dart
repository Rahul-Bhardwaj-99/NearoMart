import 'package:get/get.dart';
import '../../../data/repositories/address_repository.dart';

class SavedAddressesController extends GetxController {
  final AddressRepository _addressRepository = AddressRepository();
  
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final result = await _addressRepository.getAddresses();
      addresses.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _addressRepository.deleteAddress(id);
      addresses.removeWhere((element) => element.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete address: $e');
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      await _addressRepository.setDefaultAddress(id);
      await fetchAddresses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to set default address');
    }
  }
}
