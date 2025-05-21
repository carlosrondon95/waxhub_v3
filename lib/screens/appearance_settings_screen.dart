import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ThemeService>();
    const maxWidth = 450.0;

    Widget _radio({
      required ThemeMode mode,
      required IconData icon,
      required String label,
    }) => RadioListTile<ThemeMode>(
      value: mode,
      groupValue: service.mode,
      onChanged: (m) => service.setMode(m!),
      title: Text(label),
      secondary: Icon(icon),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tema y apariencia')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.all(30),
          decoration: _box(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _radio(
                mode: ThemeMode.system,
                icon: Icons.brightness_auto_outlined,
                label: 'Automático (sistema)',
              ),
              const Divider(height: 0),
              _radio(
                mode: ThemeMode.light,
                icon: Icons.wb_sunny_outlined,
                label: 'Claro',
              ),
              const Divider(height: 0),
              _radio(
                mode: ThemeMode.dark,
                icon: Icons.nightlight_round,
                label: 'Oscuro',
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _box(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
