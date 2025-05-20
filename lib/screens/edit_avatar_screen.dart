import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../services/user_profile_service.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({Key? key}) : super(key: key);

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  final _svc = UserProfileService();
  File? _selected;
  bool _loading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: img.path,
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
        IOSUiSettings(
          title: 'Recortar',
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(context: context), // solo context es obligatorio
      ],
    );
    if (cropped == null) return;

    setState(() => _selected = File(cropped.path));
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      final url = await _svc.uploadAvatar(_selected!);
      await _svc.updateAvatarUrl(url);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Avatar actualizado')));
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 350.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Foto de perfil')),
      body: Center(
        child: Container(
          width: maxWidth,
          padding: const EdgeInsets.all(30),
          decoration: _box,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    _selected != null ? FileImage(_selected!) : null,
                child: _selected == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _pick, child: const Text('Elegir imagen')),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
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
