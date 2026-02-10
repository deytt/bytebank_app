import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        return UserModel(id: credential.user!.uid, email: credential.user!.email!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao fazer login');
    }
  }

  Future<UserModel?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return UserModel(id: credential.user!.uid, email: credential.user!.email!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao criar conta');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
