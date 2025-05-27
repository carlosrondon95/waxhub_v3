// lib/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '/providers/map_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;
  UniqueKey _mapKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para que al cambiar settings se reconstruya.
    final mapProv = context.watch<MapProvider>();

    // Generamos un style JSON para ocultar POIs si hace falta.
    final poiStyle =
        mapProv.showPOIs
            ? null
            : '''[
      {
        "featureType": "poi",
        "stylers": [{"visibility": "off"}]
      }
    ]''';

    // Cada vez que cambie el número de marcadores o el tipo de mapa, forzamos rebuild en Web.
    _mapKey = UniqueKey();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Tiendas')),
      body: Center(
        child:
            mapProv.isLoading || mapProv.userLocation == null
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    // Mapa
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      child: GoogleMap(
                        key: _mapKey,
                        mapType: mapProv.mapType, // ← Aplica el tipo de mapa
                        initialCameraPosition: CameraPosition(
                          target: mapProv.userLocation!,
                          zoom: 13,
                        ),
                        myLocationEnabled: true,
                        markers: mapProv.markers,
                        onMapCreated: (controller) {
                          _mapCtrl = controller;
                          if (poiStyle != null) {
                            _mapCtrl!.setMapStyle(poiStyle);
                          }
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    // Lista de tiendas
                    Expanded(
                      child:
                          mapProv.shops.isEmpty
                              ? const Center(
                                child: Text('Sin tiendas cercanas'),
                              )
                              : ListView.separated(
                                separatorBuilder:
                                    (_, __) => const Divider(height: 0),
                                itemCount: mapProv.shops.length,
                                itemBuilder: (_, i) {
                                  final shop = mapProv.shops[i];
                                  final loc = shop.geometry!.location;
                                  return ListTile(
                                    leading: const Icon(Icons.store),
                                    title: Text(shop.name),
                                    subtitle: Text(
                                      shop.vicinity ??
                                          '(${loc.lat.toStringAsFixed(4)}, ${loc.lng.toStringAsFixed(4)})',
                                    ),
                                    onTap: () {
                                      _mapCtrl?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          LatLng(loc.lat, loc.lng),
                                          15,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
