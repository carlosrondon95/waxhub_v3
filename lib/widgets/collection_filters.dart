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
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortByChanged,
    required this.showFavorites,
    required this.onShowFavoritesChanged,
    required this.viewMode,
    required this.onViewModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 8),
          // Dropdowns and toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sort by dropdown
              DropdownButton<String>(
                value: sortBy,
                onChanged: (value) {
                  if (value != null) onSortByChanged(value);
                },
                items: const [
                  DropdownMenuItem(value: 'titulo', child: Text('Título')),
                  DropdownMenuItem(value: 'artista', child: Text('Artista')),
                  DropdownMenuItem(value: 'anio', child: Text('Año')),
                ],
              ),
              // View mode dropdown
              DropdownButton<String>(
                value: viewMode,
                onChanged: (value) {
                  if (value != null) onViewModeChanged(value);
                },
                items: const [
                  DropdownMenuItem(value: 'lista', child: Text('Lista')),
                  DropdownMenuItem(
                    value: 'cuadricula',
                    child: Text('Cuadrícula'),
                  ),
                  DropdownMenuItem(value: 'carrusel', child: Text('Carrusel')),
                ],
              ),
              // Favorites toggle
              ElevatedButton(
                onPressed: () => onShowFavoritesChanged(!showFavorites),
                child: Text(showFavorites ? 'Todos' : 'Favoritos'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
