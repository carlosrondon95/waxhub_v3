// lib/screens/collection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(title: const Text('Mi Colección')),
      body: Column(
        children: [
          // Filtros y búsqueda
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
          if (collection.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Builder(
                builder: (_) {
                  final items = collection.filteredRecords;
                  switch (collection.viewMode) {
                    case 'cuadricula':
                      return CollectionGrid(
                        records: items,
                        onTap:
                            (r) => Navigator.pushNamed(
                              context,
                              '/detalle_disco',
                              arguments: r,
                            ),
                      );
                    case 'carrusel':
                      return CollectionCarousel(records: items);
                    case 'lista':
                    default:
                      return CollectionList(
                        records: items,
                        onTap:
                            (r) => Navigator.pushNamed(
                              context,
                              '/detalle_disco',
                              arguments: r,
                            ),
                        onEdit:
                            (r) => Navigator.pushNamed(
                              context,
                              '/editar_disco',
                              arguments: r,
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
    );
  }
}
