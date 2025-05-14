// lib/providers/collection_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/vinyl_record.dart';

class CollectionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  List<VinylRecord> _allRecords = [];
  String _searchQuery = '';
  String _sortBy = 'titulo';
  bool _showFavorites = false;
  String _viewMode = 'lista';
  bool _isLoading = false;

  CollectionProvider() {
    // Listen to auth changes and subscribe accordingly
    _auth.authStateChanges().listen((user) {
      _subscription?.cancel();
      if (user != null) {
        _subscribeToRecords(user.uid);
      } else {
        _allRecords = [];
        notifyListeners();
      }
    });
  }

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
          onError: (_) {
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

  // Getters
  List<VinylRecord> get allRecords => List.unmodifiable(_allRecords);
  List<VinylRecord> get filteredRecords {
    final q = _searchQuery.toLowerCase();
    var list =
        _allRecords.where((record) {
          final matchesSearch =
              record.titulo.toLowerCase().contains(q) ||
              record.artista.toLowerCase().contains(q) ||
              record.genero.toLowerCase().contains(q);
          final matchesFavorites = !_showFavorites || record.favorito;
          return matchesSearch && matchesFavorites;
        }).toList();

    list.sort((a, b) {
      switch (_sortBy) {
        case 'artista':
          return a.artista.compareTo(b.artista);
        case 'anio':
          return a.anio.compareTo(b.anio);
        default:
          return a.titulo.compareTo(b.titulo);
      }
    });
    return list;
  }

  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get showFavorites => _showFavorites;
  String get viewMode => _viewMode;
  bool get isLoading => _isLoading;

  // Setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String field) {
    _sortBy = field;
    notifyListeners();
  }

  void setShowFavorites(bool value) {
    _showFavorites = value;
    notifyListeners();
  }

  void setViewMode(String mode) {
    _viewMode = mode;
    notifyListeners();
  }

  // Write operations
  Future<void> deleteRecord(String id) async {
    try {
      await _firestore.collection('discos').doc(id).delete();
      // changes will be reflected by listener
    } catch (_) {
      // handle error
    }
  }

  Future<void> toggleFavorite(String id, bool current) async {
    try {
      await _firestore.collection('discos').doc(id).update({
        'favorito': !current,
      });
    } catch (_) {
      // handle error
    }
  }

  Future<void> updateRecord(VinylRecord updated) async {
    try {
      await _firestore
          .collection('discos')
          .doc(updated.id)
          .set(updated.toMap());
    } catch (_) {
      // handle error
    }
  }
}
