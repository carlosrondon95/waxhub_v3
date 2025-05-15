// lib/widgets/collection_carousel.dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../models/vinyl_record.dart';
import '../core/image_proxy.dart';

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
    final heightFactor =
        isDesktop ? 0.50 : 0.40; // portada algo mayor en desktop

    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.records.length,
          itemBuilder: (_, index) {
            final d = widget.records[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * heightFactor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.network(
                    proxiedImage(d.portadaUrl),
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  d.artista,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  d.titulo,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '(${d.anio})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),

        // Flechas solo en pantallas grandes
        if (isDesktop) ...[
          Positioned(
            left: 8,
            child: _NavArrow(
              icon: Icons.chevron_left,
              onTap:
                  () => _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
            ),
          ),
          Positioned(
            right: 8,
            child: _NavArrow(
              icon: Icons.chevron_right,
              onTap:
                  () => _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
