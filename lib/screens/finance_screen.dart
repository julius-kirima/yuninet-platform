import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        "title": "Fees",
        "page": const FeesScreen(),
      },
      {
        "title": "eCitizen Payments & Initiation",
        "page": const ECitizenScreen(),
      },
      {
        "title": "Student Loan Application",
        "page": const LoanApplicationScreen(),
      },
      {
        "title": "Wallet",
        "page": const WalletScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              title: Text(feature["title"]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => feature["page"]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// 🔹 Stub screens
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StubPage(title: "Fees Module");
  }
}

class ECitizenScreen extends StatelessWidget {
  const ECitizenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StubPage(title: "eCitizen Payments Module");
  }
}

class LoanApplicationScreen extends StatelessWidget {
  const LoanApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StubPage(title: "Student Loan Application Module");
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StubPage(title: "Wallet Module");
  }
}

// 🔹 Generic stub page
class _StubPage extends StatelessWidget {
  final String title;

  const _StubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "$title Coming Soon 🚀",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
