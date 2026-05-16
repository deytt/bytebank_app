import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignInWithGoogleUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(mockRepository);
  });

  const tUser = User(
    id: 'google-uid-1',
    email: 'google@gmail.com',
    displayName: 'Google User',
    photoUrl: 'https://lh3.googleusercontent.com/photo.jpg',
  );

  test('retorna User quando o login com Google é bem-sucedido', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => tUser);

    final result = await useCase();

    expect(result, equals(tUser));
    verify(() => mockRepository.signInWithGoogle()).called(1);
  });

  test('retorna null quando o usuário cancela o login com Google', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isNull);
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.signInWithGoogle())
        .thenThrow(Exception('Erro ao fazer login com Google'));

    expect(() => useCase(), throwsException);
  });
}
