import 'package:flutter/material.dart';

class ECitizenScreen extends StatelessWidget {
  const ECitizenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eCitizen"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.blue),
            title: const Text("Initiate eCitizen Payment"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the Initiate eCitizen Payment sub-stub
              Navigator.pushNamed(context, "/initiate_ecitizen_payment");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.green),
            title: const Text("eCitizen Payment"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to the eCitizen Payment sub-stub
              Navigator.pushNamed(context, "/ecitizen_payment");
            },
          ),
        ],
      ),
    );
  }
}
