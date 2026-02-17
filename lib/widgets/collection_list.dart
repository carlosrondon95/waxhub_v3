import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/vinyl_record.dart';
import '../core/image_proxy.dart';

class CollectionList extends StatelessWidget {
  final List<VinylRecord> records;
  final ValueChanged<VinylRecord> onTap;
  final ValueChanged<VinylRecord> onEdit;
  final ValueChanged<String> onDelete;
  final void Function(String, bool) onFavoriteToggle;

  const CollectionList({
    super.key,
    required this.records,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    final leadingSize = isDesktop ? 80.0 : 60.0;
    final cardPadding = isDesktop ? 12.0 : 8.0;

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        final r = records[index];
        return Card(
          margin: EdgeInsets.symmetric(
            vertical: cardPadding / 2,
            horizontal: cardPadding,
          ),
          child: ListTile(
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: leadingSize,
                maxHeight: leadingSize,
              ),
              child: CachedNetworkImage(
                imageUrl: proxiedImage(r.portadaUrl),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image),
              ),
            ),
            title: Text(r.artista),
            subtitle: Text('${r.titulo} (${r.anio})'),
            onTap: () => onTap(r),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip:
                      r.favorito ? 'Quitar de favoritos' : 'Marcar favorito',
                  icon: Icon(
                    r.favorito ? Icons.favorite : Icons.favorite_border,
                    color: r.favorito ? Colors.red : null,
                  ),
                  onPressed: () => onFavoriteToggle(r.id, r.favorito),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'editar') onEdit(r);
                    if (v == 'eliminar') onDelete(r.id);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Editar'),
                      ),
                    ),
                    PopupMenuItem(
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
