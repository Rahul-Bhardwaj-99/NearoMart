import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/address_repository.dart';
import 'package:flutter/material.dart';

import '../../../data/services/api_service.dart';
import '../../../core/values/api_constants.dart';

// ignore_for_file: constant_identifier_names

enum AddressSetupStep { SELECT_LOCATION, CONFIRM_LOCATION, ENTER_DETAILS }

class AddressSetupController extends GetxController {
  final AddressRepository _addressRepository = AddressRepository();
  final ApiService _apiService = Get.find<ApiService>();
  final mapController = MapController();
  
  final currentStep = AddressSetupStep.SELECT_LOCATION.obs;
  final selectedLocation = const LatLng(30.7333, 76.7794).obs;
  final addressLabel = 'Home'.obs;
  
  final addressLine1 = 'Fetching address...'.obs;
  final addressLine2 = ''.obs;
  final isFetchingAddress = false.obs;
  final isMapMoving = false.obs;
  
  final flatDetailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    reverseGeocode(selectedLocation.value);
    ever(selectedLocation, (callback) => reverseGeocode(callback));
  }

  void updateLocation(LatLng point) {
    selectedLocation.value = point;
  }

  void updateLabel(String label) {
    addressLabel.value = label;
  }

  Future<void> reverseGeocode(LatLng location) async {
    try {
      isFetchingAddress.value = true;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude, 
        location.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        addressLine1.value = "${place.name}, ${place.subLocality}";
        addressLine2.value = "${place.locality}, ${place.administrativeArea} - ${place.postalCode}";
      }
    } catch (e) {
      addressLine1.value = "Unknown Location";
      addressLine2.value = "Tap or move pin to retry";
    } finally {
      isFetchingAddress.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentLatLng;
      mapController.move(currentLatLng, 15);
      
      if (currentStep.value == AddressSetupStep.SELECT_LOCATION) {
        currentStep.value = AddressSetupStep.CONFIRM_LOCATION;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch current location: $e');
    }
  }

  void goToDetails() {
    currentStep.value = AddressSetupStep.ENTER_DETAILS;
  }

  Future<void> saveAddress() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill required fields');
      return;
    }

    try {
      final address = AddressModel(
        label: addressLabel.value,
        addressText: "${addressLine1.value}, ${addressLine2.value}",
        fullName: nameController.text,
        phoneNumber: phoneController.text,
        flatDetail: flatDetailController.text,
        coordinates: [selectedLocation.value.longitude, selectedLocation.value.latitude],
      );
      
      await _addressRepository.addAddress(address);
      await _apiService.put(ApiConstants.completeOnboarding, {});
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save address: $e');
    }
  }

  @override
  void onClose() {
    flatDetailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    super.onClose();
  }
}
