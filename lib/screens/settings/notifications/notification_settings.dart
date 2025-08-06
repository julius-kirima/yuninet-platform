import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: const Center(
        child: Text(
          'Set how you receive notifications.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
