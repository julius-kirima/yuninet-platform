import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

/// Starts listening for new notifications from Supabase in real-time
void startNotificationListener() {
  final supabase = Supabase.instance.client;
  final notificationService = NotificationService();

  supabase
      .channel('public:notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        callback: (payload) {
          try {
            final data = payload.newRecord;

            final title = data['title'] ?? 'New Notification';
            final body = data['body'] ?? '';

            // Show local notification
            notificationService.showNotification(title, body);
          } catch (e) {
            print("❌ Error parsing notification payload: $e");
          }
        },
      )
      .subscribe();

  print("📡 Real-time notifications listener started...");
}
