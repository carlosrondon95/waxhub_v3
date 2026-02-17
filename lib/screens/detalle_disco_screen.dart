import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/vinyl_record.dart';
import '../providers/collection_provider.dart';

class DetalleDiscoScreen extends StatelessWidget {
  final VinylRecord record;
  const DetalleDiscoScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final collection = context.read<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(record.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/editar_disco',
              arguments: record,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, collection),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: record.portadaUrl,
                height: 200,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            Text('Artista: ${record.artista}'),
            Text('Título: ${record.titulo}'),
            Text('Género: ${record.genero}'),
            Text('Año: ${record.anio}'),
            Text('Sello: ${record.sello}'),
            if (record.lugarCompra.isNotEmpty)
              Text('Compra: ${record.lugarCompra}'),
            if (record.descripcion.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Descripción:'),
              Text(record.descripcion),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Favorito:'),
                IconButton(
                  icon: Icon(
                    record.favorito ? Icons.favorite : Icons.favorite_border,
                    color: record.favorito ? Colors.red : null,
                  ),
                  onPressed: () {
                    collection.toggleFavorite(record.id, record.favorito);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CollectionProvider collection) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar disco'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este disco de tu colección?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await collection.deleteRecord(record.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
