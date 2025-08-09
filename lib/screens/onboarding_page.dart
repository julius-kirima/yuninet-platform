import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Yuninet')), 
      body: Center(child: Text('Onboarding content here')), 
    );
  }
}