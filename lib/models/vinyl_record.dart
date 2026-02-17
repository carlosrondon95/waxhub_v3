import 'package:cloud_firestore/cloud_firestore.dart';

class VinylRecord {
  final String id;
  final String userId;
  final String referencia;
  final String artista;
  final String titulo;
  final String genero;
  final String anio;
  final String sello;
  final String lugarCompra;
  final String descripcion;
  final String portadaUrl;
  final bool favorito;

  const VinylRecord({
    required this.id,
    required this.userId,
    required this.referencia,
    required this.artista,
    required this.titulo,
    required this.genero,
    required this.anio,
    required this.sello,
    this.lugarCompra = '',
    this.descripcion = '',
    required this.portadaUrl,
    this.favorito = false,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'referencia': referencia,
    'artista': artista,
    'titulo': titulo,
    'genero': genero,
    'anio': anio,
    'sello': sello,
    'lugarCompra': lugarCompra,
    'descripcion': descripcion,
    'portadaUrl': portadaUrl,
    'favorito': favorito,
    'timestamp': FieldValue.serverTimestamp(),
  };

  VinylRecord copyWith({
    String? id,
    String? userId,
    String? referencia,
    String? artista,
    String? titulo,
    String? genero,
    String? anio,
    String? sello,
    String? lugarCompra,
    String? descripcion,
    String? portadaUrl,
    bool? favorito,
  }) {
    return VinylRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      referencia: referencia ?? this.referencia,
      artista: artista ?? this.artista,
      titulo: titulo ?? this.titulo,
      genero: genero ?? this.genero,
      anio: anio ?? this.anio,
      sello: sello ?? this.sello,
      lugarCompra: lugarCompra ?? this.lugarCompra,
      descripcion: descripcion ?? this.descripcion,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      favorito: favorito ?? this.favorito,
    );
  }

  factory VinylRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VinylRecord(
      id: doc.id,
      userId: data['userId'] as String,
      referencia: data['referencia'] as String,
      artista: data['artista'] as String,
      titulo: data['titulo'] as String,
      genero: data['genero'] as String,
      anio: data['anio'] as String,
      sello: data['sello'] as String,
      lugarCompra: data['lugarCompra'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      portadaUrl: data['portadaUrl'] as String,
      favorito: data['favorito'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VinylRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
