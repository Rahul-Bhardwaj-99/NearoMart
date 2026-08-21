import 'package:get/get.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/role_selection/views/role_selection_view.dart';
import '../modules/home/views/address_setup_view.dart';
import '../modules/home/views/search_comparison_view.dart';
import '../modules/home/views/product_detail_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/cart/views/order_success_view.dart';
import '../modules/cart/views/order_tracking_view.dart';
import '../modules/shop_detail/views/shop_detail_view.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/merchant_dashboard/views/merchant_dashboard_view.dart';
import '../modules/merchant_dashboard/views/shop_kyc_view.dart';
import '../modules/merchant_dashboard/views/add_product_view.dart';
import '../modules/merchant_dashboard/views/marketing_view.dart';
import '../modules/delivery_agent/views/rider_dashboard_view.dart';
import '../modules/delivery_agent/views/rider_dispatch_view.dart';
import '../modules/delivery_agent/views/rider_navigation_view.dart';
import '../modules/delivery_agent/views/rider_otp_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat_list/views/chat_list_view.dart';
import '../modules/chat_list/bindings/chat_list_binding.dart';
import '../modules/discover/views/discover_view.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/edit/views/edit_profile_view.dart';
import '../modules/saved_addresses/views/saved_addresses_view.dart';
import '../modules/saved_addresses/bindings/saved_addresses_binding.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/role_selection/bindings/role_selection_binding.dart';
import '../modules/home/bindings/address_setup_binding.dart';
import '../modules/home/bindings/product_detail_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/shop_detail/bindings/shop_detail_binding.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/merchant_dashboard/bindings/merchant_dashboard_binding.dart';
import '../modules/merchant_dashboard/bindings/shop_kyc_binding.dart';
import '../modules/delivery_agent/bindings/rider_dashboard_binding.dart';
import '../modules/home/bindings/search_comparison_binding.dart';
import '../modules/discover/bindings/discover_binding.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/edit/bindings/edit_profile_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: _Paths.AUTH, page: () => AuthView(), binding: AuthBinding()),
    GetPage(
      name: _Paths.ROLE_SELECTION,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: _Paths.ADDRESS_SETUP,
      page: () => const AddressSetupView(),
      binding: AddressSetupBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_COMPARISON,
      page: () => const SearchComparisonView(),
      binding: SearchComparisonBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SHOP_DETAIL,
      page: () => const ShopDetailView(),
      binding: ShopDetailBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(name: _Paths.ORDER_SUCCESS, page: () => const OrderSuccessView()),
    GetPage(name: _Paths.ORDER_TRACKING, page: () => const OrderTrackingView()),
    GetPage(
      name: _Paths.MERCHANT_DASHBOARD,
      page: () => const MerchantDashboardView(),
      binding: MerchantDashboardBinding(),
    ),
    GetPage(
      name: _Paths.MERCHANT_KYC,
      page: () => const ShopKycView(),
      binding: ShopKycBinding(),
    ),
    GetPage(
      name: _Paths.MERCHANT_ADD_PRODUCT,
      page: () => const AddProductView(),
    ),
    GetPage(name: _Paths.MERCHANT_MARKETING, page: () => const MarketingView()),
    GetPage(
      name: _Paths.RIDER_DASHBOARD,
      page: () => const RiderDashboardView(),
      binding: RiderDashboardBinding(),
    ),
    GetPage(name: _Paths.RIDER_DISPATCH, page: () => const RiderDispatchView()),
    GetPage(
      name: _Paths.RIDER_NAVIGATION,
      page: () => const RiderNavigationView(),
    ),
    GetPage(
      name: _Paths.RIDER_OTP,
      page: () => const RiderOtpView(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatListView(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_DETAIL,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.DISCOVER,
      page: () => const DiscoverView(),
      binding: DiscoverBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.SAVED_ADDRESSES,
      page: () => const SavedAddressesView(),
      binding: SavedAddressesBinding(),
    ),
  ];
}
