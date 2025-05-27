// lib/widgets/change_email_section.dart

import 'package:flutter/material.dart';
import '/services/user_service.dart';

class ChangeEmailSection extends StatefulWidget {
  final String initialEmail;

  const ChangeEmailSection({Key? key, required this.initialEmail})
    : super(key: key);

  @override
  State<ChangeEmailSection> createState() => _ChangeEmailSectionState();
}

class _ChangeEmailSectionState extends State<ChangeEmailSection> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newEmail = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (newEmail != widget.initialEmail) {
      final available = await UserService().isEmailAvailable(newEmail);
      if (!available) {
        setState(() => _error = 'Ese email ya está registrado.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await UserService().updateEmail(password, newEmail);
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('¡Email actualizado!'),
              content: const Text(
                'Se ha enviado un correo de verificación a tu nueva dirección.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cambiar email', style: headerStyle),
        const SizedBox(height: 6),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nuevo email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(v.trim())) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator:
                    (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Guardar email'),
        ),
      ],
    );
  }
}
