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
    const maxWidth = 450.0;
    final cardColor = Theme.of(context).cardColor;
    final shadow = Theme.of(context).shadowColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de mapa'),
        // Sin `leading`, así Flutter dibuja automáticamente la flecha atrás
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera con icono
              Row(
                children: [
                  const Icon(Icons.explore, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Preferencias de Mapa',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Radio en km
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Radio de búsqueda'),
                subtitle: Slider(
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${(mapProv.radius / 1000).toStringAsFixed(1)} km',
                  value: mapProv.radius / 1000,
                  onChanged: (km) => mapProv.setRadius((km * 1000).toInt()),
                ),
                trailing: Text(
                  '${(mapProv.radius / 1000).toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),

              const SizedBox(height: 16),

              // Tipo de mapa (solo Normal y Satélite)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.map_outlined),
                title: const Text('Tipo de mapa'),
                trailing: DropdownButton<MapType>(
                  value: mapProv.mapType,
                  items: const [
                    DropdownMenuItem(
                      value: MapType.normal,
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: MapType.satellite,
                      child: Text('Satélite'),
                    ),
                  ],
                  onChanged: mapProv.setMapType,
                ),
              ),

              const SizedBox(height: 24),

              // Botón de guardar con popup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar ajustes'),
                  onPressed: () async {
                    await mapProv.saveSettings();
                    await showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('¡Listo!'),
                            content: const Text(
                              'Los cambios se han aplicado correctamente.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
