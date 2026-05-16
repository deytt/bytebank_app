import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/get_transactions_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  final tDate = DateTime(2024, 6, 1);
  final tTransaction = Transaction(
    id: 'tx-1',
    userId: 'user-1',
    title: 'Salário',
    value: 3000.0,
    category: 'Renda',
    type: TransactionType.income,
    date: tDate,
  );

  final tPage = TransactionPage(
    transactions: [tTransaction],
    hasMore: false,
    cursor: null,
  );

  test('retorna TransactionPage delegando ao repositório sem filtros', () async {
    when(() => mockRepository.getTransactionsPaginated(
          'user-1',
          pageToken: any(named: 'pageToken'),
          category: any(named: 'category'),
          searchTitle: any(named: 'searchTitle'),
          hasReceipt: any(named: 'hasReceipt'),
          dateRangeDays: any(named: 'dateRangeDays'),
          type: any(named: 'type'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => tPage);

    final result = await useCase('user-1');

    expect(result.transactions, equals(tPage.transactions));
    expect(result.hasMore, isFalse);
    verify(() => mockRepository.getTransactionsPaginated(
          'user-1',
          pageToken: null,
          category: null,
          searchTitle: null,
          hasReceipt: null,
          dateRangeDays: null,
          type: null,
          limit: 20,
        )).called(1);
  });

  test('repassa todos os filtros opcionais ao repositório', () async {
    when(() => mockRepository.getTransactionsPaginated(
          'user-1',
          pageToken: any(named: 'pageToken'),
          category: any(named: 'category'),
          searchTitle: any(named: 'searchTitle'),
          hasReceipt: any(named: 'hasReceipt'),
          dateRangeDays: any(named: 'dateRangeDays'),
          type: any(named: 'type'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => tPage);

    await useCase(
      'user-1',
      category: 'Alimentação',
      searchTitle: 'mercado',
      hasReceipt: true,
      dateRangeDays: 30,
      type: TransactionType.expense,
      limit: 50,
    );

    verify(() => mockRepository.getTransactionsPaginated(
          'user-1',
          pageToken: null,
          category: 'Alimentação',
          searchTitle: 'mercado',
          hasReceipt: true,
          dateRangeDays: 30,
          type: TransactionType.expense,
          limit: 50,
        )).called(1);
  });

  test('propaga Exception lançada pelo repositório', () async {
    when(() => mockRepository.getTransactionsPaginated(
          any(),
          pageToken: any(named: 'pageToken'),
          category: any(named: 'category'),
          searchTitle: any(named: 'searchTitle'),
          hasReceipt: any(named: 'hasReceipt'),
          dateRangeDays: any(named: 'dateRangeDays'),
          type: any(named: 'type'),
          limit: any(named: 'limit'),
        )).thenThrow(Exception('Erro ao carregar transações'));

    expect(() => useCase('user-1'), throwsException);
  });
}
