// lib/screens/settings/information_account_screen.dart
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../services/user_service.dart';
import '../../services/user_profile_service.dart';
import '../../widgets/change_name_section.dart';
import '../../widgets/change_email_section.dart';
import '../../widgets/change_password_section.dart';

class InformationAccountScreen extends StatefulWidget {
  const InformationAccountScreen({Key? key}) : super(key: key);

  @override
  State<InformationAccountScreen> createState() =>
      _InformationAccountScreenState();
}

class _InformationAccountScreenState extends State<InformationAccountScreen> {
  final _userSvc = UserService();
  final _profileSvc = UserProfileService();

  String _name = '';
  String _email = '';
  bool _canChangeName = false;
  bool _isGoogle = false;
  String? _avatarUrl;

  File? _selected;
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
      _canChangeName = !(info['nombreCambiado'] as bool);
      _isGoogle = info['isGoogle'] as bool;
      _avatarUrl = info['photoURL'] as String?;
    });
  }

  /* ---------- Avatar ---------- */
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar',
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
          ],
        ),
        IOSUiSettings(title: 'Recortar', aspectRatioLockEnabled: true),
        WebUiSettings(context: context), // versión web
      ],
    );
    if (cropped == null) return;

    setState(() => _selected = File(cropped.path));
  }

  Future<void> _saveAvatar() async {
    if (_selected == null) return;
    setState(() => _savingAvatar = true);
    try {
      final url = await _profileSvc.uploadAvatar(_selected!);
      await _profileSvc.updateAvatarUrl(url);
      setState(() {
        _avatarUrl = url;
        _selected = null;
        _savingAvatar = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Avatar actualizado')));
    } catch (e) {
      setState(() => _savingAvatar = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /* ---------- Eliminar cuenta con doble confirmación ---------- */
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
            decoration: InputDecoration(labelText: '¿Cuánto es $a + $b?'),
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
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    const maxWidth = 450.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Información de la cuenta')),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(30),
          decoration: _box,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /* Avatar + nombre */
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _selected != null
                          ? FileImage(_selected!)
                          : (_avatarUrl != null
                                  ? NetworkImage(_avatarUrl!)
                                  : null)
                              as ImageProvider<Object>?,
                  child:
                      _selected == null && _avatarUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
                const SizedBox(height: 8),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickAvatar,
                  style: ElevatedButton.styleFrom(
                    // ↑ más aire a derecha-izquierda y ligeramente arriba-abajo
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    minimumSize: const Size.fromHeight(
                      40,
                    ), // mantiene altura mínima cómoda
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cambiar foto'),
                ),

                if (_selected != null) ...[
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: _savingAvatar ? null : _saveAvatar,
                    child:
                        _savingAvatar
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Guardar foto'),
                  ),
                  const SizedBox(height: 20),
                ] else
                  const SizedBox(height: 20),

                /* Nombre, email, contraseña */
                ChangeNameSection(
                  initialName: _name,
                  canChange: _canChangeName,
                  onSaved: _load,
                ),
                const SizedBox(height: 24),
                ChangeEmailSection(initialEmail: _email),
                const SizedBox(height: 24),
                ChangePasswordSection(isGoogle: _isGoogle),
                const SizedBox(height: 24),

                /* Eliminar cuenta */
                ElevatedButton(
                  onPressed: _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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

  static const _box = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );
}
