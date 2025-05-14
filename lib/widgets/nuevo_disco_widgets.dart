import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/discogs_service.dart';

/* ─── ARTISTA ──────────────────────────────────────────── */
class ArtistAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final void Function(ArtistResult) onArtistSelected;
  const ArtistAutocomplete({
    super.key,
    required this.controller,
    required this.onArtistSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<ArtistResult>(
      suggestionsCallback:
          (q) => q.length < 2 ? [] : DiscogsService().searchArtists(q),
      itemBuilder: (_, a) => ListTile(title: Text(a.name)),
      onSelected: (a) {
        controller.text = a.name; // texto con mayúsculas y “&”
        onArtistSelected(a);
      },
      emptyBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Sin coincidencias'),
          ),
      builder:
          (context, textCtrl, focus) => TextField(
            controller: textCtrl, // ← ¡usar el que da TypeAhead!
            focusNode: focus,
            decoration: const InputDecoration(labelText: 'Artista'),
            textInputAction: TextInputAction.next,
          ),
    );
  }
}

/* ─── TÍTULO ───────────────────────────────────────────── */
class TitleAutocomplete extends StatelessWidget {
  final bool enabled;
  final int artistId;
  final TextEditingController controller;
  final void Function(ReleaseResult) onTitleSelected;
  const TitleAutocomplete({
    super.key,
    required this.enabled,
    required this.artistId,
    required this.controller,
    required this.onTitleSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return TextFormField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Título'),
        enabled: false,
      );
    }
    return TypeAheadField<ReleaseResult>(
      suggestionsCallback:
          (q) =>
              q.isEmpty
                  ? []
                  : DiscogsService().searchVinylsOfArtist(artistId, q),
      itemBuilder:
          (_, r) => ListTile(
            leading:
                r.thumb.isNotEmpty ? Image.network(r.thumb, width: 40) : null,
            title: Text(r.title),
          ),
      onSelected: (r) {
        controller.text = r.title; // texto exacto
        onTitleSelected(r);
      },
      emptyBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Sin coincidencias'),
          ),
      builder:
          (context, textCtrl, focus) => TextField(
            controller: textCtrl, // ← importante
            focusNode: focus,
            decoration: const InputDecoration(labelText: 'Título'),
            textInputAction: TextInputAction.next,
          ),
    );
  }
}

/* ─── INPUT GENÉRICO ───────────────────────────────────── */
class DiscoFormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obligatorio;
  final TextInputType keyboardType;
  const DiscoFormInput({
    super.key,
    required this.controller,
    required this.label,
    this.obligatorio = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: keyboardType,
    validator:
        obligatorio
            ? (v) => v == null || v.isEmpty ? 'Campo requerido' : null
            : null,
  );
}

/* ─── PORTADA (sin cambios) ───────────────────────────── */
class CoverSelector extends StatelessWidget {
  final String? coverUrl;
  final VoidCallback onPickImage;
  const CoverSelector({
    super.key,
    required this.coverUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (coverUrl != null && coverUrl!.isNotEmpty)
          Image.network(
            coverUrl!,
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
          onPressed: onPickImage,
          child: const Text('Cargar portada'),
        ),
      ],
    );
  }
}
