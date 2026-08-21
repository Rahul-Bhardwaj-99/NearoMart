import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/services/notification_service.dart';
import '../routes/app_pages.dart';
import '../routes/arguments/arguments.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    initNotifications();
  }

  Future<void> initNotifications() async {
    // 1. Request Permission
    final settings = await _notificationService.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      // 2. Fetch FCM Token
      await _notificationService.getToken();

      // 3. Handle Foreground Messages (When app is active)
      _notificationService.foregroundMessages.listen((message) {

        // You can display a GetX Snackbar when a notification arrives in foreground!
        if (message.notification != null) {
          Get.snackbar(
            message.notification!.title ?? 'Notification',
            message.notification!.body ?? '',
            snackPosition: SnackPosition.TOP,
          );
        }
      });

      // 4. Handle Notification Tap (When app is in background)
      _notificationService.openedMessages.listen((message) {
        _handleNotificationTap(message);
      });
    } else {
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString();
    final id = data['id']?.toString() ?? data['orderId']?.toString();

    if (type == null || id == null) return;

    switch (type) {
      case 'ORDER':
      case 'ORDER_STATUS':
        Get.toNamed(Routes.ORDER_TRACKING, arguments: OrderArguments.fromId(id));
        break;
      case 'CHAT':
      case 'CHAT_MESSAGE':
        Get.toNamed(Routes.CHAT_DETAIL, arguments: ChatArguments.fromId(id));
        break;
      case 'SHOP':
        Get.toNamed(Routes.SHOP_DETAIL, arguments: ShopArguments.fromId(id));
        break;
      default:
        break;
    }
  }
}
