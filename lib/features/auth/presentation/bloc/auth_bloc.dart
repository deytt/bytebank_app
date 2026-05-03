import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;

  AuthBloc({
    required WatchAuthStateUseCase watchAuthState,
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
  })  : _watchAuthState = watchAuthState,
        _signIn = signIn,
        _signUp = signUp,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await emit.forEach<User?>(
      _watchAuthState(),
      onData: (user) {
        if (user != null) {
          return AuthAuthenticated(
            UserModel(
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              photoUrl: user.photoUrl,
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
      final user = await _signIn(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(UserModel(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        )));
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
      final user = await _signUp(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(UserModel(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        )));
      } else {
        emit(const AuthError('Falha ao criar conta'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(UserModel(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        )));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }
}
