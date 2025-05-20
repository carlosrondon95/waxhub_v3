import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/input_form_field.dart';
import '../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Diálogo para restablecer contraseña
  Future<void> _resetPassword() async {
    final auth = context.read<AuthProvider>();
    final emailDialogCtrl = TextEditingController(text: _emailCtrl.text);

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: TextField(
            controller: emailDialogCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'Introduce tu email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final error = await auth.sendPasswordReset(
                  emailDialogCtrl.text.trim(),
                );
                Navigator.of(dialogCtx).pop(); // cierra diálogo

                if (!mounted) return; // ← evita usar context desmontado
                final msg = error ??
                    'Enlace de recuperación enviado. Revisa tu correo.';
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(msg)));
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  /// Inicia sesión con correo/contraseña
  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    final err = await auth.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    } else {
      // Navega a Home y limpia pila
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;

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
              // ─── Email ──────────────────────────────────────────────
              InputFormField(
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                hint: 'Introduce tu correo',
              ),
              const SizedBox(height: 10),

              // ─── Contraseña ─────────────────────────────────────────
              InputFormField(
                label: 'Contraseña',
                icon: Icons.lock_outline,
                controller: _passCtrl,
                hint: 'Introduce tu contraseña',
                obscure: true,
              ),
              const SizedBox(height: 10),

              // ─── Recuérdame & Olvidaste contraseña ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('Recuérdame'),
                    ],
                  ),
                  TextButton(
                    onPressed: _resetPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Color(0xFF2D79F3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Botón Entrar ──────────────────────────────────────
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 10),

              // ─── Ir a Registro ─────────────────────────────────────
              TextButton(
                onPressed: () => context.pushNamed('register'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(color: Color(0xFF2D79F3)),
                ),
              ),
              const SizedBox(height: 20),

              const Text('O con'),
              const SizedBox(height: 10),

              // ─── Google Sign-In ────────────────────────────────────
              const GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
