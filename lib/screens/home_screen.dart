import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goTo(BuildContext context, String route) => context.push(route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Align(
          alignment: const Alignment(0, -0.4),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fila superior: Añadir disco & Colección
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _IconLabel(
                        icon: Icons.add,
                        label: 'Añadir Disco',
                        onTap: () => _goTo(context, '/nuevo_disco'),
                      ),
                    ),
                    Expanded(
                      child: _IconLabel(
                        icon: Icons.collections,
                        label: 'Ver Colección',
                        onTap: () => _goTo(context, '/coleccion'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Logo
                Image.asset('assets/images/waxhub.png', height: 150),
                const SizedBox(height: 16),
                // Fila inferior: Mapa de Tiendas & Opciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _IconLabel(
                        icon: Icons.map,
                        label: 'Tiendas Cercanas',
                        onTap: () => _goTo(context, '/mapa_tiendas'),
                      ),
                    ),
                    Expanded(
                      child: _IconLabel(
                        icon: Icons.settings,
                        label: 'Ajustes',
                        onTap: () => _goTo(context, '/ajustes'),
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

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  static const double _iconSize = 50;

  const _IconLabel({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _iconSize, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
