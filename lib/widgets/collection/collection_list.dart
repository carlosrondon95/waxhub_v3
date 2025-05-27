// lib/widgets/collection_list.dart

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/models/vinyl_record.dart';
import '/core/image_proxy.dart';

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
    final leadingSize = isDesktop ? 100.0 : 80.0;
    final horizontalMargin = isDesktop ? 16.0 : 8.0;
    final maxContentWidth = isDesktop ? 700.0 : double.infinity;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Card(
              margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: horizontalMargin,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: leadingSize,
                    maxHeight: leadingSize,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      proxiedImage(r.portadaUrl),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
                title: Text(
                  r.artista,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${r.titulo} • ${r.anio}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () => onTap(r),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip:
                          r.favorito
                              ? 'Quitar de favoritos'
                              : 'Marcar favorito',
                      icon: Icon(
                        r.favorito ? Icons.favorite : Icons.favorite_border,
                        color: r.favorito ? Colors.red : null,
                      ),
                      onPressed: () => onFavoriteToggle(r.id, r.favorito),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Opciones',
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        // sin borde gris: side comentado
                        // side: BorderSide(
                        //   color: Theme.of(context).dividerColor.withOpacity(0.3),
                        //   width: 1,
                        // ),
                      ),
                      onSelected: (value) async {
                        if (value == 'editar') {
                          onEdit(r);
                        } else if (value == 'eliminar') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  title: const Text('Eliminar disco'),
                                  content: const Text(
                                    '¿Seguro que quieres eliminar este disco?',
                                  ),
                                  actionsPadding: const EdgeInsets.fromLTRB(
                                    24,
                                    16,
                                    24,
                                    24,
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    const SizedBox(width: 32),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: Text(
                                        'Eliminar',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            onDelete(r.id);
                            // éxito
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          size: 48,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Disco eliminado correctamente',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                            await Future.delayed(const Duration(seconds: 2));
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          }
                        }
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
            ),
          ),
        );
      },
    );
  }
}
