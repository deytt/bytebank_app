import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/domain/usecases/watch_auth_state_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late WatchAuthStateUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = WatchAuthStateUseCase(mockRepository);
  });

  const tUser = User(id: 'uid-stream', email: 'stream@test.com');

  test('retorna stream que emite User quando usuário está autenticado', () {
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(tUser));

    final stream = useCase();

    expect(stream, emits(tUser));
  });

  test('retorna stream que emite null quando usuário não está autenticado', () {
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(null));

    final stream = useCase();

    expect(stream, emits(isNull));
  });

  test('retorna stream que emite múltiplos valores em sequência', () {
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => Stream.fromIterable([null, tUser, null]));

    final stream = useCase();

    expect(stream, emitsInOrder([isNull, tUser, isNull]));
  });
}
