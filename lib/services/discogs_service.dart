// lib/services/discogs_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/artist_result.dart';
import '../models/release_result.dart';
import '../models/release_detail.dart';

/// Convierte cualquier URL http: en https:
String httpsUrl(String? url) =>
    url == null ? '' : url.replaceFirst(RegExp(r'^http:'), 'https:');

class DiscogsService {
  static const _base = 'https://api.discogs.com';
  static const _key = 'EnOxCIQFcqxxCmvaYxoC';
  static const _secret = 'mobvMiiVhTlRnxHvGEtsQccHnyihqtOV';
  static const _agent = 'WaxHub/1.0 (info@tucorreo.com)';

  final Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': _agent,
  };

  Map<String, String> _authQS(Map<String, String> qp) => {
    ...qp,
    'key': _key,
    'secret': _secret,
  };

  Future<List<ArtistResult>> searchArtists(String q) async {
    final uri = Uri.parse(
      '$_base/database/search',
    ).replace(queryParameters: _authQS({'q': q, 'type': 'artist'}));
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);
    final json = jsonDecode(res.body);
    return (json['results'] as List)
        .map((e) => ArtistResult.fromJson(e))
        .toList();
  }

  Future<List<ReleaseResult>> searchVinylsOfArtist(
    int artistId,
    String title,
  ) async {
    final uri = Uri.parse('$_base/database/search').replace(
      queryParameters: _authQS({
        'artist_id': artistId.toString(),
        'release_title': title,
        'format': 'Vinyl',
        'type': 'release',
        'per_page': '100',
      }),
    );
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);

    final seen = <String>{};
    final out = <ReleaseResult>[];
    for (final e in jsonDecode(res.body)['results']) {
      final r = ReleaseResult.fromJson(e);
      final key =
          r.title.toLowerCase().replaceAll(RegExp(r'\s+\(.*?\)'), '').trim();
      if (seen.add(key)) out.add(r);
    }
    return out;
  }

  Future<ReleaseDetail> fetchRelease(int id) async {
    final uri = Uri.parse('$_base/releases/$id');
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);
    return ReleaseDetail.fromJson(jsonDecode(res.body));
  }

  void _throwIfError(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('Discogs ${r.statusCode}: ${r.reasonPhrase}');
    }
  }
}
