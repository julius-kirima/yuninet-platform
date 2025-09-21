import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yuninet_app/screens/settings/widgets/setting_tile.dart';
import 'package:yuninet_app/routes/app_routes.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _requestAccountInfo(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ You must be logged in')),
        );
        return;
      }

      // Build account info JSON
      final accountInfo = {
        'id': user.id,
        'email': user.email,
        'phone': user.phone,
        'created_at': user.createdAt,
        'app_metadata': user.appMetadata,
        'user_metadata': user.userMetadata,
      };

      // Save file locally
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/account_info_${user.id}.json');
      await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(accountInfo));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📄 Account info saved at: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Not logged in')),
        );
        return;
      }

      // Delete user from Supabase (requires service role normally)
      await _supabase.auth.signOut();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Account Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📧 Change Email
          SettingTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changeEmail);
            },
          ),
          const SizedBox(height: 10),

          // 🔐 Two-Factor Authentication
          SettingTile(
            icon: Icons.lock_outline,
            title: 'Enable 2FA (Two-Factor Authentication)',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.twoFactorSetup);
            },
          ),
          const SizedBox(height: 10),

          // 📱 Change Phone Number
          SettingTile(
            icon: Icons.phone_android,
            title: 'Change Phone Number',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.changePhone);
            },
          ),
          const SizedBox(height: 10),

          // 📥 Request Account Info
          SettingTile(
            icon: Icons.download_outlined,
            title: 'Request Account Info',
            onTap: () => _requestAccountInfo(context),
          ),
          const SizedBox(height: 10),

          // 🗑️ Delete Account
          SettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                      'Are you sure you want to delete your account? This action is irreversible.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // close dialog
                        await _deleteAccount(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
