import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  // Ancho máximo para los botones
  static const double _buttonMaxWidth = 300.0;

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
                // Diseño según plataforma
                if (kIsWeb)
                  // Web: botones en fila con ancho limitado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _buttonMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.pushNamed('login'),
                            child: const Text('Iniciar Sesión'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _buttonMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.pushNamed('register'),
                            child: const Text('Crear Cuenta'),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Móvil: botones apilados con ancho máximo
                  Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _buttonMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.pushNamed('login'),
                            child: const Text('Iniciar Sesión'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _buttonMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.pushNamed('register'),
                            child: const Text('Crear Cuenta'),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
