import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../providers/map_provider.dart';

class MapSettingsScreen extends StatefulWidget {
  const MapSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MapSettingsScreen> createState() => _MapSettingsScreenState();
}

class _MapSettingsScreenState extends State<MapSettingsScreen> {
  // Valor local para manejar suavemente el slider
  late double _sliderValue;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final prov = context.read<MapProvider>();
      _sliderValue = prov.radius / 1000;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MapProvider>();
    const maxWidth = 450.0;
    final cardColor = Theme.of(context).cardColor;
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de mapa')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Row(
                children: [
                  const Icon(Icons.explore, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Preferencias de Mapa',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Radio de búsqueda (km)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Radio de búsqueda'),
                subtitle: Slider(
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_sliderValue.toStringAsFixed(1)} km',
                  value: _sliderValue,
                  onChanged: (km) {
                    setState(() {
                      _sliderValue = km;
                    });
                  },
                  onChangeEnd: (km) {
                    prov.setRadius((km * 1000).toInt());
                  },
                ),
                trailing: Text(
                  '${_sliderValue.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),

              // Tipo de mapa (solo Normal / Satélite)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.map_outlined),
                title: const Text('Tipo de mapa'),
                trailing: DropdownButton<MapType>(
                  value: prov.mapType,
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
                  onChanged: (MapType? t) {
                    if (t != null) prov.setMapType(t);
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
