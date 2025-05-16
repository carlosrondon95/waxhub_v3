import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../services/discogs_service.dart';
import '../models/artist_result.dart';
import '../models/release_result.dart';
import '../models/vinyl_record.dart';
import '../core/image_proxy.dart'; // 👈 helper para CORS

class VinylProvider extends ChangeNotifier {
  /* ─── Form & controllers ─── */
  final formKey = GlobalKey<FormState>();

  final artistController = TextEditingController();
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final yearController = TextEditingController();
  final labelController = TextEditingController();
  final buyController = TextEditingController();
  final descController = TextEditingController();

  /* ─── Services ─── */
  final _discogs = DiscogsService();
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  /* ─── State ─── */
  ArtistResult? selectedArtist;
  ReleaseResult? selectedRelease;
  String? coverUrl;
  bool isLoading = false;

  /* ───────────── Discogs search ───────────── */
  Future<List<ArtistResult>> searchArtists(String q) async =>
      q.length < 2 ? [] : _discogs.searchArtists(q);

  void selectArtist(ArtistResult artist) {
    selectedArtist = artist;
    artistController.text = artist.name;
    selectedRelease = null;
    titleController.clear();
    genreController.clear();
    yearController.clear();
    labelController.clear();
    coverUrl = null;
    notifyListeners();
  }

  Future<List<ReleaseResult>> searchReleases(String q) async {
    if (selectedArtist == null || q.isEmpty) return [];
    return _discogs.searchVinylsOfArtist(selectedArtist!.id, q);
  }

  /* ───────────── Select release ───────────── */
  Future<void> selectRelease(ReleaseResult release) async {
    isLoading = true;
    notifyListeners();

    selectedRelease = release;
    final detail = await _discogs.fetchRelease(release.id);

    titleController.text = detail.title;
    genreController.text = detail.genre ?? '';
    yearController.text = detail.year ?? '';
    labelController.text = detail.label ?? '';

    coverUrl = proxiedImage(detail.coverUrl); // 👈 usa helper

    isLoading = false;
    notifyListeners();
  }

  /* ───────────── Imagen manual ───────────── */
  Future<void> pickCoverImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final ref = _storage.ref('covers/${_uuid.v4()}.jpg');
      await ref.putFile(File(picked.path));
      coverUrl = await ref.getDownloadURL();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Guardar disco ───────────── */
  Future<bool> saveRecord() async {
    if (!formKey.currentState!.validate() || selectedRelease == null) {
      return false;
    }
    final user = _auth.currentUser;
    if (user == null) return false;

    isLoading = true;
    notifyListeners();

    final record = VinylRecord(
      id: '',
      userId: user.uid,
      referencia: selectedRelease!.id.toString(),
      artista: artistController.text,
      titulo: titleController.text,
      genero: genreController.text,
      anio: yearController.text,
      sello: labelController.text,
      lugarCompra: buyController.text,
      descripcion: descController.text,
      portadaUrl: coverUrl ?? '',
    );

    try {
      await _firestore.collection('discos').add(record.toMap());
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Clean up ───────────── */
  @override
  void dispose() {
    artistController.dispose();
    titleController.dispose();
    genreController.dispose();
    yearController.dispose();
    labelController.dispose();
    buyController.dispose();
    descController.dispose();
    super.dispose();
  }
}
