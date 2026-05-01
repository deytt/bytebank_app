import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach<dynamic>(
      _authService.authStateChanges,
      onData: (firebaseUser) {
        if (firebaseUser != null) {
          return AuthAuthenticated(
            UserModel(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoUrl: firebaseUser.photoURL,
            ),
          );
        }
        return const AuthUnauthenticated();
      },
      onError: (error, stackTrace) => const AuthUnauthenticated(),
    );
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signIn(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Falha ao autenticar'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signUp(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Falha ao criar conta'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
