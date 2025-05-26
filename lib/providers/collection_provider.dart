// lib/providers/collection_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vinyl_record.dart';
import '../services/discogs_service.dart';

/// Modo de sincronización con Discogs
enum SyncMode { manual, auto }

class CollectionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DiscogsService _discogsService = DiscogsService();

  StreamSubscription<QuerySnapshot>? _subscription;

  /* ─── Colección ───────────────────────────────────────── */
  List<VinylRecord> _allRecords = [];
  String _searchQuery = '';
  String _sortBy = 'titulo';
  bool _showFavorites = false;
  String _viewMode = 'lista';
  bool _isLoading = false;

  /* ─── Ajustes Discogs ─────────────────────────────────── */
  SyncMode syncMode = SyncMode.manual;
  int autoSyncHours = 24;

  /* ─── Constructor ─────────────────────────────────────── */
  CollectionProvider() {
    _loadDiscogsSettings();
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

  /// Carga desde SharedPreferences los ajustes de Discogs
  Future<void> _loadDiscogsSettings() async {
    final sp = await SharedPreferences.getInstance();
    syncMode = SyncMode.values[sp.getInt('discogs_sync_mode') ?? 0];
    autoSyncHours = sp.getInt('discogs_auto_sync_hours') ?? autoSyncHours;
    notifyListeners();
  }

  /// Persiste en SharedPreferences los ajustes de Discogs
  Future<void> saveDiscogsSettings() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('discogs_sync_mode', syncMode.index);
    await sp.setInt('discogs_auto_sync_hours', autoSyncHours);
  }

  /// Importa toda la colección desde Discogs
  Future<void> importFromDiscogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      // Usa displayName, o extrae username de email si prefieres
      final username =
          user.displayName ?? user.email?.split('@')[0] ?? user.uid;
      await _discogsService.importCollection(username);
      _subscribeToRecords(user.uid);
    } catch (e) {
      debugPrint('Error importando de Discogs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza manualmente la colección desde Discogs
  Future<void> updateFromDiscogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      final username =
          user.displayName ?? user.email?.split('@')[0] ?? user.uid;
      await _discogsService.updateCollection(username);
      _subscribeToRecords(user.uid);
    } catch (e) {
      debugPrint('Error actualizando de Discogs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  SyncMode get discogsSyncMode => syncMode;
  int get discogsAutoSyncHours => autoSyncHours;

  /* ─── Setters (filtros, vista y Discogs) ───────────────── */

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

  void setDiscogsSyncMode(SyncMode mode) {
    syncMode = mode;
    notifyListeners();
  }

  void setDiscogsAutoSyncHours(int hours) {
    autoSyncHours = hours;
    notifyListeners();
  }

  /* ─── Operaciones de escritura ────────────────────────── */

  Future<void> deleteRecord(String id) async {
    await _firestore.collection('discos').doc(id).delete();
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
