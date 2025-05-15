// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _goTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
            child: GestureDetector(
              onTap: () => _goTo(context, '/opciones_usuario'),
              child: CircleAvatar(
                backgroundColor: colors.secondaryContainer,
                radius: 20,
                child: Icon(Icons.person, size: 24, color: colors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset('assets/images/waxhub.png', height: 150),
              const SizedBox(height: 32),

              // Primera fila: Añadir Disco y Colección
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _IconLabel(
                      icon: Icons.add,
                      label: 'Añadir\nDisco',
                      size: 42,
                      onTap: () => _goTo(context, '/nuevo_disco'),
                    ),
                  ),
                  Expanded(
                    child: _IconLabel(
                      icon: Icons.collections,
                      label: 'Colección',
                      size: 42,
                      onTap: () => _goTo(context, '/coleccion'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Segunda fila: Mapa de Tiendas y Comunidad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _IconLabel(
                      icon: Icons.map,
                      label: 'Mapa\nde Tiendas',
                      size: 42,
                      onTap: () => _goTo(context, '/mapa_tiendas'),
                    ),
                  ),
                  Expanded(
                    child: _IconLabel(
                      icon: Icons.group,
                      label: 'Comunidad',
                      size: 42,
                      onTap: () => _goTo(context, '/comunidad'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final VoidCallback onTap;

  const _IconLabel({
    Key? key,
    required this.icon,
    required this.label,
    this.size = 40,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: size, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
