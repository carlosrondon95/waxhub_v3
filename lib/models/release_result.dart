import '/services/discogs_service.dart' show httpsUrl;

class ReleaseResult {
  final int id;
  final String title;
  final String thumb;

  ReleaseResult({required this.id, required this.title, required this.thumb});

  factory ReleaseResult.fromJson(Map<String, dynamic> j) => ReleaseResult(
    id: j['id'] as int,
    title: j['title'] as String,
    thumb: httpsUrl(j['thumb']),
  );
}
