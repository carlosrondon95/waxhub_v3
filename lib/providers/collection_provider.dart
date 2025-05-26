import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/vinyl_record.dart';

class CollectionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  /* ─── Estado ───────────────────────────────────────────── */
  List<VinylRecord> _allRecords = [];
  String _searchQuery = '';
  String _sortBy = 'titulo';
  bool _showFavorites = false;
  String _viewMode = 'lista';
  bool _isLoading = false;

  /* ─── Constructor ─────────────────────────────────────── */
  CollectionProvider() {
    // Cada vez que cambia la sesión, ajusta la suscripción
    _auth.authStateChanges().listen((user) {
      _subscription?.cancel();
      if (user != null) {
        _subscribeToRecords(user.uid);
      } else {
        _allRecords = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /* ─── Suscripción a Firestore ─────────────────────────── */
  void _subscribeToRecords(String uid) {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestore
        .collection('discos')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            _allRecords =
                snapshot.docs.map((doc) => VinylRecord.fromDoc(doc)).toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Firestore listener error: $e');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /* ─── Getters (públicos) ───────────────────────────────── */

  List<VinylRecord> get allRecords => List.unmodifiable(_allRecords);

  List<VinylRecord> get filteredRecords {
    final q = _searchQuery.toLowerCase();

    var list =
        _allRecords.where((r) {
          final matchSearch =
              r.titulo.toLowerCase().contains(q) ||
              r.artista.toLowerCase().contains(q) ||
              r.genero.toLowerCase().contains(q);
          final matchFav = !_showFavorites || r.favorito;
          return matchSearch && matchFav;
        }).toList();

    list.sort((a, b) {
      switch (_sortBy) {
        case 'artista':
          return a.artista.toLowerCase().compareTo(b.artista.toLowerCase());
        case 'anio':
          return a.anio.compareTo(b.anio);
        default:
          return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
      }
    });

    return list;
  }

  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get showFavorites => _showFavorites;
  String get viewMode => _viewMode;
  bool get isLoading => _isLoading;

  /* ─── Setters (filtros y vista) ───────────────────────── */

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setSortBy(String field) {
    _sortBy = field;
    notifyListeners();
  }

  void setShowFavorites(bool v) {
    _showFavorites = v;
    notifyListeners();
  }

  void setViewMode(String mode) {
    _viewMode = mode;
    notifyListeners();
  }

  /* ─── Operaciones de escritura ────────────────────────── */

  Future<void> deleteRecord(String id) async {
    await _firestore.collection('discos').doc(id).delete();
    // El listener actualizará la lista
  }

  Future<void> toggleFavorite(String id, bool current) async {
    await _firestore.collection('discos').doc(id).update({
      'favorito': !current,
    });
  }

  Future<void> updateRecord(VinylRecord updated) async {
    await _firestore.collection('discos').doc(updated.id).set(updated.toMap());
  }
}
