import 'package:flutter_google_maps_webservices/places.dart' as g_places;

/// Servicio ligero para consultar Google Places y obtener tiendas de vinilo.
class GooglePlacesService {
  static const _apiKey = 'AIzaSyBpmV9gSDHG472GUmxC0e0JbMO4jjPQJGA';

  final _places = g_places.GoogleMapsPlaces(apiKey: _apiKey);

  /// Busca “vinyl record store” en un radio (m) alrededor de [lat,lng].
  Future<List<g_places.PlacesSearchResult>> buscarTiendas({
    required double lat,
    required double lng,
    int radius = 50000, // 50 km
  }) async {
    final resp = await _places.searchNearbyWithRadius(
      g_places.Location(lat: lat, lng: lng),
      radius,
      keyword: 'vinyl record store',
    );

    if (!resp.isOkay) {
      throw Exception(
        'Places API error: ${resp.status} – ${resp.errorMessage}',
      );
    }

    // Filtra resultados que SÍ tienen geometry
    return resp.results.where((r) => r.geometry?.location != null).toList();
  }
}
