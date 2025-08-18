import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

/// Starts listening for new notifications from Supabase in real-time
void startNotificationListener() {
  final supabase = Supabase.instance.client;
  final notificationService = NotificationService();

  try {
    if (kIsWeb) {
      // Web: use Supabase stream() for real-time updates
      supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((notifications) async {
            for (final notif in notifications) {
              final type = notif['type'] as String? ?? '';
              final enabled = await notificationService.getUserPreference(type);
              if (!enabled) continue;

              final title = notif['title'] ?? 'New Notification';
              final body = notif['body'] ?? '';
              final id = notif['id'] as int? ?? 0;

              await notificationService.showNotification(title, body, id: id);
            }
          });
      debugPrint("📡 Real-time notifications listener started on Web.");
    } else {
      // Mobile: use Supabase channels with Postgres changes
      final channel = supabase.channel('public:notifications');

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            callback: (payload) async {
              try {
                final data = payload.newRecord;
                final title = data['title'] ?? 'New Notification';
                final body = data['body'] ?? '';
                final type = data['type'] ?? '';

                final enabled =
                    await notificationService.getUserPreference(type);
                if (!enabled) return;

                await notificationService.showNotification(
                  title,
                  body,
                  id: data['id'] as int? ?? 0,
                );
              } catch (e) {
                debugPrint("❌ Error parsing notification payload: $e");
              }
            },
          )
          .subscribe();
      debugPrint("📡 Real-time notifications listener started on Mobile.");
    }
  } catch (e) {
    debugPrint("❌ Failed to start real-time notifications listener: $e");
  }
}
