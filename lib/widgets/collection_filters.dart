// lib/widgets/collection_filters.dart
import 'package:flutter/material.dart';

class CollectionFilters extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String sortBy;
  final ValueChanged<String> onSortByChanged;
  final bool showFavorites;
  final ValueChanged<bool> onShowFavoritesChanged;
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;

  const CollectionFilters({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.showFavorites,
    required this.onShowFavoritesChanged,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // — Buscador en su propia fila —feo
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          // — Controles (Ordenar, Vista, Favoritos) debajo —
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: sortBy,
                  onChanged: (v) => v != null ? onSortByChanged(v) : null,
                  items: const [
                    DropdownMenuItem(value: 'titulo', child: Text('Título')),
                    DropdownMenuItem(value: 'artista', child: Text('Artista')),
                    DropdownMenuItem(value: 'anio', child: Text('Año')),
                  ],
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: viewMode,
                  onChanged: (v) => v != null ? onViewModeChanged(v) : null,
                  items: const [
                    DropdownMenuItem(value: 'lista', child: Text('Lista')),
                    DropdownMenuItem(
                      value: 'cuadricula',
                      child: Text('Cuadrícula'),
                    ),
                    DropdownMenuItem(
                      value: 'carrusel',
                      child: Text('Carrusel'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => onShowFavoritesChanged(!showFavorites),
                  icon: Icon(showFavorites ? Icons.star : Icons.star_border),
                  label: Text(showFavorites ? 'Todos' : 'Favoritos'),
                ),
              ],
            ),
          ),
        ],
      ), //tonto
    );
  }
}
