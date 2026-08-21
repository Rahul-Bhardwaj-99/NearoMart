part of 'app_pages.dart';

// ignore_for_file: constant_identifier_names

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const ROLE_SELECTION = _Paths.ROLE_SELECTION;
  static const ADDRESS_SETUP = _Paths.ADDRESS_SETUP;
  static const SEARCH_COMPARISON = _Paths.SEARCH_COMPARISON;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const ORDER_SUCCESS = _Paths.ORDER_SUCCESS;
  static const ORDER_TRACKING = _Paths.ORDER_TRACKING;
  static const HOME = _Paths.HOME;
  static const SHOP_DETAIL = _Paths.SHOP_DETAIL;
  static const CART = _Paths.CART;
  static const MERCHANT_DASHBOARD = _Paths.MERCHANT_DASHBOARD;
  static const MERCHANT_KYC = _Paths.MERCHANT_KYC;
  static const MERCHANT_ADD_PRODUCT = _Paths.MERCHANT_ADD_PRODUCT;
  static const MERCHANT_MARKETING = _Paths.MERCHANT_MARKETING;
  static const RIDER_DASHBOARD = _Paths.RIDER_DASHBOARD;
  static const RIDER_DISPATCH = _Paths.RIDER_DISPATCH;
  static const RIDER_NAVIGATION = _Paths.RIDER_NAVIGATION;
  static const RIDER_OTP = _Paths.RIDER_OTP;
  static const CHAT = _Paths.CHAT;
  static const CHAT_DETAIL = _Paths.CHAT_DETAIL;
  static const DISCOVER = _Paths.DISCOVER;
  static const ORDERS = _Paths.ORDERS;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const SAVED_ADDRESSES = _Paths.SAVED_ADDRESSES;
  static const CHAT_LIST = _Paths.CHAT_LIST;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const ROLE_SELECTION = '/role-selection';
  static const ADDRESS_SETUP = '/address-setup';
  static const SEARCH_COMPARISON = '/search-comparison';
  static const PRODUCT_DETAIL = '/product-detail';
  static const ORDER_SUCCESS = '/order-success';
  static const ORDER_TRACKING = '/order-tracking';
  static const HOME = '/home';
  static const SHOP_DETAIL = '/shop-detail';
  static const CART = '/cart';
  static const MERCHANT_DASHBOARD = '/merchant-dashboard';
  static const MERCHANT_KYC = '/merchant-kyc';
  static const MERCHANT_ADD_PRODUCT = '/merchant-add-product';
  static const MERCHANT_MARKETING = '/merchant-marketing';
  static const RIDER_DASHBOARD = '/rider-dashboard';
  static const RIDER_DISPATCH = '/rider-dispatch';
  static const RIDER_NAVIGATION = '/rider-navigation';
  static const RIDER_OTP = '/rider-otp';
  static const CHAT = '/chat';
  static const CHAT_DETAIL = '/chat-detail';
  static const DISCOVER = '/discover';
  static const ORDERS = '/orders';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const SAVED_ADDRESSES = '/saved-addresses';
  static const CHAT_LIST = '/chat-list';
}
