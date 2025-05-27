import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onBg = colorScheme.onBackground;
    final onBgMedium = onBg.withOpacity(0.8);
    final onBgLight = onBg.withOpacity(0.6);
    final accent = colorScheme.primary;

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Versión 1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: onBgMedium),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'WaxHub es una plataforma diseñada especialmente para coleccionistas de vinilos. '
              'Su interfaz te permite:',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: onBg, height: 1.5),
            ),
            const SizedBox(height: 12),
            _bullet(
              context,
              'Añadir y catalogar discos de forma ágil.',
              accent,
              onBg,
            ),
            _bullet(
              context,
              'Crear listas personalizadas y destacar tus favoritos.',
              accent,
              onBg,
            ),
            _bullet(
              context,
              'Explorar un mapa interactivo de tiendas cercanas.',
              accent,
              onBg,
            ),
            _bullet(
              context,
              'Disfrutar de acceso seguro y sincronización en la nube.',
              accent,
              onBg,
            ),
            const SizedBox(height: 24),
            Text(
              'Con WaxHub tendrás tu colección siempre bajo control.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: onBg, height: 1.5),
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Licencia MIT\n© 2025 WaxHub. Todos los derechos reservados.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: onBgLight, height: 1.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Desarrollado por Carlos Rondón Pérez\n'
              'Proyecto de Fin de Ciclo\n'
              'CFGS Desarrollo de Aplicaciones Multiplataforma',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onBgLight,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text, Color accent, Color onBg) {
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: onBg, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
