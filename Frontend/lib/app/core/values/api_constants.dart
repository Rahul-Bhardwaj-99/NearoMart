import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.nearomart.com/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }

    return 'http://localhost:5000/api';
  }

  static const String verifyOtp = '/auth/verify-otp';
  static const String profile = '/auth/profile';
  static const String updateRole = '/auth/update-role';
  static const String completeOnboarding = '/auth/complete-onboarding';
  static const String updateProfile = '/auth/update-profile';
  static const String addresses = '/auth/addresses';
  static const String shops = '/shops';
  static const String categories = '/categories';
  static const String banners = '/banners';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String availableDeliveries = '/orders/available-deliveries';
  static const String myDeliveries = '/orders/my-deliveries';
  static const String riderAvailability = '/orders/rider/availability';
  static const String specials = '/specials';
  static const String chats = '/chats';
  static String chat(String chatId) => '$chats/$chatId';
  static String chatRead(String chatId) => '${chat(chatId)}/read';
  static String endChat(String chatId) => '${chat(chatId)}/end';
}
