// lib/widgets/collection_list.dart
import 'package:flutter/material.dart';
import '../models/vinyl_record.dart';

class CollectionList extends StatelessWidget {
  final List<VinylRecord> records;
  final ValueChanged<VinylRecord> onTap;
  final ValueChanged<VinylRecord> onEdit;
  final ValueChanged<String> onDelete;
  final void Function(String, bool) onFavoriteToggle;

  const CollectionList({
    Key? key,
    required this.records,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Image.network(
              record.portadaUrl,
              width: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
            title: Text(record.artista),
            subtitle: Text('${record.titulo} (${record.anio})'),
            onTap: () => onTap(record),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    record.favorito ? Icons.favorite : Icons.favorite_border,
                    color: record.favorito ? Colors.red : null,
                  ),
                  onPressed: () => onFavoriteToggle(record.id, record.favorito),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar')
                      onEdit(record);
                    else if (value == 'eliminar')
                      onDelete(record.id);
                  },
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Editar'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Eliminar'),
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
