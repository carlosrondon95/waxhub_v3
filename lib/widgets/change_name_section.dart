import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'input_form_field.dart';

class ChangeNameSection extends StatefulWidget {
  final String initialName;
  final bool canChange;
  final VoidCallback onSaved;

  const ChangeNameSection({
    Key? key,
    required this.initialName,
    required this.canChange,
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await UserService().updateName(widget.initialName, _nameCtrl.text.trim());
      if (!mounted) return;
      widget.onSaved();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(
      context,
    ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600);

    if (!widget.canChange) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre de usuario', style: headerStyle),
          const SizedBox(height: 6),
          Text(widget.initialName),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cambiar nombre', style: headerStyle),
        const SizedBox(height: 6),
        Form(
          key: _formKey,
          child: InputFormField(
            label: 'Nuevo nombre',
            icon: Icons.person_outline,
            controller: _nameCtrl,
            hint: 'Introduce tu nombre',
            validator:
                (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
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
