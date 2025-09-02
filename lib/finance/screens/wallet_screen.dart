import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Wallet Details"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/wallet_details");
            },
          ),
          ListTile(
            title: const Text("Transactions"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/wallet_transactions");
            },
          ),
          ListTile(
            title: const Text("Top Up Wallet"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, "/wallet_topup");
            },
          ),
        ],
      ),
    );
  }
}
