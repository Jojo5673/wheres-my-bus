import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'landing_store.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Modular.get<LandingStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Landing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: ${store.count}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: store.increment,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}