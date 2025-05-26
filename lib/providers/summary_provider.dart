import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryProvider extends ChangeNotifier {
  bool isLoading = false;
  int addedCount = 0;
  int favoritedCount = 0;

  /// Carga el resumen de los últimos [days] días
  Future<void> loadSummary(int days) async {
    isLoading = true;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user logged in; skipping summary load');
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final since = DateTime.now().subtract(Duration(days: days));
      debugPrint('Loading summary for user=${user.uid}, since=$since');

      // Discos añadidos
      final addedQuery = FirebaseFirestore.instance
          .collection('discos')
          .where('userId', isEqualTo: user.uid)
          .where('addedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('addedAt');
      final addedSnap = await addedQuery.get();
      debugPrint('Added query returned ${addedSnap.size} documents');
      addedCount = addedSnap.size;

      // Favoritos marcados
      final favQuery = FirebaseFirestore.instance
          .collection('discos')
          .where('userId', isEqualTo: user.uid)
          .where(
            'favoritedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(since),
          )
          .orderBy('favoritedAt');
      final favSnap = await favQuery.get();
      debugPrint('Favorited query returned ${favSnap.size} documents');
      favoritedCount = favSnap.size;
    } on FirebaseException catch (e) {
      debugPrint('Error cargando resumen: ${e.message}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
