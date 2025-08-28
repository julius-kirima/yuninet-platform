import 'package:flutter/material.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = [
      {"title": "Official Announcements Section"},
      {"title": "Student Polls/Surveys"},
      {"title": "Peer-to-Peer Tutoring"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Communication & Engagement")),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(feature["title"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("${feature["title"]} Module Coming Soon 🚀")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
