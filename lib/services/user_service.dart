// lib/services/user_service.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _st = FirebaseStorage.instance;

  /// Carga info de Auth + Firestore, incluyendo contador de cambios de nombre.
  Future<Map<String, dynamic>> loadUserInfo() async {
    final user = _auth.currentUser!;
    final doc = await _db.collection('usuarios').doc(user.uid).get();
    final data = doc.exists ? doc.data()! : <String, dynamic>{};
    final cambioCount = data['nombreCambioCount'] as int? ?? 0;
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'nombre': data['nombre'] as String? ?? user.displayName,
      'nombreCambioCount': cambioCount,
      'isGoogle': user.providerData.any((p) => p.providerId == 'google.com'),
      'avatarUrl': data['avatarUrl'] as String? ?? user.photoURL,
    };
  }

  /// Comprueba si ese nombre de usuario ya existe en Firestore
  Future<bool> isNameAvailable(String name) async {
    final snap =
        await _db
            .collection('usuarios')
            .where('nombre', isEqualTo: name.trim())
            .limit(1)
            .get();
    return snap.docs.isEmpty;
  }

  /// Comprueba si ese email ya existe en Firestore
  Future<bool> isEmailAvailable(String email) async {
    final snap =
        await _db
            .collection('usuarios')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();
    return snap.docs.isEmpty;
  }

  /// Incrementa contador y actualiza nombre
  Future<void> updateName(String newName) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('usuarios').doc(uid).set({
      'nombre': newName.trim(),
      'nombreCambioCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> updatePassword(String oldPass, String newPass) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPass,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPass);
  }

  Future<void> updateEmail(String password, String newEmail) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updateEmail(newEmail);
    await user.sendEmailVerification();
    await _db.collection('usuarios').doc(user.uid).set({
      'email': newEmail,
    }, SetOptions(merge: true));
  }

  /// Sube avatar dado en bytes (web y mobile)
  Future<String> uploadAvatarBytes(Uint8List data, String filename) async {
    final uid = _auth.currentUser!.uid;
    final ref = _st.ref().child('avatars/$uid-$filename');
    await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> updateAvatarUrl(String url) async {
    final user = _auth.currentUser!;
    await user.updatePhotoURL(url);
    await _db.collection('usuarios').doc(user.uid).set({
      'avatarUrl': url,
    }, SetOptions(merge: true));
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser!;
    final uid = user.uid;
    try {
      await _st.ref().child('avatars/$uid.jpg').delete();
    } catch (_) {}
    await _db.collection('usuarios').doc(uid).delete();
    await user.delete();
  }

  Future<void> logout() => _auth.signOut();
}
