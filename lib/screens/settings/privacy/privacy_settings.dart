import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: const Center(
        child: Text(
          'Manage your privacy preferences here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
