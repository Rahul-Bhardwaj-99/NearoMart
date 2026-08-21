import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/base/base_controller.dart';

import '../../../data/services/socket_service.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/values/socket_events.dart';
import '../../../routes/arguments/arguments.dart';

class RiderDashboardController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final UserService _userService = Get.find<UserService>();
  final isOnline = true.obs;
  final currentIndex = 0.obs;
  final availableDeliveries = <dynamic>[].obs;
  final activeDeliveries = <dynamic>[].obs;
  final historyDeliveries = <dynamic>[].obs;
  final stats = <String, dynamic>{
    'totalEarnings': 0,
    'totalDeliveries': 0,
    'todayEarnings': 0,
    'todayDeliveries': 0,
    'rating': 5.0
  }.obs;
  final wallet = <String, dynamic>{'balance': 0, 'transactions': []}.obs;
  final pendingDispatch = Rxn<dynamic>();
  Rx<UserModel?> get userProfile => _userService.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchEverything();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on(SocketEvents.newDispatch, (data) {
      pendingDispatch.value = data;
      Get.snackbar(
        'New Request', 
        'New delivery request from ${data['shopName']}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 10),
      );
    });
  }

  Future<void> fetchEverything() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchDeliveries(),
        fetchStats(),
        fetchHistory(),
        fetchWallet(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleOnline(bool val) async {
    try {
      final response = await _apiService.put(ApiConstants.riderAvailability, {
        'isAvailable': val,
      });
      if (response.statusCode == 200) {
        isOnline.value = val;
        if (val) fetchEverything();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update availability');
    }
  }

  Future<void> fetchDeliveries() async {
    try {
      final responses = await Future.wait([
        _apiService.get(ApiConstants.availableDeliveries),
        _apiService.get(ApiConstants.myDeliveries),
      ]);
      if (responses[0].statusCode == 200) {
        availableDeliveries.assignAll(responses[0].data);
      }
      if (responses[1].statusCode == 200) {
        // Filter active vs historical
        final allMy = responses[1].data as List;
        activeDeliveries.assignAll(allMy.where((o) => o['orderStatus'] == 'DISPATCHED').toList());
      }
    } catch (_) {}
  }

  Future<void> fetchStats() async {
    try {
      final response = await _apiService.get('/orders/rider/stats');
      if (response.statusCode == 200) {
        stats.value = Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
  }

  Future<void> fetchHistory() async {
    try {
      final response = await _apiService.get('/orders/rider/history');
      if (response.statusCode == 200) {
        historyDeliveries.assignAll(response.data);
      }
    } catch (_) {}
  }

  Future<void> fetchWallet() async {
    try {
      final response = await _apiService.get('/orders/rider/wallet');
      if (response.statusCode == 200) {
        wallet.value = Map<String, dynamic>.from(response.data);
      }
    } catch (_) {}
  }

  Future<void> acceptDispatch(String orderId) async {
    try {
      final response = await _apiService.put('${ApiConstants.orders}/$orderId/accept-delivery', {});
      if (response.statusCode == 200) {
        pendingDispatch.value = null;
        await fetchEverything();
        Get.toNamed(Routes.RIDER_NAVIGATION, arguments: RiderOrderArguments.fromData(response.data));
      }
    } catch (e) {
      Get.snackbar('Error', 'This delivery is no longer available');
      pendingDispatch.value = null;
    }
  }

  void declineDispatch() {
    pendingDispatch.value = null;
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
      _userService.clear();
      Get.find<StorageService>().clearAll();
      Get.offAllNamed(Routes.AUTH);
    } catch (_) {
      _userService.clear();
      Get.find<StorageService>().clearAll();
      Get.offAllNamed(Routes.AUTH);
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
