// lib/screens/settings/settings_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';

class SettingsMenuScreen extends StatelessWidget {
  const SettingsMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(30),
          decoration: _box,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tile(
                context,
                Icons.person_outline,
                'Información de la cuenta',
                () => context.pushNamed('cuenta'),
              ),
              _tile(context, Icons.palette_outlined, 'Tema y apariencia', () {
                /* pendiente */
              }),
              _tile(context, Icons.language_outlined, 'Idioma', () {
                /* pendiente */
              }),
              _tile(
                context,
                Icons.notifications_outlined,
                'Notificaciones',
                () {
                  /* pendiente */
                },
              ),
              /*_tile(
                context,
                Icons.lock_outline,
                'Privacidad',
                () {/* pendiente */},
              ),*/
              _tile(
                context,
                Icons.upload_file_outlined,
                'Exportar / Importar',
                () {
                  /* pendiente */
                },
              ),
              _tile(context, Icons.info_outline, 'Acerca de', () {
                /* pendiente */
              }),
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
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  static const _box = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );
}
