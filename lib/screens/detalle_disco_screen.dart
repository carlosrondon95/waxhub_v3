import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/vinyl_record.dart';
import '../providers/collection_provider.dart';

class DetalleDiscoScreen extends StatelessWidget {
  final VinylRecord record;
  const DetalleDiscoScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    // Obtenemos la versión más reciente del disco por si ha cambiado (p. ej. favorito)
    final updatedRecord = collection.allRecords.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedRecord.titulo),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit),
            onPressed: () => context.pushNamed('editar_disco', extra: updatedRecord),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar disco'),
                  content: const Text('¿Seguro que quieres eliminar este disco de tu colección?'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => context.pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await collection.deleteRecord(updatedRecord.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: updatedRecord.favorito ? 'Quitar de favoritos' : 'Marcar como favorito',
        onPressed: () => collection.toggleFavorite(updatedRecord.id, updatedRecord.favorito),
        child: Icon(
          updatedRecord.favorito ? Icons.favorite : Icons.favorite_border,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      updatedRecord.portadaUrl,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 120),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _InfoTile(icon: Icons.person, label: 'Artista', value: updatedRecord.artista),
                _InfoTile(icon: Icons.album, label: 'Título', value: updatedRecord.titulo),
                _InfoTile(icon: Icons.music_note, label: 'Género', value: updatedRecord.genero),
                _InfoTile(icon: Icons.calendar_today, label: 'Año', value: '${updatedRecord.anio}'),
                _InfoTile(icon: Icons.library_music, label: 'Sello', value: updatedRecord.sello),
                if (updatedRecord.lugarCompra.isNotEmpty)
                  _InfoTile(
                    icon: Icons.store_mall_directory,
                    label: 'Lugar de compra',
                    value: updatedRecord.lugarCompra,
                  ),
                if (updatedRecord.descripcion.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text('Descripción',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    updatedRecord.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 28),
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
