// lib/models/vinyl_record.dart
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

  VinylRecord({
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
}
