// lib/screens/edit_disco_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../models/vinyl_record.dart';
import '../providers/collection_provider.dart';

class EditDiscoScreen extends StatefulWidget {
  final VinylRecord record;
  const EditDiscoScreen({super.key, required this.record});

  @override
  State<EditDiscoScreen> createState() => _EditDiscoScreenState();
}

class _EditDiscoScreenState extends State<EditDiscoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _artistCtr;
  late TextEditingController _titleCtr;
  late TextEditingController _genreCtr;
  late TextEditingController _yearCtr;
  late TextEditingController _labelCtr;
  late TextEditingController _buyCtr;
  late TextEditingController _descCtr;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _artistCtr = TextEditingController(text: r.artista);
    _titleCtr = TextEditingController(text: r.titulo);
    _genreCtr = TextEditingController(text: r.genero);
    _yearCtr = TextEditingController(text: r.anio);
    _labelCtr = TextEditingController(text: r.sello);
    _buyCtr = TextEditingController(text: r.lugarCompra);
    _descCtr = TextEditingController(text: r.descripcion);
  }

  @override
  void dispose() {
    _artistCtr.dispose();
    _titleCtr.dispose();
    _genreCtr.dispose();
    _yearCtr.dispose();
    _labelCtr.dispose();
    _buyCtr.dispose();
    _descCtr.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CollectionProvider>();
    final updated = VinylRecord(
      id: widget.record.id,
      userId: widget.record.userId,
      referencia: widget.record.referencia,
      artista: _artistCtr.text,
      titulo: _titleCtr.text,
      genero: _genreCtr.text,
      anio: _yearCtr.text,
      sello: _labelCtr.text,
      lugarCompra: _buyCtr.text,
      descripcion: _descCtr.text,
      portadaUrl:
          _pickedImage != null ? _pickedImage!.path : widget.record.portadaUrl,
      favorito: widget.record.favorito,
    );
    await provider.updateRecord(updated);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar disco')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cover selector (cuadrado) con cursor de mano
                      Center(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _pickCover,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image:
                                          _pickedImage != null
                                              ? FileImage(
                                                    File(_pickedImage!.path),
                                                  )
                                                  as ImageProvider
                                              : NetworkImage(
                                                widget.record.portadaUrl,
                                              ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Campos de texto
                      TextFormField(
                        controller: _artistCtr,
                        decoration: const InputDecoration(
                          labelText: 'Artista',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _titleCtr,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          prefixIcon: Icon(Icons.album),
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _genreCtr,
                        decoration: const InputDecoration(
                          labelText: 'Género',
                          prefixIcon: Icon(Icons.music_note),
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _yearCtr,
                        decoration: const InputDecoration(
                          labelText: 'Año',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _labelCtr,
                        decoration: const InputDecoration(
                          labelText: 'Sello',
                          prefixIcon: Icon(Icons.library_music),
                        ),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _buyCtr,
                        decoration: const InputDecoration(
                          labelText: 'Lugar de compra',
                          prefixIcon: Icon(Icons.store),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtr,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
