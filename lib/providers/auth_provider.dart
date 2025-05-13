import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => _auth.currentUser != null;

  /// Iniciar sesión con email y contraseña
  Future<String?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        return 'Debes verificar tu correo antes de iniciar sesión.';
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Iniciar sesión con Google
  Future<String?> signInWithGoogle() async {
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

      if (isNewUser && _auth.currentUser != null) {
        await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).set(
          {
            'email': _auth.currentUser!.email,
            'nombre': googleUser.displayName ?? '',
          },
        );
      }

      notifyListeners();
      return null;
    } catch (e) {
      return 'Error al iniciar sesión con Google: ${e.toString()}';
    }
  }

  /// Enviar correo para restablecer contraseña
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Reenviar correo de verificación
  Future<String?> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return null;
      } else {
        return 'El usuario ya está verificado o no existe.';
      }
    } catch (e) {
      return 'Error al enviar el correo de verificación.';
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
