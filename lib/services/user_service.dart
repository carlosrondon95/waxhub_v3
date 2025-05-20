import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Carga información básica del usuario desde Auth + Firestore
  Future<Map<String, dynamic>> loadUserInfo() async {
    final user = _auth.currentUser!;
    final doc = await _db.collection('usuarios').doc(user.uid).get();
    final data = doc.exists ? doc.data()! : <String, dynamic>{};
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'nombre': data['nombre'] as String? ?? user.displayName,
      'nombreCambiado': data['nombreCambiado'] as bool? ?? false,
      'isGoogle': user.providerData.any((p) => p.providerId == 'google.com'),
    };
  }

  /// Verifica si nombre está libre
  Future<bool> isNameAvailable(String name) async {
    final snap =
        await _db
            .collection('usuarios')
            .where('nombre', isEqualTo: name.trim())
            .limit(1)
            .get();
    return snap.docs.isEmpty;
  }

  /// Actualiza el nombre en Firestore
  Future<void> updateName(String uid, String newName) {
    return _db.collection('usuarios').doc(uid).set({
      'nombre': newName.trim(),
      'nombreCambiado': true,
    }, SetOptions(merge: true));
  }

  /// Reautentica y actualiza contraseña
  Future<void> updatePassword(String oldPass, String newPass) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPass,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPass);
  }

  /// Cierra sesión
  Future<void> logout() => _auth.signOut();
}
