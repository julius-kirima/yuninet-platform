import 'package:flutter/material.dart';

class AnswerQuestionScreen extends StatelessWidget {
  const AnswerQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Answer Question")),
      body: const Center(child: Text("Answer Question Screen")),
    );
  }
}
