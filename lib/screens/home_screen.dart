import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaxHub'),
        centerTitle: true,
        automaticallyImplyLeading: false, // quita la flecha de “atrás”
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/images/waxhub.png', height: 150),
                const SizedBox(height: 24),

                // Opciones de menú
                MenuOption(
                  title: 'Añadir Disco',
                  icon: Icons.add,
                  onTap: () => Navigator.pushNamed(context, '/nuevo_disco'),
                ),
                const SizedBox(height: 16),
                MenuOption(
                  title: 'Ver Colección',
                  icon: Icons.collections,
                  onTap: () => Navigator.pushNamed(context, '/coleccion'),
                ),
                const SizedBox(height: 16),
                MenuOption(
                  title: 'Mapa de Tiendas',
                  icon: Icons.map,
                  onTap: () => Navigator.pushNamed(context, '/mapa_tiendas'),
                ),
                const SizedBox(height: 16),
                MenuOption(
                  title: 'Opciones de Usuario',
                  icon: Icons.person,
                  onTap:
                      () => Navigator.pushNamed(context, '/opciones_usuario'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFB2EBF2), // secundario suave
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFF00BCD4), // primario turquesa
              ),
              const SizedBox(width: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
