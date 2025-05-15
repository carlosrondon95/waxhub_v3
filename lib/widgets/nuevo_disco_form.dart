// lib/widgets/nuevo_disco_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../services/discogs_service.dart';
import '../providers/vinyl_provider.dart';
import '../core/image_proxy.dart';

class NuevoDiscoForm extends StatelessWidget {
  const NuevoDiscoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vinyl = context.watch<VinylProvider>();
    final bp = ResponsiveBreakpoints.of(context);
    final isDesktop = bp.largerThan(TABLET);

    // Limita el ancho máx. y aplica padding homogéneo
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ------------- Línea 1: Artista + Título -------------
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

            // ------------- Línea 2: Género + Año -------------
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
                    decoration: const InputDecoration(labelText: 'Género'),
                    validator: _required,
                  ),
                ),
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: TextFormField(
                    controller: vinyl.yearController,
                    decoration: const InputDecoration(labelText: 'Año'),
                    keyboardType: TextInputType.number,
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ------------- Línea 3: Sello + Compra -------------
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
                    decoration: const InputDecoration(labelText: 'Sello'),
                    validator: _required,
                  ),
                ),
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: TextFormField(
                    controller: vinyl.buyController,
                    decoration: const InputDecoration(
                      labelText: 'Lugar de compra',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ------------- Descripción -------------
            TextFormField(
              controller: vinyl.descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: null,
            ),
            const SizedBox(height: 24),

            // ------------- Portada -------------
            Column(
              children: [
                if (vinyl.coverUrl != null && vinyl.coverUrl!.isNotEmpty)
                  Image.network(
                    proxiedImage(vinyl.coverUrl),
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
                  child: const Text('Cargar portada'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ------------- Guardar -------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    vinyl.isLoading
                        ? null
                        : () async {
                          final ok = await vinyl.saveRecord();
                          if (ok) Navigator.of(context).pop();
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
    );
  }

  // ------ validadores y campos auxiliares ------

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
            decoration: const InputDecoration(labelText: 'Artista'),
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
        decoration: const InputDecoration(labelText: 'Título'),
        enabled: false,
      );
    }

    return TypeAheadField<ReleaseResult>(
      builder:
          (ctx, ctrl, node) => TextFormField(
            controller: ctrl,
            focusNode: node,
            decoration: const InputDecoration(labelText: 'Título'),
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
