import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Your Budget Manager',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('v1.0.0 — Privacy-First Finance Companion'),
            SizedBox(height: 24),
            Text(
              'Your data is 100% stored locally on your device in an encrypted SQLite database. No servers, no tracking, no external data sharing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
