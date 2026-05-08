//lib/core/services/local_notification_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin plugin;
  LocalNotificationService(this.plugin);

  Future<void> showPickupRequest({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const android = AndroidNotificationDetails(
        'pickup_requests',
        'طلبات الاستلام',
        channelDescription: 'إشعارات طلبات الاستلام للمعلمين',
        importance: Importance.max,
        priority: Priority.high,
      );

      const ios = DarwinNotificationDetails();

      const details = NotificationDetails(android: android, iOS: ios);

      await plugin.show(
        id: id, // ✅ named
        title: title, // ✅ named
        body: body, // ✅ named
        notificationDetails: details, // ✅ named
        // payload: 'optional payload',
      );
    } catch (e) {
      debugPrint('❌ LocalNotification error: $e');
    }
  }
}