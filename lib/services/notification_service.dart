import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> showNotification(String title, String body) async {
    var details = NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'Yuninet'),
    );
    await _notifications.show(0, title, body, details);
  }
}
