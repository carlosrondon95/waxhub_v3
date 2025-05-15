// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.length < 7) return 'Mínimo 7 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe incluir una mayúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe incluir un número';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de usuario')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Crea tu cuenta',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Nombre de usuario con validación en tiempo real
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      errorText: _nameError,
                    ),
                    validator: (_) => _nameError,
                    onChanged: (v) async {
                      if (v.trim().isEmpty) {
                        setState(() => _nameError = 'Ingresa tu nombre');
                      } else {
                        final exists = await context
                            .read<AuthProvider>()
                            .usernameExists(v);
                        setState(
                          () =>
                              _nameError =
                                  exists ? 'Nombre ya registrado' : null,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Correo electrónico con validación en tiempo real
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      errorText: _emailError,
                    ),
                    validator: (_) => _emailError,
                    onChanged: (v) async {
                      if (!v.contains('@')) {
                        setState(() => _emailError = 'Correo inválido');
                      } else {
                        final exists = await context
                            .read<AuthProvider>()
                            .emailExists(v);
                        setState(
                          () =>
                              _emailError =
                                  exists ? 'Correo ya registrado' : null,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  PasswordField(
                    controller: _passwordController,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 16),

                  // Confirmar contraseña
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar contraseña',
                    validator:
                        (v) =>
                            v != _passwordController.text
                                ? 'Las contraseñas no coinciden'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  // Botón de registro
                  ElevatedButton(
                    onPressed:
                        (auth.isLoading ||
                                _nameError != null ||
                                _emailError != null)
                            ? null
                            : _handleRegister,
                    child:
                        auth.isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          ),
          if (auth.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final error = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Revisa tu correo para verificar.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
