import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_google_maps_webservices/places.dart' as g_places;

/// Servicio que consulta la Cloud Function `nearbyVinylStores`
/// y devuelve las tiendas de vinilo cercanas como modelos de
/// `flutter_google_maps_webservices`.
class GooglePlacesService {
  // URL del proxy HTTPS (ajusta si cambias región/proyecto)
  static const _proxyUrl =
      'https://europe-west1-waxhub95.cloudfunctions.net/nearbyVinylStores';

  /// Busca “vinyl record store” cerca de [lat,lng] en un radio de [radius] m.
  Future<List<g_places.PlacesSearchResult>> buscarTiendas({
    required double lat,
    required double lng,
    int radius = 10_000, // 10 km
  }) async {
    final uri = Uri.parse(_proxyUrl).replace(queryParameters: {
      'lat': '$lat',
      'lng': '$lng',
      'radius': '$radius',
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception(
          'Proxy error ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    final data = g_places.PlacesSearchResponse.fromJson(
      json.decode(resp.body),
    );

    if (!data.isOkay) {
      throw Exception(
          'Places API error: ${data.status} – ${data.errorMessage}');
    }

    // Devolvemos solo resultados con coordenadas válidas
    return (data.results)
        .where((r) => r.geometry?.location != null)
        .toList();
  }
}
