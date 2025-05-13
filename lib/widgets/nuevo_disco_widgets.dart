import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/discogs_service.dart';

/* ─── Artista ───────────────────────────────────────────── */
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
    return TypeAheadFormField<ArtistResult>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Artista'),
      ),
      suggestionsCallback:
          (pattern) =>
              pattern.length < 2 ? [] : DiscogsService().searchArtists(pattern),
      itemBuilder: (_, a) => ListTile(title: Text(a.name)),
      onSuggestionSelected: onArtistSelected,
      noItemsFoundBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sin coincidencias'),
          ),
      validator: (v) => v == null || v.isEmpty ? 'Introduce un artista' : null,
    );
  }
}

/* ─── Título ────────────────────────────────────────────── */
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
    return TypeAheadFormField<ReleaseResult>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Título'),
      ),
      suggestionsCallback:
          (pattern) =>
              pattern.length < 1
                  ? []
                  : DiscogsService().searchVinylsOfArtist(artistId, pattern),
      itemBuilder:
          (_, r) => ListTile(
            leading:
                r.thumb.isNotEmpty ? Image.network(r.thumb, width: 40) : null,
            title: Text(r.title),
          ),
      onSuggestionSelected: onTitleSelected,
      noItemsFoundBuilder:
          (_) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Sin coincidencias'),
          ),
      validator: (v) => v == null || v.isEmpty ? 'Selecciona un título' : null,
    );
  }
}

/* ─── TextFormField genérico ───────────────────────────── */
class DiscoFormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  const DiscoFormInput({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: keyboardType,
    validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
  );
}

/* ─── Portada ───────────────────────────────────────────── */
/* …imports y demás widgets… */

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
          child: const Text('Seleccionar portada manual'),
        ),
      ],
    );
  }
}
