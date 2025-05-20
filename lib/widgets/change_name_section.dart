import 'dart:async';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

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
  final _svc = UserService();
  final _ctr = TextEditingController();
  bool? _available;
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctr.text = widget.initialName;
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    setState(() {
      _loading = true;
      _available = null;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final ok = v.trim().length > 5 && await _svc.isNameAvailable(v.trim());
      setState(() {
        _available = ok;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _ctr.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    if (!widget.canChange) return const SizedBox.shrink();
    final isValidLength = _ctr.text.trim().length > 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nuevo nombre',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF151717)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _ctr,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Mínimo 6 caracteres',
            prefixIcon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
            suffixIcon: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : (_available == true
                    ? const Icon(Icons.check, color: Colors.green)
                    : (_available == false
                        ? const Icon(Icons.close, color: Colors.red)
                        : null)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFecedec), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
        ),
        if (!isValidLength) 
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'El nombre debe tener al menos 6 caracteres',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: (_available == true && isValidLength)
              ? () async {
                  final info = await _svc.loadUserInfo();
                  await _svc.updateName(info['uid'] as String, _ctr.text.trim());
                  widget.onSaved();
                }
              : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Guardar nombre'),
        ),
      ],
    );
  }
}
