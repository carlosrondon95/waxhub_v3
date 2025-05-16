import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/map_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;

  /// Clave que obligará a recrear el widget GoogleMap en Web cuando
  /// cambie el número de marcadores.
  UniqueKey _mapKey = UniqueKey();

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

            // Si cambia el número de marcadores, generamos una key nueva
            _mapKey = UniqueKey();

            return Column(
              children: [
                // ─── Mapa (mitad superior) ───────────────────────────
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: GoogleMap(
                    key: _mapKey, // 🔑 fuerza rebuild en Web
                    initialCameraPosition: CameraPosition(
                      target: map.userLocation!,
                      zoom: 13,
                    ),
                    myLocationEnabled: true,
                    markers: map.markers,
                    onMapCreated: (c) => _mapCtrl = c,
                  ),
                ),

                const Divider(height: 1),

                // ─── Lista de tiendas (mitad inferior) ───────────────
                Expanded(
                  child:
                      map.shops.isEmpty
                          ? const Center(child: Text('Sin tiendas cercanas'))
                          : ListView.separated(
                            itemCount: map.shops.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 0),
                            itemBuilder: (_, idx) {
                              final shop = map.shops[idx];
                              final geo = shop.geometry!.location;
                              return ListTile(
                                leading: const Icon(Icons.store),
                                title: Text(shop.name),
                                subtitle: Text(
                                  shop.vicinity ??
                                      '(${geo.lat.toStringAsFixed(4)}, '
                                          '${geo.lng.toStringAsFixed(4)})',
                                ),
                                onTap: () {
                                  _mapCtrl?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(geo.lat, geo.lng),
                                      15,
                                    ),
                                  );
                                },
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
