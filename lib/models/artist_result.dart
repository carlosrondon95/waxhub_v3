class ArtistResult {
  final int id;
  final String name;

  ArtistResult({required this.id, required this.name});

  factory ArtistResult.fromJson(Map<String, dynamic> j) =>
      ArtistResult(id: j['id'] as int, name: j['title'] as String);
}
