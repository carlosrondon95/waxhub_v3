import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

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

  OutlineInputBorder _border(BuildContext ctx, {required bool focused}) {
    final theme = Theme.of(ctx);
    final baseColor =
        theme.brightness == Brightness.light
            ? Colors.grey.shade300
            : Colors.white24;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focused ? theme.colorScheme.primary : baseColor,
        width: focused ? 2 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).iconTheme.color,
        ),
        labelText: widget.label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: _border(context, focused: false),
        focusedBorder: _border(context, focused: true),
        errorBorder: _border(context, focused: false),
        focusedErrorBorder: _border(context, focused: true),
        suffixIcon: IconButton(
          iconSize: isDesktop ? 28 : 24,
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
