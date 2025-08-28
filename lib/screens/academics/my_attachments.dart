import 'package:flutter/material.dart';

class AttachmentsScreen extends StatelessWidget {
  const AttachmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Attachments")),
      body: const Center(child: Text("Attachments Screen")),
    );
  }
}
