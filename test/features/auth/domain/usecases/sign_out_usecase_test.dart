import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_out_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignOutUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  test('chama signOut no repositório com sucesso', () async {
    when(() => mockRepository.signOut()).thenAnswer((_) async {});

    await useCase();

    verify(() => mockRepository.signOut()).called(1);
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.signOut())
        .thenThrow(Exception('Erro ao deslogar'));

    expect(() => useCase(), throwsException);
  });
}
