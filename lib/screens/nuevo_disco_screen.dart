import 'package:flutter/material.dart';
import '../services/discogs_service.dart';
import '../widgets/nuevo_disco_widgets.dart';

class NuevoDiscoScreen extends StatelessWidget {
  final TextEditingController artistCtr;
  final TextEditingController titleCtr;
  final TextEditingController genreCtr;
  final TextEditingController yearCtr;
  final TextEditingController labelCtr;
  final TextEditingController buyCtr;
  final TextEditingController descCtr;

  final bool titleEnabled;
  final int? artistId;
  final String? coverUrl;

  final void Function(ArtistResult) onArtistSelected;
  final void Function(ReleaseResult) onTitleSelected;
  final VoidCallback onPickImage;
  final VoidCallback onSave;

  const NuevoDiscoScreen({
    super.key,
    required this.artistCtr,
    required this.titleCtr,
    required this.genreCtr,
    required this.yearCtr,
    required this.labelCtr,
    required this.buyCtr,
    required this.descCtr,
    required this.titleEnabled,
    required this.artistId,
    required this.coverUrl,
    required this.onArtistSelected,
    required this.onTitleSelected,
    required this.onPickImage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ArtistAutocomplete(
          controller: artistCtr,
          onArtistSelected: onArtistSelected,
        ),
        const SizedBox(height: 12),
        TitleAutocomplete(
          enabled: titleEnabled,
          artistId: artistId ?? 0,
          controller: titleCtr,
          onTitleSelected: onTitleSelected,
        ),
        const SizedBox(height: 12),
        DiscoFormInput(controller: genreCtr, label: 'Género'),
        const SizedBox(height: 12),
        DiscoFormInput(
          controller: yearCtr,
          label: 'Año',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        DiscoFormInput(controller: labelCtr, label: 'Sello'),
        const SizedBox(height: 12),
        DiscoFormInput(
          controller: buyCtr,
          label: 'Lugar de compra',
          obligatorio: false,
        ), // ← opcional
        const SizedBox(height: 12),
        DiscoFormInput(
          controller: descCtr,
          label: 'Descripción',
          obligatorio: false,
        ), // ← opcional
        const SizedBox(height: 24),
        CoverSelector(coverUrl: coverUrl, onPickImage: onPickImage),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onSave, child: const Text('Guardar disco')),
      ],
    );
  }
}
