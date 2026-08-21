import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nearomart/app/data/services/api_service.dart';
import 'package:nearomart/app/data/services/profile_service.dart';
import 'package:nearomart/app/data/services/storage_service.dart';
import 'package:nearomart/app/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileService extends ProfileService {
  int callCount = 0;
  Map<String, dynamic> profile = {
    '_id': 'user-1',
    'name': 'Test User',
    'phone': '1234567890',
    'role': 'BUYER',
  };

  @override
  Future<Map<String, dynamic>> getProfile() async {
    callCount++;
    return profile;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileService mockProfile;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(await StorageService().init());
    Get.put(ApiService());
    mockProfile = MockProfileService();
    Get.put<ProfileService>(mockProfile);
  });

  tearDown(() {
    Get.reset();
  });

  group('UserService cache and refresh', () {
    test('fetchProfile loads profile once and caches it', () async {
      final userService = Get.put(UserService());

      await userService.fetchProfile();
      expect(userService.currentUser.value?.id, 'user-1');
      expect(mockProfile.callCount, 1);

      // Second call without force should use cache
      await userService.fetchProfile();
      expect(mockProfile.callCount, 1);
    });

    test('refreshProfile forces a reload', () async {
      final userService = Get.put(UserService());

      await userService.fetchProfile();
      expect(mockProfile.callCount, 1);

      await userService.refreshProfile();
      expect(mockProfile.callCount, 2);
    });

    test('clear resets currentUser and cache flag', () async {
      final userService = Get.put(UserService());

      await userService.fetchProfile();
      expect(userService.currentUser.value, isNotNull);

      userService.clear();
      expect(userService.currentUser.value, isNull);

      // After clear, fetchProfile should reload
      await userService.fetchProfile();
      expect(mockProfile.callCount, 2);
    });

    test('onInit does not fetch profile when no token exists', () async {
      // No token in storage
      final userService = Get.put(UserService());

      // onInit is called by Get.put
      expect(userService.currentUser.value, isNull);
      expect(mockProfile.callCount, 0);
    });

    test('onInit fetches profile when token exists', () async {
      final storage = Get.find<StorageService>();
      await storage.saveToken('test-token');

      final userService = Get.put(UserService());

      // onInit is called by Get.put, but fetchProfile is async.
      // Allow the async fetch to complete.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(userService.currentUser.value?.id, 'user-1');
      expect(mockProfile.callCount, 1);
    });
  });
}