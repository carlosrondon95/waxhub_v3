import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /* ───────────── Helpers en Firestore ───────────── */

  Future<bool> usernameExists(String name) async {
    final snap = await _firestore
        .collection('usuarios')
        .where('nombre', isEqualTo: name.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> emailExists(String email) async {
    final snap = await _firestore
        .collection('usuarios')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /* ───────────── Login con e-mail ───────────── */

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Login con Google ───────────── */

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
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

      // Guardar usuario nuevo
      if ((result.additionalUserInfo?.isNewUser ?? false) &&
          currentUser != null) {
        await _firestore.collection('usuarios').doc(currentUser!.uid).set({
          'email': currentUser!.email,
          'nombre': googleUser.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } catch (e) {
      return 'Error al iniciar sesión con Google: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Restablecer contraseña ───────────── */

  Future<String?> sendPasswordReset(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Reenviar verificación ───────────── */

  Future<String?> resendEmailVerification() async {
    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Registro ───────────── */

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1) Crear la cuenta
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2) Enviar email de verificación
      await cred.user!.sendEmailVerification();

      // 3) Guardar en Firestore
      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4) Cerrar sesión para que el router NO redirija a /home
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error al registrar usuario: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ───────────── Logout ───────────── */

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
