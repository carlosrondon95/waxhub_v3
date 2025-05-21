// lib/screens/collection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/collection_provider.dart';
import '../widgets/collection_filters.dart';
import '../widgets/collection_list.dart';
import '../widgets/collection_grid.dart';
import '../widgets/collection_carousel.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      // Dejamos que el tema marque el color de fondo (claro u oscuro).
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mi Colección')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /* ────────────  Filtros y búsqueda  ──────────── */
            CollectionFilters(
              searchQuery: collection.searchQuery,
              onSearchChanged: collection.setSearchQuery,
              sortBy: collection.sortBy,
              onSortByChanged: collection.setSortBy,
              showFavorites: collection.showFavorites,
              onShowFavoritesChanged: collection.setShowFavorites,
              viewMode: collection.viewMode,
              onViewModeChanged: collection.setViewMode,
            ),

            /* ─────────────  Contenido / Spinner  ───────────── */
            Expanded(
              child:
                  collection.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Builder(
                        builder: (_) {
                          final items = collection.filteredRecords;
                          switch (collection.viewMode) {
                            case 'cuadricula':
                              return CollectionGrid(
                                records: items,
                                onTap:
                                    (r) => context.pushNamed(
                                      'detalle_disco',
                                      extra: r,
                                    ),
                              );
                            case 'carrusel':
                              return CollectionCarousel(records: items);
                            case 'lista':
                            default:
                              return CollectionList(
                                records: items,
                                onTap:
                                    (r) => context.pushNamed(
                                      'detalle_disco',
                                      extra: r,
                                    ),
                                onEdit:
                                    (r) => context.pushNamed(
                                      'editar_disco',
                                      extra: r,
                                    ),
                                onDelete: collection.deleteRecord,
                                onFavoriteToggle: collection.toggleFavorite,
                              );
                          }
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
