import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/discogs_service.dart';
import '../screens/nuevo_disco_screen.dart';

class NuevoDiscoPage extends StatefulWidget {
  const NuevoDiscoPage({super.key});

  @override
  State<NuevoDiscoPage> createState() => _NuevoDiscoPageState();
}

class _NuevoDiscoPageState extends State<NuevoDiscoPage> {
  /* ─── Controllers ─── */
  final _artistCtr = TextEditingController();
  final _titleCtr = TextEditingController();
  final _genreCtr = TextEditingController();
  final _yearCtr = TextEditingController();
  final _labelCtr = TextEditingController();
  final _buyCtr = TextEditingController();
  final _descCtr = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _uuid = Uuid();

  int? _artistId;
  int? _releaseId; // ← referencia oculta
  String? _coverUrl;

  final _discogs = DiscogsService();
  final _storage = FirebaseStorage.instance.ref();
  final _firestore = FirebaseFirestore.instance;

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

  /* ─────────── callbacks ─────────── */
  void _onArtistSelected(ArtistResult a) {
    setState(() {
      _artistId = a.id;
      _artistCtr.text = a.name;
      _titleCtr.clear();
      _releaseId = null;
      _genreCtr.clear();
      _yearCtr.clear();
      _labelCtr.clear();
      _coverUrl = null;
    });
  }

  Future<void> _onTitleSelected(ReleaseResult r) async {
    final detail = await _discogs.fetchRelease(r.id);
    setState(() {
      _releaseId = r.id;
      _titleCtr.text = detail.title;
      _genreCtr.text = detail.genre ?? '';
      _yearCtr.text = detail.year ?? '';
      _labelCtr.text = detail.label ?? '';
      _coverUrl = detail.coverUrl;
    });
  }

  Future<void> _pickManualImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = _storage.child('portadas/${_uuid.v4()}.jpg');

    try {
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      if (!mounted) return;

      setState(() {
        _coverUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al subir la imagen')));
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _releaseId == null) return;

    final data = {
      'userId': uid,
      'referencia': _releaseId.toString(),
      'artista': _artistCtr.text,
      'titulo': _titleCtr.text,
      'genero': _genreCtr.text,
      'anio': _yearCtr.text,
      'sello': _labelCtr.text,
      'compra': _buyCtr.text,
      'descripcion': _descCtr.text,
      'portadaUrl': _coverUrl ?? '',
    };

    await _firestore.collection('discos').add(data);
    if (mounted) Navigator.of(context).pop();
  }

  /* ─────────── UI ─────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir disco')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: NuevoDiscoScreen(
            artistCtr: _artistCtr,
            titleCtr: _titleCtr,
            genreCtr: _genreCtr,
            yearCtr: _yearCtr,
            labelCtr: _labelCtr,
            buyCtr: _buyCtr,
            descCtr: _descCtr,
            titleEnabled: _artistId != null,
            artistId: _artistId,
            coverUrl: _coverUrl,
            onArtistSelected: _onArtistSelected,
            onTitleSelected: _onTitleSelected,
            onPickImage: _pickManualImage,
            onSave: _onSave,
          ),
        ),
      ),
    );
  }
}
