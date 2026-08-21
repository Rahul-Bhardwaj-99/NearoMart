import 'package:get/get.dart';
import '../../core/values/api_constants.dart';
import 'api_service.dart';

class OrderService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<dynamic> _cachedOrders = <dynamic>[].obs;
  bool _hasLoadedOrders = false;

  /// Get cached orders or fetch if not cached
  Future<List<dynamic>> getMyOrders({bool force = false}) async {
    if (_hasLoadedOrders && !force) {
      return _cachedOrders;
    }

    try {
      final response = await _apiService.get('${ApiConstants.orders}/my');
      final orders = List<dynamic>.from(response.data as List);
      _cachedOrders.assignAll(orders);
      _hasLoadedOrders = true;
      return orders;
    } catch (e) {
      rethrow;
    }
  }

  /// Force refresh orders from API
  Future<List<dynamic>> refreshOrders() => getMyOrders(force: true);

  /// Clear cached orders
  void clear() {
    _cachedOrders.clear();
    _hasLoadedOrders = false;
  }
}
