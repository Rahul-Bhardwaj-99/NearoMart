import 'package:get/get.dart';
import '../../core/values/api_constants.dart';
import 'api_service.dart';

class ProfileService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get(ApiConstants.profile);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(ApiConstants.updateProfile, data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateRole(String role) async {
    final response = await _apiService.put(ApiConstants.updateRole, {'role': role});
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> completeOnboarding(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.put(
      ApiConstants.completeOnboarding,
      data,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
