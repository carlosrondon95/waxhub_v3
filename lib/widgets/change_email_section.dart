import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

class ChangeEmailSection extends StatefulWidget {
  final String initialEmail;
  const ChangeEmailSection({Key? key, required this.initialEmail})
    : super(key: key);

  @override
  State<ChangeEmailSection> createState() => _ChangeEmailSectionState();
}

class _ChangeEmailSectionState extends State<ChangeEmailSection> {
  final _svc = UserProfileService();
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    _emailCtr.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await _svc.updateEmail(_passCtr.text, _emailCtr.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo actualizado. Revisa tu email para verificar.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  InputDecoration _dec(String hint, {Widget? prefix, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: prefix ?? const Icon(Icons.email_outlined, size: 20),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
      );

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Nuevo correo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailCtr,
          keyboardType: TextInputType.emailAddress,
          decoration: _dec('Introduce nuevo correo'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtr,
          obscureText: !_showPass,
          decoration: _dec(
            'Contraseña actual',
            prefix: const Icon(Icons.lock_outline, size: 20),
            suffix: IconButton(
              icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Guardar correo'),
        ),
      ],
    );
  }
}
