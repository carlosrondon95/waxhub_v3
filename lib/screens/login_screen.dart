import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/input_form_field.dart';
import '../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final auth = context.read<AuthProvider>();
    final dialogEmailCtrl = TextEditingController(text: _emailCtrl.text);

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Restablecer contraseña'),
            content: TextField(
              controller: dialogEmailCtrl,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'Introduce tu email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final error = await auth.sendPasswordReset(
                    dialogEmailCtrl.text.trim(),
                  );
                  final msg =
                      error ??
                      'Correo de restablecimiento enviado correctamente.';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    final auth = context.read<AuthProvider>();

    return Scaffold(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Correo electrónico
              InputFormField(
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                hint: 'Introduce tu correo',
              ),
              const SizedBox(height: 10),

              // Contraseña
              InputFormField(
                label: 'Contraseña',
                icon: Icons.lock_outline,
                controller: _passCtrl,
                hint: 'Introduce tu contraseña',
                obscure: true,
              ),
              const SizedBox(height: 10),

              // Recuérdame & Olvidaste tu contraseña
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged:
                            (v) => setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('Recuérdame'),
                    ],
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TextButton(
                      onPressed: _resetPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Color(0xFF2D79F3)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón Entrar
              ElevatedButton(
                onPressed: () async {
                  final err = await auth.signIn(
                    _emailCtrl.text.trim(),
                    _passCtrl.text,
                  );
                  if (err != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(err)));
                  }
                  // al iniciar sesión, FirebaseAuth refresca authStateChanges()
                  // y tu router redirigirá automáticamente a la pantalla “home”.
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 10),

              // Enlace a registro
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: () => context.pushNamed('register'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(color: Color(0xFF2D79F3)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('O con'),
              const SizedBox(height: 10),

              // Botón Google
              const GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
