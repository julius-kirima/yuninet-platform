import 'package:flutter/material.dart';

class TranscriptsScreen extends StatelessWidget {
  const TranscriptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transcripts / Results")),
      body: const Center(child: Text("Transcripts / Results Screen")),
    );
  }
}
