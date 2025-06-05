// lib/widgets/nuevo_disco_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/models/artist_result.dart';
import '/models/release_result.dart';
import '/providers/vinyl_provider.dart';
import '/core/image_proxy.dart';

Future<void> _showAlert(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                size: 48,
                color:
                    success
                        ? Theme.of(context).colorScheme.primary
                        : Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

class NuevoDiscoForm extends StatelessWidget {
  const NuevoDiscoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vinyl = context.watch<VinylProvider>();
    final bp = ResponsiveBreakpoints.of(context);
    final isDesktop = bp.largerThan(TABLET);

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // —— Línea 1: Artista + Título ——
              ResponsiveRowColumn(
                layout:
                    isDesktop
                        ? ResponsiveRowColumnType.ROW
                        : ResponsiveRowColumnType.COLUMN,
                columnSpacing: 12,
                rowSpacing: 12,
                children: [
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: _ArtistField(vinyl: vinyl),
                  ),
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: _TitleField(vinyl: vinyl),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // —— Línea 2: Género + Año ——
              ResponsiveRowColumn(
                layout:
                    isDesktop
                        ? ResponsiveRowColumnType.ROW
                        : ResponsiveRowColumnType.COLUMN,
                columnSpacing: 12,
                rowSpacing: 12,
                children: [
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: TextFormField(
                      controller: vinyl.genreController,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        prefixIcon: Icon(Icons.music_note),
                      ),
                      validator: _required,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: TextFormField(
                      controller: vinyl.yearController,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // —— Línea 3: Sello + Procedencia ——
              ResponsiveRowColumn(
                layout:
                    isDesktop
                        ? ResponsiveRowColumnType.ROW
                        : ResponsiveRowColumnType.COLUMN,
                columnSpacing: 12,
                rowSpacing: 12,
                children: [
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: TextFormField(
                      controller: vinyl.labelController,
                      decoration: const InputDecoration(
                        labelText: 'Sello',
                        prefixIcon: Icon(Icons.library_music),
                      ),
                      validator: _required,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: TextFormField(
                      controller: vinyl.buyController,
                      decoration: const InputDecoration(
                        labelText: 'Procedencia',
                        prefixIcon: Icon(Icons.card_giftcard),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // —— Descripción ——
              TextFormField(
                controller: vinyl.descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: null,
              ),

              const SizedBox(height: 24),

              // —— Portada ——
              Column(
                children: [
                  if (vinyl.coverUrl != null && vinyl.coverUrl!.isNotEmpty)
                    Image.network(
                      proxiedImage(vinyl.coverUrl!),
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 80),
                    )
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Sin portada')),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: vinyl.isLoading ? null : vinyl.pickCoverImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Elegir portada manualmente'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // —— Botón Guardar con diálogos ——
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      vinyl.isLoading
                          ? null
                          : () async {
                            // 1) Diálogo de carga
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (_) => const AlertDialog(
                                    content: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text('Añadiendo disco...'),
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );

                            // 2) Guardar
                            final ok = await vinyl.saveRecord();

                            // 3) Cerrar carga
                            Navigator.of(context, rootNavigator: true).pop();

                            if (ok) {
                              // 4) Éxito
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
                                            Icons.check_circle_outline,
                                            size: 48,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Disco añadido a tu colección',
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
                              Navigator.of(context, rootNavigator: true).pop();

                              // 5) Limpiar formulario para seguir añadiendo
                              vinyl.clearForm();
                            } else {
                              // 6) Error
                              await _showAlert(
                                context,
                                'Error al añadir el disco. Intenta de nuevo.',
                              );
                            }
                          },
                  child:
                      vinyl.isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Guardar disco'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // —— Validación genérica ——
  String? _required(String? v) =>
      (v == null || v.isEmpty) ? 'Campo requerido' : null;
}

class _ArtistField extends StatelessWidget {
  final VinylProvider vinyl;
  const _ArtistField({required this.vinyl});

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<ArtistResult>(
      builder:
          (ctx, ctrl, node) => TextFormField(
            controller: ctrl,
            focusNode: node,
            decoration: const InputDecoration(
              labelText: 'Artista',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
      suggestionsCallback: (q) => q.length < 2 ? [] : vinyl.searchArtists(q),
      itemBuilder: (_, a) => ListTile(title: Text(a.name)),
      onSelected: vinyl.selectArtist,
      emptyBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Sin coincidencias'),
          ),
    );
  }
}

class _TitleField extends StatelessWidget {
  final VinylProvider vinyl;
  const _TitleField({required this.vinyl});

  @override
  Widget build(BuildContext context) {
    if (vinyl.selectedArtist == null) {
      return TextFormField(
        controller: vinyl.titleController,
        decoration: const InputDecoration(
          labelText: 'Título',
          prefixIcon: Icon(Icons.album),
        ),
        enabled: false,
      );
    }

    return TypeAheadField<ReleaseResult>(
      builder:
          (ctx, ctrl, node) => TextFormField(
            controller: ctrl,
            focusNode: node,
            decoration: const InputDecoration(
              labelText: 'Título',
              prefixIcon: Icon(Icons.album),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
          ),
      suggestionsCallback: (q) => q.isEmpty ? [] : vinyl.searchReleases(q),
      itemBuilder:
          (_, r) => ListTile(
            leading:
                r.thumb.isNotEmpty
                    ? Image.network(
                      proxiedImage(r.thumb),
                      width: 40,
                      fit: BoxFit.cover,
                    )
                    : null,
            title: Text(r.title),
          ),
      onSelected: vinyl.selectRelease,
      emptyBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Sin coincidencias'),
          ),
    );
  }
}
