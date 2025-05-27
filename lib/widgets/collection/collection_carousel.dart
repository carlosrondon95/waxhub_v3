// lib/widgets/collection_carousel.dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '/models/vinyl_record.dart';
import '/core/image_proxy.dart';

class CollectionCarousel extends StatefulWidget {
  final List<VinylRecord> records;
  const CollectionCarousel({super.key, required this.records});

  @override
  State<CollectionCarousel> createState() => _CollectionCarouselState();
}

class _CollectionCarouselState extends State<CollectionCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return const Center(child: Text('No hay discos'));
    }

    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final heightFactor = isDesktop ? 0.50 : 0.40;

    return PageView.builder(
      controller: _controller,
      itemCount: widget.records.length,
      itemBuilder: (_, index) {
        final d = widget.records[index];
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Imagen ocupa un porcentaje fijo
                SizedBox(
                  height: constraints.maxHeight * heightFactor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Image.network(
                      proxiedImage(d.portadaUrl),
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                ),
                // El resto puede desplazarse si falta espacio
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          d.artista,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.titulo,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(${d.anio})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
