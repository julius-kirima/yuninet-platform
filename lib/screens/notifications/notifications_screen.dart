import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yuninet_app/routes/app_routes.dart';

/// Model class for notifications
class AppNotification {
  final int id;
  final String type; // like, comment, share, follow, unfollow, post, profile
  final String title;
  final String body;
  final DateTime createdAt;
  final String? targetId; // ✅ added for navigation

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.targetId,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as int,
      type: map['type'] as String,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      targetId: map['target_id']?.toString(),
    );
  }

  IconData get icon {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'share':
        return Icons.share;
      case 'follow':
        return Icons.person_add;
      case 'unfollow':
        return Icons.person_remove;
      case 'post':
        return Icons.article;
      case 'profile':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return DateFormat('yMMMd').format(createdAt);
  }
}

/// Notifications screen UI with Supabase integration and settings
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _notificationsStream;
  Map<String, bool> _userPreferences = {};
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences();

    // Stream notifications in real time from Supabase
    _notificationsStream = supabase
        .from('notifications')
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  /// Fetch user's notification preferences
  Future<void> _fetchUserPreferences() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final prefs = await supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (prefs != null) {
        setState(() {
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
        });
      }
    } catch (e) {
      debugPrint("Error fetching notification preferences: $e");
    }

    setState(() {
      _loadingPrefs = false;
    });
  }

  /// Check if a notification type is enabled
  bool _isEnabled(String type) {
    if (_userPreferences.isEmpty) return true;
    return _userPreferences[type] ?? true;
  }

  /// ✅ Handle navigation based on type
  void _handleNotificationTap(AppNotification notif) {
    switch (notif.type) {
      case 'post':
        if (notif.targetId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.postDetail,
            arguments: notif.targetId,
          );
        }
        break;

      case 'comment':
        if (notif.targetId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.comments,
            arguments: notif.targetId,
          );
        }
        break;

      case 'profile':
      case 'follow':
      case 'unfollow':
        if (notif.targetId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.profile,
            arguments: notif.targetId,
          );
        }
        break;

      case 'chat':
        // You can add your chat route here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chat screen not yet implemented")),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unknown notification type: ${notif.type}")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet 👀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final notifications = snapshot.data!
              .map((map) => AppNotification.fromMap(map))
              .where((notif) => _isEnabled(notif.type))
              .toList();

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'All notifications are disabled in your settings.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final notif = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child:
                      Icon(notif.icon, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  notif.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${notif.body} • ${notif.timeAgo}"),
                onTap: () => _handleNotificationTap(notif),
              );
            },
          );
        },
      ),
    );
  }
}
