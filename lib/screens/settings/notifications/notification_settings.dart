import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final supabase = Supabase.instance.client;

  // General notification settings
  bool pushEnabled = true;
  bool emailEnabled = false;
  bool chatNotifications = true;
  bool postNotifications = true;

  // Social notification settings
  bool likeNotifications = true;
  bool followNotifications = true;
  bool unfollowNotifications = false;
  bool shareNotifications = true;
  bool commentNotifications = true;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  /// Fetch current user's notification settings from Supabase
  Future<void> _fetchSettings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        pushEnabled = response['push'] ?? true;
        emailEnabled = response['email'] ?? false;
        chatNotifications = response['chat'] ?? true;
        postNotifications = response['post'] ?? true;
        likeNotifications = response['like'] ?? true;
        followNotifications = response['follow'] ?? true;
        unfollowNotifications = response['unfollow'] ?? false;
        shareNotifications = response['share'] ?? true;
        commentNotifications = response['comment'] ?? true;
      });
    }

    setState(() {
      _loading = false;
    });
  }

  /// Save the current settings to Supabase
  Future<void> _saveSettings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = {
      'user_id': userId,
      'push': pushEnabled,
      'email': emailEnabled,
      'chat': chatNotifications,
      'post': postNotifications,
      'like': likeNotifications,
      'follow': followNotifications,
      'unfollow': unfollowNotifications,
      'share': shareNotifications,
      'comment': commentNotifications,
    };

    // Upsert (insert or update) preferences
    await supabase.from('notification_preferences').upsert(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification settings saved ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Choose how you want to receive notifications:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          // General Notifications
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive alerts on your device"),
            value: pushEnabled,
            onChanged: (value) => setState(() => pushEnabled = value),
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            subtitle: const Text("Receive important updates via email"),
            value: emailEnabled,
            onChanged: (value) => setState(() => emailEnabled = value),
          ),

          const Divider(),

          // Activity Notifications
          SwitchListTile(
            title: const Text("Chat Messages"),
            subtitle: const Text("Be notified of new chat messages"),
            value: chatNotifications,
            onChanged: (value) => setState(() => chatNotifications = value),
          ),
          SwitchListTile(
            title: const Text("Post Interactions"),
            subtitle:
                const Text("Get notified about likes & comments on your posts"),
            value: postNotifications,
            onChanged: (value) => setState(() => postNotifications = value),
          ),

          const Divider(),

          // Social Notifications
          const Text(
            "Social Notifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text("Likes"),
            subtitle: const Text("When someone likes your posts"),
            value: likeNotifications,
            onChanged: (value) => setState(() => likeNotifications = value),
          ),
          SwitchListTile(
            title: const Text("Follows"),
            subtitle: const Text("When someone follows you"),
            value: followNotifications,
            onChanged: (value) => setState(() => followNotifications = value),
          ),
          SwitchListTile(
            title: const Text("Unfollows"),
            subtitle: const Text("When someone unfollows you"),
            value: unfollowNotifications,
            onChanged: (value) => setState(() => unfollowNotifications = value),
          ),
          SwitchListTile(
            title: const Text("Shares"),
            subtitle: const Text("When someone shares your posts"),
            value: shareNotifications,
            onChanged: (value) => setState(() => shareNotifications = value),
          ),
          SwitchListTile(
            title: const Text("Comments"),
            subtitle: const Text("When someone comments on your posts"),
            value: commentNotifications,
            onChanged: (value) => setState(() => commentNotifications = value),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Settings"),
            onPressed: _saveSettings,
          ),
        ],
      ),
    );
  }
}
