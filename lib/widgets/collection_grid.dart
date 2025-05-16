// lib/widgets/collection_grid.dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../models/vinyl_record.dart';
import '../core/image_proxy.dart';

class CollectionGrid extends StatelessWidget {
  final List<VinylRecord> records;
  final void Function(VinylRecord) onTap;

  const CollectionGrid({super.key, required this.records, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bp = ResponsiveBreakpoints.of(context);

    int cols = 2;
    if (bp.largerThan(TABLET)) cols = 3;
    if (bp.largerThan(DESKTOP)) cols = 5;

    const aspectRatio = 0.8;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final r = records[i];
        return GestureDetector(
          onTap: () => onTap(r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portada 1:1
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    proxiedImage(r.portadaUrl),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Título
              Flexible(
                child: Text(
                  r.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              // Artista
              Flexible(
                child: Text(
                  r.artista,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              // Año
              Text(
                r.anio,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
