import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.amber),
            title: const Text('Dark Mode (Default & Active)'),
            subtitle: const Text('Futuristic dark aesthetic with gold accents'),
            trailing: const Icon(Icons.check_circle, color: Colors.amber),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.light_mode, color: Colors.grey),
            title: const Text('Light Mode'),
            subtitle: const Text('Custom light theme (Coming Soon)'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Light mode will be customizable in a future update.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
