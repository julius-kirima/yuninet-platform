import 'package:flutter/material.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Loan Application")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Loan Forms"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/loan_forms");
            },
          ),
        ],
      ),
    );
  }
}
