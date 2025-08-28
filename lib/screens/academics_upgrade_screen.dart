import 'package:flutter/material.dart';

class AcademicsUpgradeScreen extends StatelessWidget {
  const AcademicsUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = [
      {"title": "Lecture Materials Repository"},
      {"title": "Group Projects/Collaboration Tool"},
      {"title": "Library Integration"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Academics Upgrade")),
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
