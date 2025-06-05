// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/providers/auth_provider.dart';
import '/widgets/fields/input_form_field.dart';
import '/widgets/fields/google_signin_button.dart';

/// Alerta reutilizable (errores)
Future<void> _showAlert(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                size: 48,
                color:
                    success
                        ? Theme.of(context).colorScheme.primary
                        : Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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
    final emailDialogCtrl = TextEditingController(text: _emailCtrl.text);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            'Restablecer contraseña',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
                Navigator.of(dialogCtx).pop();
                if (!mounted) return;
                final msg =
                    error ??
                    'Enlace de recuperación enviado. Revisa tu correo.';
                await _showAlert(context, msg, success: error == null);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    // ­—— Diálogo de carga ——
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            content: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Expanded(child: Text('Iniciando sesión...')),
              ],
            ),
          ),
    );

    final err = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);

    // Cerrar diálogo de carga
    Navigator.of(context, rootNavigator: true).pop();

    if (!mounted) return;
    if (err != null) {
      await _showAlert(context, err);
    } else {
      // Snackbar verde de bienvenida
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido a WaxHub!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pequeña pausa para que se vea
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputFormField(
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                controller: _emailCtrl,
                hint: 'Introduce tu correo',
              ),
              const SizedBox(height: 10),
              InputFormField(
                label: 'Contraseña',
                icon: Icons.lock_outline,
                controller: _passCtrl,
                hint: 'Introduce tu contraseña',
                obscure: true,
              ),
              const SizedBox(height: 10),
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
                      Text(
                        'Recuérdame',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _resetPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              TextButton(
                onPressed: () => context.pushNamed('register'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Regístrate',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Inicia sesión con Google',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              const GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
