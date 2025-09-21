import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'account/account_settings.dart';
import 'privacy/privacy_settings.dart';
import 'notifications/notification_settings.dart';
import 'analytics/analytics_screen.dart';
import 'about/about_yuninet_screen.dart';
import 'widgets/setting_tile.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  SupabaseClient get _supabase => Supabase.instance.client;

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Log Out"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.auth.signOut();

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during logout: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SettingTile(
            icon: Icons.person,
            title: "Account Settings",
            onTap: () => _navigate(context, const AccountSettingsScreen()),
          ),
          const SizedBox(height: 16),
          const Text("Privacy & Security",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SettingTile(
            icon: Icons.lock,
            title: "Privacy & Security",
            onTap: () => _navigate(context, const PrivacySettingsScreen()),
          ),
          const SizedBox(height: 16),
          const Text("Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SettingTile(
            icon: Icons.notifications,
            title: "Notification Settings",
            onTap: () => _navigate(context, const NotificationSettingsScreen()),
          ),
          const SizedBox(height: 16),
          const Text("Insights & App Info",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SettingTile(
            icon: Icons.bar_chart,
            title: "Analytics",
            onTap: () => _navigate(context, const AnalyticsScreen()),
          ),
          SettingTile(
            icon: Icons.info_outline,
            title: "About Yuninet",
            onTap: () => _navigate(context, const AboutYuninetScreen()),
          ),
          const SizedBox(height: 24),
          SettingTile(
            icon: Icons.logout,
            title: "Log Out",
            iconColor: Colors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
