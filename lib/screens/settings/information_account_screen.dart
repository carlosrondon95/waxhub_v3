// lib/screens/settings/information_account_screen.dart

import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/services/user_service.dart';
import '/widgets/changes/change_name_section.dart';
import '/widgets/changes/change_email_section.dart';
import '/widgets/changes/change_password_section.dart';

class InformationAccountScreen extends StatefulWidget {
  const InformationAccountScreen({Key? key}) : super(key: key);

  @override
  State<InformationAccountScreen> createState() =>
      _InformationAccountScreenState();
}

class _InformationAccountScreenState extends State<InformationAccountScreen> {
  final _userSvc = UserService();
  final _profileSvc = UserService();

  String _name = '';
  String _email = '';
  int _nameChangeCount = 0;
  bool _isGoogle = false;
  String? _avatarUrl;

  XFile? _selectedImage;
  Uint8List? _selectedBytes;
  bool _savingAvatar = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await _userSvc.loadUserInfo();
    setState(() {
      _name = info['nombre'] as String;
      _email = info['email'] as String;
      _nameChangeCount = info['nombreCambioCount'] as int;
      _isGoogle = info['isGoogle'] as bool;
      _avatarUrl = info['avatarUrl'] as String?;
      _selectedImage = null;
      _selectedBytes = null;
      _savingAvatar = false;
    });
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _selectedImage = img;
      _selectedBytes = bytes;
    });
  }

  Future<void> _saveAvatar() async {
    if (_selectedBytes == null || _selectedImage == null) return;
    setState(() => _savingAvatar = true);
    try {
      final url = await _profileSvc.uploadAvatarBytes(
        _selectedBytes!,
        _selectedImage!.name,
      );
      await _profileSvc.updateAvatarUrl(url);
      await precacheImage(NetworkImage(url), context);
      setState(() {
        _avatarUrl = url;
        _selectedImage = null;
        _selectedBytes = null;
      });
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('¡Avatar actualizado!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir avatar: $e')));
    } finally {
      if (mounted) setState(() => _savingAvatar = false);
    }
  }

  Future<void> _confirmDelete() async {
    final sure = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );
    if (sure != true) return;

    final a = Random().nextInt(10) + 1;
    final b = Random().nextInt(10) + 1;
    final answer = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String input = '';
        return AlertDialog(
          title: const Text('Captcha'),
          content: TextField(
            onChanged: (v) => input = v,
            decoration: InputDecoration(labelText: '¿Cuánto es \$a + \$b?'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, input),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
    if (answer == null || int.tryParse(answer) != a + b) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Captcha incorrecto')));
      return;
    }

    try {
      await _profileSvc.deleteAccount();
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cuenta eliminada')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingNameChanges = (2 - _nameChangeCount).clamp(0, 2);
    const maxWidth = 450.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Información de la cuenta')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.all(30),
          decoration: _box(context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _selectedBytes != null
                                ? MemoryImage(_selectedBytes!)
                                : (_avatarUrl != null
                                        ? NetworkImage(_avatarUrl!)
                                        : null)
                                    as ImageProvider<Object>?,
                        child:
                            _selectedBytes == null && _avatarUrl == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.black45,
                        radius: 14,
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedBytes != null)
                  ElevatedButton(
                    onPressed: _savingAvatar ? null : _saveAvatar,
                    child:
                        _savingAvatar
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Guardar foto'),
                  )
                else
                  const SizedBox(height: 20),
                // Mostrar siempre el nombre de usuario debajo del avatar
                Text(_name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 24),
                ChangeNameSection(
                  initialName: _name,
                  remainingNameChanges: remainingNameChanges,
                  onSaved: _load,
                ),
                const SizedBox(height: 24),
                ChangeEmailSection(initialEmail: _email),
                const SizedBox(height: 24),
                ChangePasswordSection(isGoogle: _isGoogle),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Eliminar cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _box(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        theme.brightness == Brightness.light
            ? Colors.grey.shade300
            : Colors.white24;
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
