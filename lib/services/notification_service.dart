import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final supabase = Supabase.instance.client;

  // User preferences cache
  Map<String, bool> _userPreferences = {};

  /// Initialize local notifications and start listening to Supabase notifications
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Load user preferences
    await fetchUserPreferences();

    // Note: Real-time listening will be handled in your realtime_listener.dart
  }

  /// Request iOS/macOS notification permissions
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Show a local notification
  Future<void> showNotification(
    String title,
    String body, {
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'yuninet_channel_id',
      'Yuninet Notifications',
      channelDescription: 'This channel is used for Yuninet app notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Fetch user preferences from Supabase
  Future<void> fetchUserPreferences() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final prefs = await supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (prefs != null) {
        _userPreferences = {
          'like': prefs['like'] ?? true,
          'comment': prefs['comment'] ?? true,
          'share': prefs['share'] ?? true,
          'follow': prefs['follow'] ?? true,
          'unfollow': prefs['unfollow'] ?? false,
          'chat': prefs['chat'] ?? true,
          'post': prefs['post'] ?? true,
          'push': prefs['push'] ?? true,
          'email': prefs['email'] ?? false,
        };
      }
    } catch (e) {
      _userPreferences = {}; // fallback: all enabled
    }
  }

  /// Public method to get preference for a given notification type
  Future<bool> getUserPreference(String type) async {
    // Refresh preferences from Supabase
    await fetchUserPreferences();
    return _userPreferences[type] ?? true;
  }
}
