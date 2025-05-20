import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ChangePasswordSection extends StatefulWidget {
  final bool isGoogle;
  const ChangePasswordSection({Key? key, required this.isGoogle})
    : super(key: key);

  @override
  State<ChangePasswordSection> createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  final _svc = UserService();
  final _oldCtr = TextEditingController();
  final _newCtr = TextEditingController();
  final _confCtr = TextEditingController();

  bool _showOld = false, _showNew = false, _showConf = false;

  @override
  void dispose() {
    _oldCtr.dispose();
    _newCtr.dispose();
    _confCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtr.text != _confCtr.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    try {
      await _svc.updatePassword(_oldCtr.text, _newCtr.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
      _oldCtr.clear();
      _newCtr.clear();
      _confCtr.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget _pwField(
    TextEditingController ctr,
    String hint,
    bool show,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: ctr,
      obscureText: !show,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Colors.black54,
        ),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFecedec), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    if (widget.isGoogle) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _pwField(
          _oldCtr,
          'Contraseña actual',
          _showOld,
          () => setState(() => _showOld = !_showOld),
        ),
        const SizedBox(height: 16),
        _pwField(
          _newCtr,
          'Nueva contraseña',
          _showNew,
          () => setState(() => _showNew = !_showNew),
        ),
        const SizedBox(height: 16),
        _pwField(
          _confCtr,
          'Confirmar contraseña',
          _showConf,
          () => setState(() => _showConf = !_showConf),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Actualizar contraseña'),
        ),
      ],
    );
  }
}
