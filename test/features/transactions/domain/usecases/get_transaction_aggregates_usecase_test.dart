import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/get_transaction_aggregates_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionAggregatesUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionAggregatesUseCase(mockRepository);
  });

  test('retorna o record com totalIncome e totalExpense do repositório', () async {
    const tAggregates = (totalIncome: 5000.0, totalExpense: 1200.0);
    when(() => mockRepository.getAggregates('user-1'))
        .thenAnswer((_) async => tAggregates);

    final result = await useCase('user-1');

    expect(result.totalIncome, equals(5000.0));
    expect(result.totalExpense, equals(1200.0));
    verify(() => mockRepository.getAggregates('user-1')).called(1);
  });

  test('retorna zeros quando não há transações', () async {
    const tAggregates = (totalIncome: 0.0, totalExpense: 0.0);
    when(() => mockRepository.getAggregates('user-1'))
        .thenAnswer((_) async => tAggregates);

    final result = await useCase('user-1');

    expect(result.totalIncome, equals(0.0));
    expect(result.totalExpense, equals(0.0));
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.getAggregates(any()))
        .thenThrow(Exception('Erro ao calcular totais'));

    expect(() => useCase('user-1'), throwsException);
  });
}
