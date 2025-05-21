import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showButtons = false;

  void _toggleButtons() {
    setState(() => _showButtons = !_showButtons);
  }

  void _goTo(BuildContext context, String route) {
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const duration = Duration(milliseconds: 400);
    const double topOffset = 0.65; // desplazamiento para filas superior
    const double bottomLeftOffset =
        0.75; // desplazamiento para 'Tiendas Cercanas'
    const double bottomRightOffset =
        0.55; // desplazamiento ajustado para 'Ajustes' a la izquierda

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left icon
            AnimatedAlign(
              duration: duration,
              alignment:
                  _showButtons
                      ? const Alignment(-topOffset, -0.4)
                      : Alignment.center,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showButtons ? 1 : 0,
                child: _IconLabel(
                  icon: Icons.add,
                  label: 'Añadir Disco',
                  color: colorScheme.primary,
                  onTap: () => _goTo(context, '/nuevo_disco'),
                ),
              ),
            ),

            // Top-right icon
            AnimatedAlign(
              duration: duration,
              alignment:
                  _showButtons
                      ? const Alignment(topOffset, -0.4)
                      : Alignment.center,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showButtons ? 1 : 0,
                child: _IconLabel(
                  icon: Icons.collections,
                  label: 'Ver Colección',
                  color: colorScheme.primary,
                  onTap: () => _goTo(context, '/coleccion'),
                ),
              ),
            ),

            // Bottom-left icon (Tiendas Cercanas)
            AnimatedAlign(
              duration: duration,
              alignment:
                  _showButtons
                      ? const Alignment(-bottomLeftOffset, 0.4)
                      : Alignment.center,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showButtons ? 1 : 0,
                child: _IconLabel(
                  icon: Icons.map,
                  label: 'Tiendas Cercanas',
                  color: colorScheme.primary,
                  onTap: () => _goTo(context, '/mapa_tiendas'),
                ),
              ),
            ),

            // Bottom-right icon (Ajustes)
            AnimatedAlign(
              duration: duration,
              alignment:
                  _showButtons
                      ? const Alignment(bottomRightOffset, 0.4)
                      : Alignment.center,
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showButtons ? 1 : 0,
                child: _IconLabel(
                  icon: Icons.settings,
                  label: 'Ajustes',
                  color: colorScheme.primary,
                  onTap: () => _goTo(context, '/ajustes'),
                ),
              ),
            ),

            // Center logo/disco (siempre fijo)
            Center(
              child: GestureDetector(
                onTap: _toggleButtons,
                child: Image.asset('assets/images/waxhub.png', height: 150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  static const double _iconSize = 50;

  const _IconLabel({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _iconSize, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
