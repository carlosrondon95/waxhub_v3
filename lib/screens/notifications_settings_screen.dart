import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    final cardColor = Theme.of(context).cardColor;
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.1);
    final notif = context.watch<NotificationsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opción: notificar tiendas cercanas
              ListTile(
                leading: Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: const Text('Tiendas cercanas'),
                trailing: Switch(
                  value: notif.notifyNearbyShops,
                  onChanged: (value) => notif.setNotifyNearbyShops(value),
                ),
              ),
              const SizedBox(height: 16),
              // Opción: intervalo de envío de resumen
              ListTile(
                leading: Icon(
                  Icons.schedule_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: const Text('Informe de uso'),
                trailing: DropdownButton<int>(
                  value: notif.summaryIntervalDays,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Diario')),
                    DropdownMenuItem(value: 7, child: Text('Semanal')),
                    DropdownMenuItem(value: 14, child: Text('Cada 2 semanas')),
                    DropdownMenuItem(value: 30, child: Text('Mensual')),
                  ],
                  onChanged: (days) {
                    if (days != null) notif.setSummaryIntervalDays(days);
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
