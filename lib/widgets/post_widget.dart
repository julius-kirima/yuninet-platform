import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  void showLikeNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'Channel for like notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Like!',
      'Someone liked your post ??',
      notificationDetails,
    );
  }
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
