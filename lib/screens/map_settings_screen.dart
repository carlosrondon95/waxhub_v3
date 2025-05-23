// lib/screens/settings/map_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';

class MapSettingsScreen extends StatelessWidget {
  const MapSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapProv = context.watch<MapProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de mapa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Radio de búsqueda ───────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Radio de búsqueda (m)'),
              subtitle: Slider(
                min: 1000,
                max: 50000,
                divisions: 49,
                label: '${mapProv.radius} m',
                value: mapProv.radius.toDouble(),
                onChanged: (v) => mapProv.setRadius(v.toInt()),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tipo de mapa ────────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tipo de mapa'),
              trailing: DropdownButton<MapType>(
                value: mapProv.mapType,
                items:
                    MapType.values.map((t) {
                      final name = t.toString().split('.').last;
                      return DropdownMenuItem(
                        value: t,
                        child: Text(name[0].toUpperCase() + name.substring(1)),
                      );
                    }).toList(),
                onChanged: mapProv.setMapType,
              ),
            ),

            const SizedBox(height: 16),

            // ─── Puntos de interés ───────────────────────────────────
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mostrar POIs'),
              value: mapProv.showPOIs,
              onChanged: mapProv.setShowPOIs,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                await mapProv.saveSettings();
                Navigator.pop(context);
              },
              child: const Text('Guardar ajustes'),
            ),
          ],
        ),
      ),
    );
  }
}
