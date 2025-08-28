import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Assignments")),
      body: const Center(child: Text("Assignments Screen")),
    );
  }
}
