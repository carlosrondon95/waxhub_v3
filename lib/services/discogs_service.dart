import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Convierte URLs http a https para seguridad.
String _https(String? url) =>
    url == null ? '' : url.replaceFirst(RegExp(r'^http:'), 'https:');

class DiscogsService {
  static const _base = 'https://api.discogs.com';

  String get _key => dotenv.env['DISCOGS_KEY'] ?? '';
  String get _secret => dotenv.env['DISCOGS_SECRET'] ?? '';

  final Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'WaxHub/1.0',
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
      final key = r.title
          .toLowerCase()
          .replaceAll(RegExp(r'\s+\(.*?\)'), '')
          .trim();
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

/* ───────── Modelos ───────── */

class ArtistResult {
  final int id;
  final String name;

  const ArtistResult({required this.id, required this.name});

  factory ArtistResult.fromJson(Map<String, dynamic> j) =>
      ArtistResult(id: j['id'], name: j['title']);
}

class ReleaseResult {
  final int id;
  final String title;
  final String thumb;

  const ReleaseResult({
    required this.id,
    required this.title,
    required this.thumb,
  });

  factory ReleaseResult.fromJson(Map<String, dynamic> j) =>
      ReleaseResult(id: j['id'], title: j['title'], thumb: _https(j['thumb']));
}

class ReleaseDetail {
  final String title;
  final List<String> artists;
  final String? year;
  final String? genre;
  final String? label;
  final String? coverUrl;

  const ReleaseDetail({
    required this.title,
    required this.artists,
    this.year,
    this.genre,
    this.label,
    this.coverUrl,
  });

  factory ReleaseDetail.fromJson(Map<String, dynamic> j) => ReleaseDetail(
    title: j['title'],
    artists: (j['artists'] as List).map((a) => a['name'] as String).toList(),
    year: j['year']?.toString(),
    genre: (j['genres'] as List?)?.isNotEmpty == true ? j['genres'][0] : null,
    label:
        (j['labels'] as List?)?.isNotEmpty == true
            ? j['labels'][0]['name']
            : null,
    coverUrl:
        (j['images'] as List?)?.isNotEmpty == true
            ? _https(j['images'][0]['uri'])
            : null,
  );
}
