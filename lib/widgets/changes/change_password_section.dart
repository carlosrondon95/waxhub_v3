// lib/widgets/changes/change_password_section.dart
import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/widgets/fields/password_field.dart';

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

class ChangePasswordSection extends StatefulWidget {
  final bool isGoogle;

  const ChangePasswordSection({Key? key, required this.isGoogle})
    : super(key: key);

  @override
  State<ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  String? _passwordValidator(String? v) {
    if (v == null || v.length < 7) return 'Mínimo 7 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe incluir una mayúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe incluir un número';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await UserService().updatePassword(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      await _showAlert(context, 'Contraseña actualizada', success: true);
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      await _showAlert(context, _error ?? 'Error desconocido');
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGoogle) return const SizedBox.shrink();

    final headerStyle = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cambiar contraseña', style: headerStyle),
        const SizedBox(height: 6),
        Form(
          key: _formKey,
          child: Column(
            children: [
              PasswordField(
                controller: _currentCtrl,
                label: 'Contraseña actual',
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _newCtrl,
                label: 'Nueva contraseña',
                validator: _passwordValidator,
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirmCtrl,
                label: 'Confirmar contraseña',
                validator: (v) => v != _newCtrl.text ? 'No coinciden' : null,
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
                  : const Text('Guardar contraseña'),
        ),
      ],
    );
  }
}
