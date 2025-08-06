import 'package:flutter/material.dart';

class AboutYuninetScreen extends StatelessWidget {
  const AboutYuninetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Yuninet')),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yuninet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Yuninet is a youth-driven social platform designed to connect, empower, and uplift communities with powerful features, government services, and tools for growth. Built by Julius Kirima, Yuninet is on a mission to inspire innovation and opportunity.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
