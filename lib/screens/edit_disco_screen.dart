import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late final TextEditingController _artistCtr;
  late final TextEditingController _titleCtr;
  late final TextEditingController _genreCtr;
  late final TextEditingController _yearCtr;
  late final TextEditingController _labelCtr;
  late final TextEditingController _buyCtr;
  late final TextEditingController _descCtr;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<CollectionProvider>();
    final updated = widget.record.copyWith(
      artista: _artistCtr.text,
      titulo: _titleCtr.text,
      genero: _genreCtr.text,
      anio: _yearCtr.text,
      sello: _labelCtr.text,
      lugarCompra: _buyCtr.text,
      descripcion: _descCtr.text,
    );
    await provider.updateRecord(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar disco')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _artistCtr,
                decoration: const InputDecoration(labelText: 'Artista'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtr,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genreCtr,
                decoration: const InputDecoration(labelText: 'Género'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtr,
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelCtr,
                decoration: const InputDecoration(labelText: 'Sello'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyCtr,
                decoration:
                    const InputDecoration(labelText: 'Lugar de compra'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtr,
                decoration: const InputDecoration(labelText: 'Descripción'),
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
    );
  }
}
