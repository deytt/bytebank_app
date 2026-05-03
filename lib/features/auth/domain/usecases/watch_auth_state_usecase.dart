import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  Stream<User?> call() => _repository.authStateChanges;
}
