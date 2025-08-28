import 'package:flutter/material.dart';

class ExamCardScreen extends StatelessWidget {
  const ExamCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exam Card")),
      body: const Center(child: Text("Exam Card Screen")),
    );
  }
}
