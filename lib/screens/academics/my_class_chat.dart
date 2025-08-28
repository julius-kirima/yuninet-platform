import 'package:flutter/material.dart';

class MyClassChatScreen extends StatelessWidget {
  const MyClassChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Class Chat")),
      body: const Center(child: Text("My Class Chat Screen")),
    );
  }
}
