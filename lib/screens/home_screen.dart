import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goTo(BuildContext context, String route) =>
      Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Image.asset('assets/images/waxhub.png', height: 150),
                const SizedBox(height: 32),
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
                    // Espacio reservado para futuras funcionalidades
                    const Expanded(child: SizedBox()),
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
  final double size;
  final VoidCallback onTap;

  const _IconLabel({
    required this.icon,
    required this.label,
    this.size = 40,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
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
    );
  }
}
