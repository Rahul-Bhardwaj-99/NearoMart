import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/notification_controller.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/data/services/cart_service.dart';
import 'app/data/services/location_service.dart';
import 'app/data/services/socket_service.dart';
import 'app/data/services/user_service.dart';
import 'app/data/services/profile_service.dart';
import 'app/data/services/order_service.dart';
import 'app/data/services/chat_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/size_config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => SocketService().init());
  Get.put(ProfileService());
  Get.put(OrderService());
  Get.put(ChatService());
  Get.put(NotificationService());
  Get.put(UserService());
  Get.put(LocationService());
  Get.put(CartService());
  Get.put(NotificationController());
  runApp(
    LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeConfig().init(constraints, orientation);
            return Obx(() {
              final role = Get.find<UserService>().currentUser.value?.role;
              return GetMaterialApp(
                title: "NearoMart",
                initialRoute: AppPages.initial,
                getPages: AppPages.routes,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.getThemeForRole(role),
              );
            });
          },
        );
      },
    ),
  );
}
