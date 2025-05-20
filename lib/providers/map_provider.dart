import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_google_maps_webservices/places.dart' as g_places;

import '../services/google_places_service.dart';

class MapProvider extends ChangeNotifier {
  final _loc = Location();
  final _places = GooglePlacesService();

  bool hasPermission = false;
  bool isLoading = false;
  LatLng? userLocation;

  Set<Marker> markers = {};
  List<g_places.PlacesSearchResult> shops = [];

  /// Llama a esto en initState (ya lo haces desde MapScreen).
  Future<void> init() async {
    // ── Permisos ───────────────────────────────────────────────────────
    final perm = await _loc.requestPermission();
    hasPermission = perm == PermissionStatus.granted;
    notifyListeners();
    if (!hasPermission) return;

    // ── Localización del usuario ───────────────────────────────────────
    final l = await _loc.getLocation();
    if (l.latitude == null || l.longitude == null) return;
    userLocation = LatLng(l.latitude!, l.longitude!);
    notifyListeners();

    // ── Carga de tiendas y marcadores ──────────────────────────────────
    await _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    if (userLocation == null) return;

    isLoading = true;
    notifyListeners();

    try {
      shops = await _places.buscarTiendas(
        lat: userLocation!.latitude,
        lng: userLocation!.longitude,
      );

      markers = shops.map((p) {
        final geo = p.geometry!.location;
        return Marker(
          markerId: MarkerId(p.placeId),
          position: LatLng(geo.lat, geo.lng),
          infoWindow: InfoWindow(title: p.name),
        );
      }).toSet();
    } catch (e, s) {
      debugPrint('Places error: $e\n$s');
      shops = [];
      markers = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
