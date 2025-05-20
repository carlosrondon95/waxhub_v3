import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;
  final _st   = FirebaseStorage.instance;

  Future<void> updateEmail(String password, String newEmail) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updateEmail(newEmail);
    await user.sendEmailVerification();
    await _db.collection('usuarios').doc(user.uid).set(
      {'email': newEmail},
      SetOptions(merge: true),
    );
  }

  Future<String> uploadAvatar(File file) async {
    final uid = _auth.currentUser!.uid;
    final ref = _st.ref().child('avatars/$uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> updateAvatarUrl(String url) async {
    final uid = _auth.currentUser!.uid;
    await _auth.currentUser!.updatePhotoURL(url);
    await _db.collection('usuarios').doc(uid).set(
      {'avatarUrl': url},
      SetOptions(merge: true),
    );
  }

  /// Borra los datos de Firestore y la cuenta de Auth
  Future<void> deleteAccount() async {
    final user = _auth.currentUser!;
    final uid = user.uid;
    await _db.collection('usuarios').doc(uid).delete();
    await user.delete();
  }
}
