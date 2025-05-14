// lib/widgets/password_field.dart
import 'package:flutter/material.dart';

typedef Validator = String? Function(String?);

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Validator? validator;

  const PasswordField({
    Key? key,
    required this.controller,
    this.label = 'Contraseña',
    this.validator,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    if (value.length < 7) {
      return 'Mínimo 7 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos una letra mayúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator ?? _defaultValidator,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
