import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WAXHUB',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                Image.asset('assets/images/waxhub.png', height: 180),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Crear Cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
