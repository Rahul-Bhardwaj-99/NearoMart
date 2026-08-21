import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'profile_service.dart';
import 'storage_service.dart';

class UserService extends GetxService {
  final ProfileService _profileService = Get.find<ProfileService>();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  bool _hasLoadedProfile = false;

  @override
  void onInit() {
    super.onInit();
    // Session-aware: only fetch profile if a token exists (i.e., authenticated).
    final hasToken = Get.find<StorageService>().getToken()?.isNotEmpty ?? false;
    if (hasToken) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile({bool force = false}) async {
    if (_hasLoadedProfile && !force) return;

    try {
      isLoading.value = true;
      final profile = await _profileService.getProfile();
      currentUser.value = UserModel.fromJson(profile);
      _hasLoadedProfile = true;
    } catch (e) {
      debugPrint('UserService: Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateUserData(UserModel user) {
    currentUser.value = user;
  }

  Future<void> refreshProfile() => fetchProfile(force: true);

  /// Clear user session when logging out
  void clear() {
    currentUser.value = null;
    _hasLoadedProfile = false;
  }

  bool get isBuyer => currentUser.value?.role == 'BUYER';
  bool get isMerchant => currentUser.value?.role == 'MERCHANT';
  bool get isRider => currentUser.value?.role == 'RIDER';

  String get userNameInitial {
    final name = currentUser.value?.name;
    if (name == null || name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }
}
