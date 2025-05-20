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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    );

    // Ancho fijo razonable para los desplegables
    const dropdownWidth = 160.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Buscador
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Controles con ancho fijo en desplegables
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Dropdown “Ordenar por” con ancho fijo
                SizedBox(
                  width: dropdownWidth,
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: InputDecoration(
                      labelText: 'Ordenar por',
                      isDense: true,
                      border: border,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (v) {
                      if (v != null) onSortByChanged(v);
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'titulo', child: Text('Título')),
                      DropdownMenuItem(
                          value: 'artista', child: Text('Artista')),
                      DropdownMenuItem(value: 'anio', child: Text('Año')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Dropdown “Vista” con mismo ancho fijo
                SizedBox(
                  width: dropdownWidth,
                  child: DropdownButtonFormField<String>(
                    value: viewMode,
                    decoration: InputDecoration(
                      labelText: 'Vista',
                      isDense: true,
                      border: border,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (v) {
                      if (v != null) onViewModeChanged(v);
                    },
                    items: const [
                      DropdownMenuItem(value: 'lista', child: Text('Lista')),
                      DropdownMenuItem(
                          value: 'cuadricula', child: Text('Cuadrícula')),
                      DropdownMenuItem(value: 'carrusel', child: Text('Carrusel')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Botón “Favoritos” sin icono
                ElevatedButton(
                  onPressed: () => onShowFavoritesChanged(!showFavorites),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(showFavorites ? 'Todos' : 'Favoritos'),
                ),
              ],
            ),
          ),

          // Espacio extra antes del contenido
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}