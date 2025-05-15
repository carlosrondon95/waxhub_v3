import 'package:flutter/material.dart';
import '../models/vinyl_record.dart';
import '../core/image_proxy.dart'; // 👈

class CollectionGrid extends StatelessWidget {
  final List<VinylRecord> records;
  final void Function(VinylRecord) onTap;
  const CollectionGrid({Key? key, required this.records, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: records.length,
      itemBuilder: (_, idx) {
        final disco = records[idx];
        return GestureDetector(
          onTap: () => onTap(disco),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    proxiedImage(disco.portadaUrl), // 👈
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                disco.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
