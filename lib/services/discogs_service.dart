// lib/services/discogs_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/release_detail.dart';
import '../models/artist_result.dart';
import '../models/release_result.dart';

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

  /// Importa toda la colección de Discogs y la guarda en Firestore
  Future<void> importCollection(String username) async {
    final firestore = FirebaseFirestore.instance;

    // 1) Recupera la carpeta "All" (id=0)
    final foldersUri = Uri.parse(
      '$_base/users/$username/collection/folders',
    ).replace(queryParameters: _authQS({'per_page': '100'}));
    final foldersRes = await http.get(foldersUri, headers: _headers);
    _throwIfError(foldersRes);
    final foldersJson = jsonDecode(foldersRes.body);
    final folderId =
        (foldersJson['folders'] as List).firstWhere((f) => f['id'] == 0)['id'];

    // 2) Paginación de releases
    int page = 1;
    while (true) {
      final listUri = Uri.parse(
        '$_base/users/$username/collection/folders/$folderId/releases',
      ).replace(
        queryParameters: _authQS({'per_page': '100', 'page': page.toString()}),
      );
      final listRes = await http.get(listUri, headers: _headers);
      _throwIfError(listRes);
      final listJson = jsonDecode(listRes.body) as Map<String, dynamic>;
      final releases = listJson['releases'] as List<dynamic>;
      if (releases.isEmpty) break;

      // 3) Por cada release, obtén detalle y sube a Firestore
      for (final item in releases) {
        final relId = item['basic_information']['id'] as int;
        final detail = await fetchRelease(relId);

        final data = {
          'userId': username,
          'referencia': relId.toString(),
          'titulo': detail.title,
          'artista': detail.artists.join(', '),
          'anio': detail.year ?? '',
          'genero': detail.genre ?? '',
          'sello': detail.label ?? '',
          'portadaUrl': detail.coverUrl ?? '',
          'favorito': false,
        };
        await firestore.collection('discos').add(data);
      }
      page++;
    }
  }

  /// Actualiza la colección existente (borra y reimporta)
  Future<void> updateCollection(String username) async {
    final firestore = FirebaseFirestore.instance;

    // Borra discos de este usuario
    final snap =
        await firestore
            .collection('discos')
            .where('userId', isEqualTo: username)
            .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }

    // Reimporta todo
    await importCollection(username);
  }

  void _throwIfError(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('Discogs ${r.statusCode}: ${r.reasonPhrase}');
    }
  }
}
