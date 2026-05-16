import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_up_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignUpUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockRepository);
  });

  const tUser = User(id: 'uid-new', email: 'novo@test.com');
  const tEmail = 'novo@test.com';
  const tPassword = 'novaSenha123';

  test('retorna User criado quando o repositório registra com sucesso', () async {
    when(() => mockRepository.signUp(tEmail, tPassword))
        .thenAnswer((_) async => tUser);

    final result = await useCase(tEmail, tPassword);

    expect(result, equals(tUser));
    verify(() => mockRepository.signUp(tEmail, tPassword)).called(1);
  });

  test('retorna null quando o repositório retorna null', () async {
    when(() => mockRepository.signUp(tEmail, tPassword))
        .thenAnswer((_) async => null);

    final result = await useCase(tEmail, tPassword);

    expect(result, isNull);
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.signUp(tEmail, tPassword))
        .thenThrow(Exception('E-mail já cadastrado'));

    expect(() => useCase(tEmail, tPassword), throwsException);
  });
}
