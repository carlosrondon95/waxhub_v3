// lib/screens/settings/edit_avatar_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/user_service.dart';

Future<void> _showAlert(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                size: 48,
                color:
                    success
                        ? Theme.of(context).colorScheme.primary
                        : Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({Key? key}) : super(key: key);

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  final _svc = UserService();
  XFile? _selectedImage;
  Uint8List? _selectedBytes;
  bool _loading = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
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

  Future<void> _save() async {
    if (_selectedBytes == null || _selectedImage == null) return;
    setState(() => _loading = true);
    try {
      final url = await _svc.uploadAvatarBytes(
        _selectedBytes!,
        _selectedImage!.name,
      );
      await _svc.updateAvatarUrl(url);

      if (!mounted) return;
      Navigator.pop(context);
      await _showAlert(context, 'Avatar actualizado', success: true);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        await _showAlert(context, 'Error al subir avatar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 120;
    return Scaffold(
      appBar: AppBar(title: const Text('Foto de perfil')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundImage:
                          _selectedBytes != null
                              ? MemoryImage(_selectedBytes!)
                              : null,
                      child:
                          _selectedBytes == null
                              ? Icon(
                                Icons.person,
                                size: avatarSize * 0.5,
                                color: Colors.grey.shade600,
                              )
                              : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _save,
              icon:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.save),
              label: const Text('Guardar foto'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(150, 60)),
            ),
          ],
        ),
      ),
    );
  }
}
