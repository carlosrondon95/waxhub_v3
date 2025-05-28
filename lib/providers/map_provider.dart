// lib/providers/map_provider.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_maps_webservices/places.dart' as g_places;

import '../services/google_places_service.dart';
import '../services/notification_service.dart';

class MapProvider extends ChangeNotifier {
  // ————————————————————————————————————————————— Ajustes de mapa —————————————————————————————————————————————
  int radius = 10000;
  MapType mapType = MapType.normal;
  bool showPOIs = true;

  // Carga inicial de prefs
  MapProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sp = await SharedPreferences.getInstance();
    radius = sp.getInt('map_radius') ?? radius;
    mapType = MapType.values[sp.getInt('map_type') ?? 0];
    showPOIs = sp.getBool('map_show_pois') ?? showPOIs;
    notifyListeners();
  }

  /// Cambia el radio, lo persiste y recarga marcadores
  Future<void> setRadius(int r) async {
    radius = r;
    notifyListeners();
    await saveSettings();
    await _loadMarkers();
  }

  void setMapType(MapType? t) {
    if (t == null) return;
    mapType = t;
    notifyListeners();
  }

  void setShowPOIs(bool v) {
    showPOIs = v;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('map_radius', radius);
    await sp.setInt('map_type', mapType.index);
    await sp.setBool('map_show_pois', showPOIs);
  }

  // ————————————————————————————————————————————— Lógica de mapa —————————————————————————————————————————————
  final _loc = Location();
  final _places = GooglePlacesService();

  bool hasPermission = false;
  bool isLoading = false;
  LatLng? userLocation;

  Set<Marker> markers = {};
  List<g_places.PlacesSearchResult> shops = [];

  /// Inicializa permisos, localización y marcadores
  Future<void> init() async {
    // Carga ajustes de mapa
    await _loadSettings();

    // Solicita permiso de ubicación
    final perm = await _loc.requestPermission();
    hasPermission = perm == PermissionStatus.granted;
    notifyListeners();
    if (!hasPermission) return;

    // Obtiene ubicación actual
    final l = await _loc.getLocation();
    if (l.latitude == null || l.longitude == null) return;
    userLocation = LatLng(l.latitude!, l.longitude!);
    notifyListeners();

    // Carga marcadores y lanza notificaciones si procede
    await _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    if (userLocation == null) return;

    isLoading = true;
    notifyListeners();

    try {
      // Obtiene tiendas según radio
      shops = await _places.buscarTiendas(
        lat: userLocation!.latitude,
        lng: userLocation!.longitude,
        radius: radius,
      );

      // Crea marcadores para el mapa
      markers =
          shops.map((p) {
            final geo = p.geometry!.location;
            return Marker(
              markerId: MarkerId(p.placeId),
              position: LatLng(geo.lat, geo.lng),
              infoWindow: InfoWindow(title: p.name),
            );
          }).toSet();

      // Comprueba preferencias para notificar tiendas cercanas
      final prefs = await SharedPreferences.getInstance();
      final notify = prefs.getBool('notify_nearby_shops') ?? false;
      if (notify) {
        for (var shop in shops) {
          final lat2 = shop.geometry!.location.lat;
          final lng2 = shop.geometry!.location.lng;
          final dist = _distanceInMeters(
            userLocation!.latitude,
            userLocation!.longitude,
            lat2,
            lng2,
          );
          if (dist < 1000) {
            await NotificationService.showNearbyShopNotification(
              shop.name,
              dist,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Places error: $e');
      shops = [];
      markers = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Calcula la distancia
  double _distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // radio Tierra en metros
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
