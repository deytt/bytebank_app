import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_in_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignInUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tUser = User(id: 'uid-1', email: 'user@test.com');
  const tEmail = 'user@test.com';
  const tPassword = 'senha123';

  test('retorna User quando o repositório autentica com sucesso', () async {
    when(() => mockRepository.signIn(tEmail, tPassword))
        .thenAnswer((_) async => tUser);

    final result = await useCase(tEmail, tPassword);

    expect(result, equals(tUser));
    verify(() => mockRepository.signIn(tEmail, tPassword)).called(1);
  });

  test('retorna null quando o repositório retorna null', () async {
    when(() => mockRepository.signIn(tEmail, tPassword))
        .thenAnswer((_) async => null);

    final result = await useCase(tEmail, tPassword);

    expect(result, isNull);
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.signIn(tEmail, tPassword))
        .thenThrow(Exception('E-mail ou senha incorretos'));

    expect(() => useCase(tEmail, tPassword), throwsException);
  });
}
