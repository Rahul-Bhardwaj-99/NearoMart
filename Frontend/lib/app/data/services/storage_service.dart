import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  static const String _tokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _isOnboardedKey = 'is_onboarded';

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveRole(String role) async {
    await _prefs.setString(_userRoleKey, role);
  }

  String? getRole() {
    return _prefs.getString(_userRoleKey);
  }

  Future<void> saveOnboarded(bool status) async {
    await _prefs.setBool(_isOnboardedKey, status);
  }

  bool isOnboarded() {
    return _prefs.getBool(_isOnboardedKey) ?? false;
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
