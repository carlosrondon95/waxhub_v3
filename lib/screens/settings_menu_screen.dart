import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    final cardColor = Theme.of(context).cardColor;
    final shadowColor = Theme.of(context).shadowColor.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
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
              _tile(
                context,
                Icons.person_outline,
                'Información de la cuenta',
                () => context.pushNamed('cuenta'),
              ),
              _tile(
                context,
                Icons.palette_outlined,
                'Tema y apariencia',
                () => context.pushNamed('apariencia'),
              ),
              _tile(
                context,
                Icons.language_outlined,
                'Idioma',
                () => context.pushNamed('idioma'),
              ),
              _tile(
                context,
                Icons.notifications_outlined,
                'Notificaciones',
                () => context.pushNamed('notificaciones'),
              ),
              _tile(
                context,
                Icons.map_outlined,
                'Ajustes de mapa',
                () => context.pushNamed(
                  'mapSettings',
                ), // ← coincide con app_router
              ),
              _tile(
                context,
                Icons.upload_file_outlined,
                'Exportar / Importar',
                () => context.pushNamed('exportImport'),
              ),
              _tile(
                context,
                Icons.info_outline,
                'Acerca de',
                () => context.pushNamed('acerca'),
              ),
              const Divider(height: 32),
              _tile(context, Icons.logout, 'Cerrar sesión', () async {
                await UserService().logout();
                context.goNamed('login');
              }),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _tile(
    BuildContext ctx,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(ctx).iconTheme.color),
      title: Text(text, style: Theme.of(ctx).textTheme.bodyLarge),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(ctx).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}
