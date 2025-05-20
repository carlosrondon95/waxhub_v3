 // lib/widgets/collection_carousel.dart
import 'package:flutter/material.dart';
import '../models/vinyl_record.dart';

class CollectionCarousel extends StatelessWidget {
  final List<VinylRecord> records;

  const CollectionCarousel({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('No hay discos'));
    }
    return PageView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final disco = records[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen con máximo tamaño y sin recortar
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.network(
                disco.portadaUrl,
                fit: BoxFit.contain, // mantiene proporción completa
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 80),
              ),
            ),
            const SizedBox(height: 16),
            Text(disco.artista, style: Theme.of(context).textTheme.titleMedium),
            Text(disco.titulo, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              '(${disco.anio})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
