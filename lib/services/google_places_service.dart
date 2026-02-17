import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart' as g_places;

/// Servicio ligero para consultar Google Places y obtener tiendas de vinilo.
class GooglePlacesService {
  late final g_places.GoogleMapsPlaces _places;

  GooglePlacesService() {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
    _places = g_places.GoogleMapsPlaces(apiKey: apiKey);
  }

  /// Busca "vinyl record store" en un radio (m) alrededor de [lat, lng].
  Future<List<g_places.PlacesSearchResult>> buscarTiendas({
    required double lat,
    required double lng,
    int radius = 50000,
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

    return resp.results.where((r) => r.geometry?.location != null).toList();
  }
}
