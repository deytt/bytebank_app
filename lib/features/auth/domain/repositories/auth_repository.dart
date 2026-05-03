import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
}
