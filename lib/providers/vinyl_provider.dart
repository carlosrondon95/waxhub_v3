import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../services/discogs_service.dart';
import '../models/vinyl_record.dart';

class VinylProvider extends ChangeNotifier {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController artistController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController buyController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Services & utilities
  final DiscogsService _discogs = DiscogsService();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // State
  ArtistResult? selectedArtist;
  ReleaseResult? selectedRelease;
  String? coverUrl;
  bool isLoading = false;

  // Search artists on Discogs
  Future<List<ArtistResult>> searchArtists(String query) async {
    return query.length < 2 ? [] : await _discogs.searchArtists(query);
  }

  // Select an artist
  void selectArtist(ArtistResult artist) {
    selectedArtist = artist;
    artistController.text = artist.name;
    // Reset dependent fields
    selectedRelease = null;
    titleController.clear();
    genreController.clear();
    yearController.clear();
    labelController.clear();
    coverUrl = null;
    notifyListeners();
  }

  // Search releases by selected artist
  Future<List<ReleaseResult>> searchReleases(String query) async {
    if (selectedArtist == null) return [];
    return query.isEmpty
        ? []
        : await _discogs.searchVinylsOfArtist(selectedArtist!.id, query);
  }

  // Select a release and fetch details
  Future<void> selectRelease(ReleaseResult release) async {
    isLoading = true;
    notifyListeners();

    selectedRelease = release;
    final detail = await _discogs.fetchRelease(release.id);

    titleController.text = detail.title;
    genreController.text = detail.genre ?? '';
    yearController.text = detail.year ?? '';
    labelController.text = detail.label ?? '';
    coverUrl = detail.coverUrl;

    isLoading = false;
    notifyListeners();
  }

  // Pick and upload cover image
  Future<void> pickCoverImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final file = File(picked.path);
      final ref = _storage.ref('covers/${_uuid.v4()}.jpg');
      await ref.putFile(file);
      coverUrl = await ref.getDownloadURL();
    } catch (_) {
      // Handle error if needed
    }

    isLoading = false;
    notifyListeners();
  }

  // Validate and save record to Firestore
  Future<bool> saveRecord() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedRelease == null) return false;

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
