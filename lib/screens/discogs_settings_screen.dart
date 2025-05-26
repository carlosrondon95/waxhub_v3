// lib/screens/settings/discogs_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/collection_provider.dart';

class DiscogsSettingsScreen extends StatelessWidget {
  const DiscogsSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CollectionProvider>();
    const maxWidth = 450.0;
    final bg = Theme.of(context).cardColor;
    final shadow = Theme.of(context).shadowColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(title: const Text('Discogs')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Importar colección
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Importar mi colección'),
                  onPressed:
                      prov.isLoading
                          ? null
                          : () async {
                            await prov.importFromDiscogs();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Colección importada'),
                              ),
                            );
                          },
                ),
              ),

              const SizedBox(height: 16),

              // Actualizar manualmente
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.update),
                  label: const Text('Actualizar manualmente'),
                  onPressed:
                      prov.isLoading
                          ? null
                          : () async {
                            await prov.updateFromDiscogs();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Colección actualizada'),
                              ),
                            );
                          },
                ),
              ),

              const Divider(height: 32),

              // Modo de sincronización
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sincronización automática'),
                trailing: DropdownButton<SyncMode>(
                  value: prov.discogsSyncMode,
                  items: const [
                    DropdownMenuItem(
                      value: SyncMode.manual,
                      child: Text('Solo manual'),
                    ),
                    DropdownMenuItem(
                      value: SyncMode.auto,
                      child: Text('Automática'),
                    ),
                  ],
                  onChanged: (SyncMode? m) {
                    if (m != null) prov.setDiscogsSyncMode(m);
                  },
                ),
              ),

              if (prov.discogsSyncMode == SyncMode.auto) ...[
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Intervalo (horas)'),
                  subtitle: Slider(
                    min: 1,
                    max: 168,
                    divisions: 167,
                    label: '${prov.discogsAutoSyncHours} h',
                    value: prov.discogsAutoSyncHours.toDouble(),
                    onChanged: (v) => prov.setDiscogsAutoSyncHours(v.toInt()),
                  ),
                  trailing: Text('${prov.discogsAutoSyncHours} h'),
                ),
              ],

              const SizedBox(height: 24),

              // Guardar ajustes
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar ajustes'),
                  onPressed: () async {
                    await prov.saveDiscogsSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ajustes guardados')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
