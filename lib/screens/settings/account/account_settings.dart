import 'package:flutter/material.dart';
import 'package:yuninet_app/screens/settings/widgets/setting_tile.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () {
              // TODO: Navigate to Change Email Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Email tapped')),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingTile(
            icon: Icons.lock_outline,
            title: 'Enable 2FA (Two-Factor Authentication)',
            onTap: () {
              // TODO: Enable Two-Factor Authentication
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2FA Setup tapped')),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingTile(
            icon: Icons.phone_android,
            title: 'Change Phone Number',
            onTap: () {
              // TODO: Navigate to Change Phone Number Screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Phone Number tapped')),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingTile(
            icon: Icons.download_outlined,
            title: 'Request Account Info',
            onTap: () {
              // TODO: Handle account info request
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account Info Request tapped')),
              );
            },
          ),
          const SizedBox(height: 10),
          SettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: Colors.red,
            onTap: () {
              // TODO: Implement delete account logic
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
                      onPressed: () {
                        // Perform delete logic
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Account Deleted (Simulation)')),
                        );
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
