import 'package:flutter/material.dart';

class AcademicsDashboardScreen extends StatelessWidget {
  const AcademicsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: const Center(child: Text("Academics Dashboard Screen")),
    );
  }
}
