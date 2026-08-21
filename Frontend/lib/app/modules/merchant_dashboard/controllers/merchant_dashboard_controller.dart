import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/socket_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/user_service.dart';
import '../../../core/values/api_constants.dart';
import '../../../core/base/base_controller.dart';
import '../../../routes/app_pages.dart';

class MerchantDashboardController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  final isDeliveryOn = true.obs;
  final currentIndex = 0.obs;

  // Dashboard Stats
  final todayRevenue = 0.0.obs;
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final shopRating = 0.0.obs;
  final reviewCount = 0.obs;
  final shopName = 'Loading...'.obs;
  final shopId = ''.obs;

  // Orders
  final orders = <dynamic>[].obs;
  final orderFilter = 'NEW'.obs; // NEW, ACTIVE, DONE

  // Inventory
  final inventory = <dynamic>[].obs;
  final inventoryStats = {
    'all': 0,
    'inStock': 0,
    'lowStock': 0,
    'outOfStock': 0
  }.obs;
  final inventoryFilter = 'ALL'.obs;

  // Analytics
  final weeklyRevenue = <dynamic>[].obs;
  final orderTypeSplit = <dynamic>[].obs;

  // Specials & Stories
  final specials = <dynamic>[].obs;
  final broadcastController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initData();
    _setupSocketListeners();
  }

  void _initData() async {
    await fetchMyShop();
    fetchDashboardStats();
    fetchOrders();
    fetchInventoryStats();
    fetchInventory();
    fetchAnalytics();
    fetchSpecials();
  }

  void _setupSocketListeners() {
    _socketService.on('new_order', _handleNewOrder);
    _socketService.on('rider_assigned', _handleRiderAssigned);
    _socketService.on('product_created', _handleInventoryChange);
    _socketService.on('product_updated', _handleInventoryChange);
    _socketService.on('product_deleted', _handleInventoryChange);
    _socketService.on('special_created', _handleSpecialChange);
    _socketService.on('special_updated', _handleSpecialChange);
    _socketService.on('special_deleted', _handleSpecialChange);
  }

  void _handleNewOrder(dynamic data) {
      Get.snackbar('New Order', 'You have received a new order!');
      fetchDashboardStats();
      if (orderFilter.value == 'NEW') fetchOrders();
  }

  void _handleRiderAssigned(dynamic data) {
    Get.snackbar('Rider Assigned', 'A rider has been assigned to order #${data['orderNumber'] ?? ''}');
    fetchOrders();
  }

  void _handleInventoryChange(dynamic data) {
    fetchInventory();
    fetchInventoryStats();
  }

  void _handleSpecialChange(dynamic data) {
    fetchSpecials();
  }

  Future<void> fetchMyShop() async {
    try {
      final response = await _apiService.get('${ApiConstants.shops}/my-shop');
      if (response.statusCode == 200) {
        shopName.value = response.data['shopName'];
        shopId.value = response.data['_id'];
        isDeliveryOn.value = response.data['deliveryEnabled'];
        _socketService.joinShop(shopId.value);
      }
    } catch (e) {
        debugPrint('Error fetching shop: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final response = await _apiService.get('${ApiConstants.shops}/dashboard-stats');
      if (response.statusCode == 200) {
        todayRevenue.value = (response.data['todayRevenue'] ?? 0).toDouble();
        totalOrders.value = response.data['totalOrders'] ?? 0;
        pendingOrders.value = response.data['pendingOrders'] ?? 0;
        shopRating.value = (response.data['rating'] ?? 0.0).toDouble();
        reviewCount.value = response.data['reviewCount'] ?? 0;
      }
    } catch (e) {
        debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> fetchOrders() async {
    try {
      final response = await _apiService.get('${ApiConstants.orders}/shop', queryParameters: {'status': orderFilter.value});
      if (response.statusCode == 200) {
        orders.assignAll(response.data);
      }
    } catch (e) {
        debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> fetchInventory() async {
    try {
      final response = await _apiService.get('${ApiConstants.products}/my-products', queryParameters: {'filter': inventoryFilter.value});
      if (response.statusCode == 200) {
        inventory.assignAll(response.data);
      }
    } catch (e) {
        debugPrint('Error fetching inventory: $e');
    }
  }

  Future<void> fetchInventoryStats() async {
    try {
      final response = await _apiService.get('${ApiConstants.products}/inventory-stats');
      if (response.statusCode == 200) {
        inventoryStats.value = {
          'all': response.data['allCount'],
          'inStock': response.data['inStock'],
          'lowStock': response.data['lowStock'],
          'outOfStock': response.data['outOfStock'],
        };
      }
    } catch (e) {
        debugPrint('Error fetching inventory stats: $e');
    }
  }

  Future<void> fetchAnalytics() async {
    try {
      final response = await _apiService.get('${ApiConstants.shops}/analytics');
      if (response.statusCode == 200) {
        weeklyRevenue.assignAll(response.data['weeklyRevenue']);
        orderTypeSplit.assignAll(response.data['orderDistribution']);
      }
    } catch (e) {
        debugPrint('Error fetching analytics: $e');
    }
  }

  Future<void> fetchSpecials() async {
    try {
      final response = await _apiService.get('${ApiConstants.specials}/my');
      if (response.statusCode == 200) {
        specials.assignAll(response.data);
      }
    } catch (e) {
        debugPrint('Error fetching specials: $e');
    }
  }

  void broadcastMessage() async {
    if (broadcastController.text.isEmpty) return;

    try {
      final response = await _apiService.post('${ApiConstants.shops}/broadcast', {
        'message': broadcastController.text
      });
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Broadcast sent successfully');
        broadcastController.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send broadcast');
    }
  }

  void deleteProduct(String id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.products}/$id');
      if (response.statusCode == 200) {
        fetchInventory();
        fetchInventoryStats();
        Get.snackbar('Success', 'Product deleted');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product');
    }
  }

  void restockProduct(String id, int quantity) async {
    try {
      final response = await _apiService.put('${ApiConstants.products}/$id', {
        'stockQuantity': quantity,
        'isAvailable': true
      });
      if (response.statusCode == 200) {
        fetchInventory();
        fetchInventoryStats();
        Get.snackbar('Success', 'Inventory updated');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update stock');
    }
  }

  void toggleDelivery(bool val) async {
    try {
      final response = await _apiService.put('${ApiConstants.shops}/toggle-delivery', {
        'shopId': shopId.value,
        'status': val
      });
      if (response.statusCode == 200) {
        isDeliveryOn.value = val;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update delivery status');
    }
  }

  void updateOrderStatus(String id, String status) async {
    try {
      final response = await _apiService.put('${ApiConstants.orders}/$id/status', {'status': status});
      if (response.statusCode == 200) {
        fetchOrders();
        fetchDashboardStats();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order status');
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 0) fetchDashboardStats();
    if (index == 1) fetchOrders();
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      debugPrint('Merchant logout request failed: $e');
    }
    // Clear cached user data
    Get.find<UserService>().clear();
    Get.find<StorageService>().clearAll();
    Get.offAllNamed(Routes.AUTH);
  }

  void setOrderFilter(String filter) {
    orderFilter.value = filter;
    fetchOrders();
  }

  @override
  void onClose() {
    _socketService.socket?.off('new_order', _handleNewOrder);
    _socketService.socket?.off('product_created', _handleInventoryChange);
    _socketService.socket?.off('product_updated', _handleInventoryChange);
    _socketService.socket?.off('product_deleted', _handleInventoryChange);
    _socketService.socket?.off('special_created', _handleSpecialChange);
    _socketService.socket?.off('special_updated', _handleSpecialChange);
    _socketService.socket?.off('special_deleted', _handleSpecialChange);
    broadcastController.dispose();
    super.onClose();
  }
}
