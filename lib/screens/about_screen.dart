// lib/screens/settings/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(Icons.album, size: 72, color: accent)),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'WaxHub',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(fontSize: 18, color: accent.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'WaxHub es una plataforma diseñada especialmente para coleccionistas de vinilos. '
              'Su interfaz te permite:',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _bullet(
              context,
              'Añadir y catalogar discos de forma ágil.',
              accent,
            ),
            _bullet(
              context,
              'Crear listas personalizadas y destacar tus favoritos.',
              accent,
            ),
            _bullet(
              context,
              'Explorar un mapa interactivo de tiendas cercanas.',
              accent,
            ),
            _bullet(
              context,
              'Disfrutar de acceso seguro y sincronización en la nube.',
              accent,
            ),
            const SizedBox(height: 24),
            Text(
              'Con WaxHub tendrás tu colección siempre bajo control.',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Licencia MIT\n© 2025 WaxHub. Todos los derechos reservados.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Desarrollado por Carlos Rondón Pérez\n'
              'Proyecto de Fin de Ciclo\n'
              'CFGS Desarrollo de Aplicaciones Multiplataforma',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
