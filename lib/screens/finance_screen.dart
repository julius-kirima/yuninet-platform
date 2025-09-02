import 'package:flutter/material.dart';

/// 🔹 Finance Main Screen
class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        "title": "Fees",
        "icon": Icons.school,
        "color": Colors.blue,
        "page": const FeesScreen(),
      },
      {
        "title": "eCitizen Payments & Initiation",
        "icon": Icons.account_balance,
        "color": Colors.orange,
        "page": const ECitizenScreen(),
      },
      {
        "title": "Student Loan Application",
        "icon": Icons.request_page,
        "color": Colors.purple,
        "page": const LoanApplicationScreen(),
      },
      {
        "title": "Wallet",
        "icon": Icons.account_balance_wallet,
        "color": Colors.green,
        "page": const WalletScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance"),
        backgroundColor: Colors.green.shade700,
      ),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: feature["color"].withOpacity(0.2),
                child: Icon(
                  feature["icon"],
                  color: feature["color"],
                ),
              ),
              title: Text(
                feature["title"],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

/// 🔹 Fees Screen with Sub-Modules
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subFeatures = [
      {
        "title": "Fee Summary",
        "page": const _StubPage(title: "Fee Summary"),
      },
      {
        "title": "Fee Statement",
        "page": const _StubPage(title: "Fee Statement"),
      },
      {
        "title": "Fee Structure",
        "page": const _StubPage(title: "Fee Structure"),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fees"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: subFeatures.length,
        itemBuilder: (context, index) {
          final feature = subFeatures[index];
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

/// 🔹 eCitizen Screen with Sub-Modules
class ECitizenScreen extends StatelessWidget {
  const ECitizenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subFeatures = [
      {
        "title": "Initiate eCitizen Payment",
        "page": const _StubPage(title: "Initiate eCitizen Payment"),
      },
      {
        "title": "eCitizen Payment History",
        "page": const _StubPage(title: "eCitizen Payment History"),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("eCitizen Payments"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: subFeatures.length,
        itemBuilder: (context, index) {
          final feature = subFeatures[index];
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

/// 🔹 Loan Application Screen
class LoanApplicationScreen extends StatelessWidget {
  const LoanApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StubPage(title: "Student Loan Application (Loan Forms)");
  }
}

/// 🔹 Wallet Screen
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StubPage(title: "Wallet Module");
  }
}

/// 🔹 Reusable Stub Page
class _StubPage extends StatelessWidget {
  final String title;

  const _StubPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green.shade700,
      ),
      body: Center(
        child: Text(
          "$title Coming Soon 🚀",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
