import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/auth_provider.dart';
import '/widgets/fields/input_form_field.dart';
import '/widgets/fields/password_field.dart';

/// Alerta reutilizable
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.length < 7) return 'Mínimo 7 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe incluir una mayúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe incluir un número';
    return null;
  }

  Future<void> _handleRegister() async {
    // Validaciones locales
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _nameError = null;
      _emailError = null;
    });

    final auth = context.read<AuthProvider>();

    // Validaciones en Firestore
    if (await auth.usernameExists(_nameCtrl.text)) {
      setState(() => _nameError = 'Ese nombre ya está en uso');
    }
    if (await auth.emailExists(_emailCtrl.text)) {
      setState(() => _emailError = 'Ese correo ya está registrado');
    }
    if (_nameError != null || _emailError != null) return;

    // Registro
    final error = await auth.register(
      _nameCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
    );

    if (error != null) {
      await _showAlert(context, error);
    } else {
      await _showAlert(
        context,
        'Registro exitoso. Revisa tu correo para verificar.',
        success: true,
      );
      if (!mounted) return;

      // Limpiar formulario y campos
      _formKey.currentState?.reset();
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      _confirmCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    const maxWidth = 450.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
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
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputFormField(
                      label: 'Nombre de usuario',
                      icon: Icons.person_outline,
                      controller: _nameCtrl,
                      hint: 'Introduce tu nombre',
                    ),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _nameError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    InputFormField(
                      label: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      hint: 'Introduce tu correo',
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _emailError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passCtrl,
                      validator: _passwordValidator,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmCtrl,
                      label: 'Confirmar contraseña',
                      validator:
                          (v) => v != _passCtrl.text ? 'No coinciden' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                          auth.isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Registrarse'),
                    ),
                  ],
                ),
              ),
              if (auth.isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
