import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_maps_webservices/places.dart' as g_places;
import '../services/google_places_service.dart';

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

  void setRadius(int r) {
    radius = r;
    notifyListeners();
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
    // Solicita permiso
    final perm = await _loc.requestPermission();
    hasPermission = perm == PermissionStatus.granted;
    notifyListeners();
    if (!hasPermission) return;

    // Consigue localización
    final l = await _loc.getLocation();
    if (l.latitude == null || l.longitude == null) return;
    userLocation = LatLng(l.latitude!, l.longitude!);
    notifyListeners();

    // Carga marcadores según radio actual
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
        radius: radius, // usa radio de ajustes
      );

      markers =
          shops.map((p) {
            final geo = p.geometry!.location;
            return Marker(
              markerId: MarkerId(p.placeId),
              position: LatLng(geo.lat, geo.lng),
              infoWindow: InfoWindow(title: p.name),
            );
          }).toSet();
    } catch (e) {
      debugPrint('Places error: $e');
      shops = [];
      markers = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
