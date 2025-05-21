import 'package:flutter/material.dart';

class InputFormField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputFormField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validator,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<InputFormField> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends State<InputFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

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
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: _border(context, focused: false),
        focusedBorder: _border(context, focused: true),
        errorBorder: _border(context, focused: false),
        focusedErrorBorder: _border(context, focused: true),
        suffixIcon:
            widget.obscure
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
                : null,
      ),
    );
  }
}
