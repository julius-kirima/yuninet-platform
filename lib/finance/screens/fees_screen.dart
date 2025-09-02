import 'package:flutter/material.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  Widget buildStubButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    Color color = Colors.blue,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color.shade700,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fees"),
        elevation: 2,
      ),
      body: ListView(
        children: [
          buildStubButton(
            context: context,
            title: "Fee Summary",
            icon: Icons.receipt_long,
            route: "/fee_summary",
            color: Colors.blue,
          ),
          buildStubButton(
            context: context,
            title: "Fee Statement",
            icon: Icons.description,
            route: "/fee_statement",
            color: Colors.green,
          ),
          buildStubButton(
            context: context,
            title: "Fee Structure",
            icon: Icons.account_balance_wallet,
            route: "/fee_structure",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

extension on Color {
  get shade700 => null;
}
