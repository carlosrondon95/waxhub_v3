// lib/widgets/collection_filters.dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ResponsiveRowColumn(
        // Fila en desktop, columna en móvil/tablet
        layout:
            isDesktop
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
        rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
        columnSpacing: 12,
        rowSpacing: 12,
        children: [
          // --- Buscador ---
          ResponsiveRowColumnItem(
            rowFlex: 2,
            child: SizedBox(
              width: isDesktop ? 320 : double.infinity,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),

          // --- Ordenar ---
          ResponsiveRowColumnItem(
            child: DropdownButton<String>(
              value: sortBy,
              onChanged: (v) => v != null ? onSortByChanged(v) : null,
              items: const [
                DropdownMenuItem(value: 'titulo', child: Text('Título')),
                DropdownMenuItem(value: 'artista', child: Text('Artista')),
                DropdownMenuItem(value: 'anio', child: Text('Año')),
              ],
            ),
          ),

          // --- Vista ---
          ResponsiveRowColumnItem(
            child: DropdownButton<String>(
              value: viewMode,
              onChanged: (v) => v != null ? onViewModeChanged(v) : null,
              items: const [
                DropdownMenuItem(value: 'lista', child: Text('Lista')),
                DropdownMenuItem(
                  value: 'cuadricula',
                  child: Text('Cuadrícula'),
                ),
                DropdownMenuItem(value: 'carrusel', child: Text('Carrusel')),
              ],
            ),
          ),

          // --- Favoritos / Todos ---
          ResponsiveRowColumnItem(
            child: ElevatedButton.icon(
              icon: Icon(showFavorites ? Icons.star : Icons.star_border),
              label: Text(showFavorites ? 'Todos' : 'Favoritos'),
              onPressed: () => onShowFavoritesChanged(!showFavorites),
            ),
          ),
        ],
      ),
    );
  }
}
