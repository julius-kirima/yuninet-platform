import 'package:flutter/material.dart';

class FinanceOpportunitiesScreen extends StatelessWidget {
  const FinanceOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = [
      {"title": "Scholarships & Bursaries Updates"},
      {"title": "Part-time Jobs & Attachments Board"},
      {"title": "Expense Tracker (inside Wallet)"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Finance & Opportunities")),
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
