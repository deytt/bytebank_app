import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchAuthStateUseCase mockWatchAuthState;
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignOutUseCase mockSignOut;

  setUpAll(registerFallbacks);

  setUp(() {
    mockWatchAuthState = MockWatchAuthStateUseCase();
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignOut = MockSignOutUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        watchAuthState: mockWatchAuthState,
        signIn: mockSignIn,
        signUp: mockSignUp,
        signInWithGoogle: mockSignInWithGoogle,
        signOut: mockSignOut,
      );

  const tUser = User(id: 'uid-1', email: 'user@test.com', displayName: 'Test User');

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthAuthenticated quando stream retorna usuário autenticado',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => Stream.value(tUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthUnauthenticated quando stream retorna null',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => Stream.value(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthUnauthenticated quando stream emite erro',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer(
          (_) => Stream.error(Exception('Erro de autenticação')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite estados corretos para múltiplos valores do stream',
      build: () {
        when(() => mockWatchAuthState())
            .thenAnswer((_) => Stream.fromIterable([null, tUser]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [isA<AuthUnauthenticated>(), isA<AuthAuthenticated>()],
    );
  });

  group('AuthSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthAuthenticated quando login é bem-sucedido',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignIn('user@test.com', 'senha123'))
            .thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'user@test.com',
        password: 'senha123',
      )),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthError quando login falha',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignIn(any(), any()))
            .thenThrow(Exception('E-mail ou senha incorretos'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'wrong@test.com',
        password: 'wrongpass',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'E-mail ou senha incorretos'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthError quando signIn retorna null',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignIn(any(), any())).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'user@test.com',
        password: 'senha123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'Falha ao autenticar'),
      ],
    );
  });

  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthAuthenticated quando cadastro é bem-sucedido',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignUp('novo@test.com', 'novaSenha123'))
            .thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: 'novo@test.com',
        password: 'novaSenha123',
      )),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthError quando cadastro falha',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignUp(any(), any()))
            .thenThrow(Exception('E-mail já cadastrado'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: 'existing@test.com',
        password: 'senha123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'E-mail já cadastrado'),
      ],
    );
  });

  group('AuthGoogleSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthAuthenticated quando Google Sign-In é bem-sucedido',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignInWithGoogle()).thenAnswer((_) async => tUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthUnauthenticated quando usuário cancela Google Sign-In',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignInWithGoogle()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite AuthLoading e AuthError quando Google Sign-In falha',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignInWithGoogle())
            .thenThrow(Exception('Erro ao fazer login com Google'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite AuthUnauthenticated após signOut',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => const Stream.empty());
        when(() => mockSignOut()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
