import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/summary_provider.dart';

class InformeUsoScreen extends StatefulWidget {
  const InformeUsoScreen({Key? key}) : super(key: key);

  @override
  State<InformeUsoScreen> createState() => _InformeUsoScreenState();
}

class _InformeUsoScreenState extends State<InformeUsoScreen> {
  final List<Map<String, dynamic>> _options = [
    {'label': '7 días', 'days': 7},
    {'label': '30 días', 'days': 30},
    {'label': '1 año', 'days': 365},
  ];
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    await context.read<SummaryProvider>().loadSummary(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    final summaryProv = context.watch<SummaryProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Informe de uso')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de periodo
              ListTile(
                leading: Icon(Icons.date_range, color: primaryColor),
                title: const Text('Periodo'),
                trailing: DropdownButton<int>(
                  value: _selectedDays,
                  items:
                      _options.map((opt) {
                        return DropdownMenuItem<int>(
                          value: opt['days'] as int,
                          child: Text(opt['label'] as String),
                        );
                      }).toList(),
                  onChanged: (days) {
                    if (days == null || days == _selectedDays) return;
                    setState(() => _selectedDays = days);
                    _loadSummary();
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (summaryProv.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Texto "Últimos ... días" más grande
                Center(
                  child: Text(
                    'Últimos $_selectedDays días',
                    style: textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                // Métricas
                Row(
                  children: [
                    Icon(Icons.library_music, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Añadidos: ${summaryProv.addedCount}',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Favoritos: ${summaryProv.favoritedCount}',
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Botón actualizar más pequeño
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _loadSummary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
