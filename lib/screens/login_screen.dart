import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';
import '../routes/fade_route.dart';
import 'home_screen.dart';

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
  bool _isLoading = false;
  bool mostrarReenviar = false; // Simulado por ahora

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Stack(
        children: [
          // Contenido principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bienvenido de nuevo',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
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
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleSignInWithGoogle,
                  child: const Text('Iniciar sesión con Google'),
                ),
                const SizedBox(height: 8),
                if (mostrarReenviar)
                  TextButton(
                    onPressed: _isLoading ? null : _handleResendVerification,
                    child: const Text('Reenviar correo de verificación'),
                  ),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () => setState(() => _showRecoveryDialog = true),
                  child: const Text('He olvidado mi contraseña'),
                ),
              ],
            ),
          ),

          // Overlay semitransparente con spinner central
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),

      // Diálogo de recuperación de contraseña
      floatingActionButton:
          _showRecoveryDialog ? _buildRecoveryDialog(context) : null,
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.signIn(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        FadePageRoute(page: const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleSignInWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.signInWithGoogle();
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        FadePageRoute(page: const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleResendVerification() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.resendEmailVerification();
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Correo reenviado.')));
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
            await _handlePasswordReset();
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }

  Future<void> _handlePasswordReset() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.sendPasswordReset(
      _recoveryEmailController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enlace enviado.')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }
}
