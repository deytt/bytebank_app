import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '1093070321011-81cc1bqi3l74sifg5nqql0iab0qtudgc.apps.googleusercontent.com'
        : null,
  );

  @override
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
      );
    });
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFirebaseUser(credential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFirebaseUser(credential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return _fromFirebaseUser(userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  UserModel? _fromFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  Exception _mapFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuário não encontrado');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'invalid-credential':
        return Exception('E-mail ou senha incorretos');
      case 'email-already-in-use':
        return Exception('E-mail já cadastrado');
      case 'invalid-email':
        return Exception('E-mail inválido');
      case 'weak-password':
        return Exception('Senha muito fraca');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde');
      default:
        return Exception('Erro de autenticação');
    }
  }
}
