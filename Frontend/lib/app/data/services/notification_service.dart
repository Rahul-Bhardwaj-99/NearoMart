import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<RemoteMessage> get foregroundMessages => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get openedMessages => FirebaseMessaging.onMessageOpenedApp;
}
