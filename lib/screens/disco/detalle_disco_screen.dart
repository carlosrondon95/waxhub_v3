// lib/screens/detalle_disco_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/models/vinyl_record.dart';
import '/providers/collection_provider.dart';
import '/core/image_proxy.dart';

class DetalleDiscoScreen extends StatelessWidget {
  final VinylRecord record;
  const DetalleDiscoScreen({super.key, required this.record});

  static const double _buttonWidth = 140;
  static const double _buttonHeight = 48;

  Future<void> _safeLaunch(BuildContext context, Uri url) async {
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  Future<void> _launchSpotifySearch(
    BuildContext context,
    String artist,
    String album,
  ) async {
    final query = Uri.encodeComponent('$artist $album');
    await _safeLaunch(
      context,
      Uri.parse('https://open.spotify.com/search/$query'),
    );
  }

  Future<void> _launchYouTubeSearch(
    BuildContext context,
    String artist,
    String album,
  ) async {
    final query = Uri.encodeComponent('$artist $album full album');
    await _safeLaunch(
      context,
      Uri.parse('https://www.youtube.com/results?search_query=$query'),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    CollectionProvider coll,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            title: const Text('Eliminar disco'),
            content: const Text(
              '¿Seguro que quieres eliminar este disco de tu colección?',
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await coll.deleteRecord(record.id);
      // éxito como dialog estilizado
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Disco eliminado correctamente',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // cierra éxito
        context.pop(); // vuelve atrás
      }
    }
  }

  Widget _platformButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        fixedSize: const Size(_buttonWidth, _buttonHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      onPressed: onPressed,
      icon: FaIcon(icon, size: 20),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    final updated = collection.allRecords.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(updated.titulo),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opciones',
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            onSelected: (value) {
              if (value == 'editar') {
                context.pushNamed('editar_disco', extra: updated);
              } else if (value == 'eliminar') {
                _confirmAndDelete(context, collection);
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
      floatingActionButton: FloatingActionButton(
        tooltip:
            updated.favorito ? 'Quitar de favoritos' : 'Marcar como favorito',
        onPressed:
            () => collection.toggleFavorite(updated.id, updated.favorito),
        child: Icon(updated.favorito ? Icons.favorite : Icons.favorite_border),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            updated.titulo,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              proxiedImage(updated.portadaUrl),
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 120),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _InfoTile(
                          icon: Icons.person,
                          label: 'Artista',
                          value: updated.artista,
                        ),
                        _InfoTile(
                          icon: Icons.album,
                          label: 'Título',
                          value: updated.titulo,
                        ),
                        _InfoTile(
                          icon: Icons.music_note,
                          label: 'Género',
                          value: updated.genero,
                        ),
                        _InfoTile(
                          icon: Icons.calendar_today,
                          label: 'Año',
                          value: updated.anio,
                        ),
                        _InfoTile(
                          icon: Icons.library_music,
                          label: 'Sello',
                          value: updated.sello,
                        ),
                        if (updated.lugarCompra.isNotEmpty)
                          _InfoTile(
                            icon: Icons.store_mall_directory,
                            label: 'Adquirido en',
                            value: updated.lugarCompra,
                          ),
                        if (updated.descripcion.isNotEmpty)
                          _InfoTile(
                            icon: Icons.description,
                            label: 'Descripción',
                            value: updated.descripcion,
                          ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _platformButton(
                              color: const Color(0xFF1DB954),
                              icon: FontAwesomeIcons.spotify,
                              label: 'Spotify',
                              onPressed:
                                  () => _launchSpotifySearch(
                                    context,
                                    updated.artista,
                                    updated.titulo,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            _platformButton(
                              color: Colors.redAccent,
                              icon: FontAwesomeIcons.youtube,
                              label: 'YouTube',
                              onPressed:
                                  () => _launchYouTubeSearch(
                                    context,
                                    updated.artista,
                                    updated.titulo,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
