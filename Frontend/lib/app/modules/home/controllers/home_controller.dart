import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/banner_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/user_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  final HomeRepository _repository = HomeRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final BannerRepository _bannerRepository = BannerRepository();
  final LocationService _locationService = Get.find<LocationService>();
  final UserService userService = Get.find<UserService>();

  final RxList<ShopModel> nearbyShops = <ShopModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isShopsLoading = false.obs;
  final RxString currentAddress = 'Locating...'.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  Future<void> initializeData() async {
    isLoading.value = true;
    
    try {
      await Future.wait([
        fetchCategories(),
        fetchBanners(),
      ]);
    } catch (e) {
        debugPrint('Failed to initialize home data: $e');
    } finally {
      isLoading.value = false;
    }

    _loadLocationAndShops();
  }

  Future<void> _loadLocationAndShops() async {
    isShopsLoading.value = true;
    await fetchLocation();
    await fetchNearbyShops();
    isShopsLoading.value = false;
  }

  Future<void> fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        currentPosition.value = position;
        final address = await _locationService.getAddressFromLatLng(position.latitude, position.longitude);
        currentAddress.value = address;
      }
    } catch (e) {
      currentAddress.value = 'Enable location';
    }
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _categoryRepository.getCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
        debugPrint('Failed to load categories: $e');
    }
  }

  Future<void> fetchBanners() async {
    try {
      final fetchedBanners = await _bannerRepository.getActiveBanners();
      banners.assignAll(fetchedBanners);
    } catch (e) {
        debugPrint('Failed to load banners: $e');
    }
  }

  Future<void> fetchNearbyShops() async {
    try {
      if (currentPosition.value == null) return;
      
      final shops = await _repository.getNearbyShops(
        currentPosition.value!.latitude, 
        currentPosition.value!.longitude
      );
      nearbyShops.assignAll(shops);
    } catch (e) {
        debugPrint('Failed to load nearby shops: $e');
    }
  }
}
