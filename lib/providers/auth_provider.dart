import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Comprueba si ya existe un usuario con ese nombre en Firestore.
  Future<bool> usernameExists(String name) async {
    final snap = await _firestore
        .collection(FirestoreCollections.usuarios)
        .where('nombre', isEqualTo: name.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Comprueba si ya existe un usuario con ese email en Firestore.
  Future<bool> emailExists(String email) async {
    final snap = await _firestore
        .collection(FirestoreCollections.usuarios)
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String?> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        return 'Debes verificar tu correo antes de iniciar sesión.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Inicio de sesión cancelado.';
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser && currentUser != null) {
        await _firestore
            .collection(FirestoreCollections.usuarios)
            .doc(currentUser!.uid)
            .set({
              'email': currentUser!.email,
              'nombre': googleUser.displayName ?? '',
            });
      }
      return null;
    } catch (e) {
      return 'Error al iniciar sesión con Google: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> resendEmailVerification() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return null;
      }
      return 'El usuario ya está verificado o no existe.';
    } catch (_) {
      return 'Error al enviar el correo de verificación.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.sendEmailVerification();
      await _firestore
          .collection(FirestoreCollections.usuarios)
          .doc(cred.user!.uid)
          .set({
            'nombre': name.trim(),
            'email': email.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error al registrar usuario: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
