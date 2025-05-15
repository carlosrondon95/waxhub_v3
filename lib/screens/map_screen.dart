import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/map_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapProvider()..init(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mapa de Tiendas')),
        body: Consumer<MapProvider>(
          builder: (_, map, __) {
            if (!map.hasPermission) {
              return const Center(child: Text('Permiso de ubicación denegado'));
            }
            if (map.isLoading || map.userLocation == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: map.userLocation!,
                      zoom: 13,
                    ),
                    myLocationEnabled: true,
                    markers: map.markers,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child:
                      map.shops.isEmpty
                          ? const Center(child: Text('Sin tiendas cercanas'))
                          : ListView.separated(
                            itemCount: map.shops.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 0),
                            itemBuilder: (_, idx) {
                              final s = map.shops[idx];
                              final geo = s.geometry!.location;
                              return ListTile(
                                leading: const Icon(Icons.store),
                                title: Text(s.name),
                                subtitle: Text(
                                  s.vicinity ?? '(${geo.lat}, ${geo.lng})',
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
