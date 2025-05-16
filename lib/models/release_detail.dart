// lib/models/release_detail.dart
import '../services/discogs_service.dart' show httpsUrl;

class ReleaseDetail {
  final String title;
  final List<String> artists;
  final String? year;
  final String? genre;
  final String? label;
  final String? coverUrl;

  ReleaseDetail({
    required this.title,
    required this.artists,
    this.year,
    this.genre,
    this.label,
    this.coverUrl,
  });

  factory ReleaseDetail.fromJson(Map<String, dynamic> j) => ReleaseDetail(
    title: j['title'] as String,
    artists: (j['artists'] as List).map((a) => a['name'] as String).toList(),
    year: j['year']?.toString(),
    genre:
        (j['genres'] as List?)?.isNotEmpty == true
            ? j['genres']![0] as String
            : null,
    label:
        (j['labels'] as List?)?.isNotEmpty == true
            ? j['labels']![0]['name'] as String
            : null,
    coverUrl:
        (j['images'] as List?)?.isNotEmpty == true
            ? httpsUrl((j['images']![0]['uri'] as String))
            : null,
  );
}
