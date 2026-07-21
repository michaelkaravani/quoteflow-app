import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final email = authService.currentUser?.email ?? 'user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuoteFlow'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: authService.signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.request_quote, size: 72, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'Welcome to QuoteFlow',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(email, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create a quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
