// lib/widgets/change_name_section.dart

import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ChangeNameSection extends StatefulWidget {
  final String initialName;
  final int remainingNameChanges;
  final Future<void> Function() onSaved;

  const ChangeNameSection({
    Key? key,
    required this.initialName,
    required this.remainingNameChanges,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<ChangeNameSection> createState() => _ChangeNameSectionState();
}

class _ChangeNameSectionState extends State<ChangeNameSection> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.initialName;
  }

  Future<void> _save() async {
    final newName = _nameCtrl.text.trim();
    if (!_formKey.currentState!.validate()) return;

    if (newName != widget.initialName) {
      final available = await UserService().isNameAvailable(newName);
      if (!available) {
        setState(() => _error = 'Ese nombre ya está en uso.');
        return;
      }
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await UserService().updateName(newName);
      final remainingAfter = widget.remainingNameChanges - 1;
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('¡Nombre actualizado!'),
              content: Text(
                remainingAfter > 0
                    ? 'Te quedan $remainingAfter cambios de nombre.'
                    : 'Has agotado tus 2 cambios.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      await widget.onSaved();
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canChange = widget.remainingNameChanges > 0;
    final headerStyle = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600);

    if (!canChange) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nombre de usuario', style: headerStyle),
          const SizedBox(height: 6),
          Text(widget.initialName),
          const SizedBox(height: 4),
          const Text(
            'Ya no puedes cambiar más tu nombre.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cambiar nombre (te quedan ${widget.remainingNameChanges})',
          style: headerStyle,
        ),
        const SizedBox(height: 6),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nuevo nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator:
                (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
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
                  : const Text('Guardar nombre'),
        ),
      ],
    );
  }
}
