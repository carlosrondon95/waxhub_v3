import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../services/discogs_service.dart';
import '../providers/vinyl_provider.dart';

class NuevoDiscoForm extends StatelessWidget {
  const NuevoDiscoForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vinyl = context.watch<VinylProvider>();

    return ListView(
      children: [
        // Autocomplete Artista
        TypeAheadField<ArtistResult>(
          builder: (context, textCtrl, focusNode) {
            return TextFormField(
              controller: textCtrl,
              focusNode: focusNode,
              decoration: const InputDecoration(labelText: 'Artista'),
              validator:
                  (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
            );
          },
          suggestionsCallback:
              (q) => q.length < 2 ? [] : vinyl.searchArtists(q),
          itemBuilder: (_, a) => ListTile(title: Text(a.name)),
          onSelected: vinyl.selectArtist,
          emptyBuilder:
              (_) => const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Sin coincidencias'),
              ),
        ),
        const SizedBox(height: 12),

        // Autocomplete Título
        vinyl.selectedArtist == null
            ? TextFormField(
              controller: vinyl.titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              enabled: false,
            )
            : TypeAheadField<ReleaseResult>(
              builder: (context, textCtrl, focusNode) {
                return TextFormField(
                  controller: textCtrl,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                );
              },
              suggestionsCallback:
                  (q) => q.isEmpty ? [] : vinyl.searchReleases(q),
              itemBuilder:
                  (_, r) => ListTile(
                    leading:
                        r.thumb.isNotEmpty
                            ? Image.network(r.thumb, width: 40)
                            : null,
                    title: Text(r.title),
                  ),
              onSelected: vinyl.selectRelease,
              emptyBuilder:
                  (_) => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Sin coincidencias'),
                  ),
            ),
        const SizedBox(height: 12),

        // Género
        TextFormField(
          controller: vinyl.genreController,
          decoration: const InputDecoration(labelText: 'Género'),
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 12),

        // Año
        TextFormField(
          controller: vinyl.yearController,
          decoration: const InputDecoration(labelText: 'Año'),
          keyboardType: TextInputType.number,
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 12),

        // Sello
        TextFormField(
          controller: vinyl.labelController,
          decoration: const InputDecoration(labelText: 'Sello'),
          validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 12),

        // Lugar de compra (opcional)
        TextFormField(
          controller: vinyl.buyController,
          decoration: const InputDecoration(labelText: 'Lugar de compra'),
        ),
        const SizedBox(height: 12),

        // Descripción (opcional)
        TextFormField(
          controller: vinyl.descController,
          decoration: const InputDecoration(labelText: 'Descripción'),
          maxLines: null,
        ),
        const SizedBox(height: 24),

        // Selector de portada
        Column(
          children: [
            if (vinyl.coverUrl != null && vinyl.coverUrl!.isNotEmpty)
              Image.network(
                vinyl.coverUrl!,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 80),
              )
            else
              Container(
                height: 150,
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

        // Botón Guardar
        ElevatedButton(
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
      ],
    );
  }
}
