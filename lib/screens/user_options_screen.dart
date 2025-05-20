// lib/screens/user_options_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_service.dart';
import '../widgets/change_name_section.dart';
import '../widgets/change_password_section.dart';

class UserOptionsScreen extends StatefulWidget {
  const UserOptionsScreen({Key? key}) : super(key: key);

  @override
  State<UserOptionsScreen> createState() => _UserOptionsScreenState();
}

class _UserOptionsScreenState extends State<UserOptionsScreen> {
  final _svc = UserService();
  String _currentName = '';
  bool _canChangeName = false;
  bool _isGoogle = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await _svc.loadUserInfo();
    setState(() {
      _currentName = info['nombre'] as String;
      _canChangeName = !(info['nombreCambiado'] as bool);
      _isGoogle = info['isGoogle'] as bool;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    const maxWidth = 450.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Opciones de Usuario')),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre actual
                const Text(
                  'Nombre actual',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF151717),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: _currentName),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: _currentName,
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Secciones modulares
                ChangeNameSection(
                  initialName: _currentName,
                  canChange: _canChangeName,
                  onSaved: _load,
                ),
                const SizedBox(height: 20),
                ChangePasswordSection(isGoogle: _isGoogle),
                const SizedBox(height: 20),

                // Logout directo en pantalla
                ElevatedButton(
                  onPressed: () async {
                    await _svc.logout();
                    GoRouter.of(ctx).go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
