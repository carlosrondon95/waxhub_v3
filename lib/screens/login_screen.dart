import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recoveryEmailController = TextEditingController();

  bool _showRecoveryDialog = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(controller: _passwordController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleSignIn,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: auth.isLoading ? null : _handleSignInWithGoogle,
                  child: const Text('Iniciar sesión con Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed:
                      auth.isLoading
                          ? null
                          : () => setState(() => _showRecoveryDialog = true),
                  child: const Text('He olvidado mi contraseña'),
                ),
              ],
            ),
          ),
          if (auth.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton:
          _showRecoveryDialog ? _buildRecoveryDialog(context) : null,
    );
  }

  Future<void> _handleSignIn() async {
    final auth = context.read<AuthProvider>();
    final error = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final error = await auth.signInWithGoogle();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    }
  }

  Widget _buildRecoveryDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ingresa tu correo para recibir un enlace de restablecimiento.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _recoveryEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showRecoveryDialog = false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() => _showRecoveryDialog = false);
            final auth = context.read<AuthProvider>();
            final error = await auth.sendPasswordReset(
              _recoveryEmailController.text.trim(),
            );
            if (error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error)));
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Enlace enviado.')));
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
