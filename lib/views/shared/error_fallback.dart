import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorFallbackScreen extends StatelessWidget {
  const ErrorFallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Page Not Found', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    );
  }
}
