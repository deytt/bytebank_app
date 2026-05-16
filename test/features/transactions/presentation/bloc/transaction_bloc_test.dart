import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebankapp/features/transactions/presentation/bloc/transaction_bloc.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetTransactionsUseCase mockGetTransactions;
  late MockGetTransactionAggregatesUseCase mockGetAggregates;
  late MockAddTransactionUseCase mockAddTransaction;
  late MockUpdateTransactionUseCase mockUpdateTransaction;
  late MockDeleteTransactionUseCase mockDeleteTransaction;

  setUpAll(registerFallbacks);

  setUp(() {
    mockGetTransactions = MockGetTransactionsUseCase();
    mockGetAggregates = MockGetTransactionAggregatesUseCase();
    mockAddTransaction = MockAddTransactionUseCase();
    mockUpdateTransaction = MockUpdateTransactionUseCase();
    mockDeleteTransaction = MockDeleteTransactionUseCase();
  });

  TransactionBloc buildBloc() => TransactionBloc(
        getTransactions: mockGetTransactions,
        getAggregates: mockGetAggregates,
        addTransaction: mockAddTransaction,
        updateTransaction: mockUpdateTransaction,
        deleteTransaction: mockDeleteTransaction,
      );

  final tDate = DateTime(2024, 6, 1);

  Transaction makeTransaction({String id = 'tx-1'}) => Transaction(
        id: id,
        userId: 'user-1',
        title: 'Salário',
        value: 3000.0,
        category: 'Renda',
        type: TransactionType.income,
        date: tDate,
      );

  final tTransaction = makeTransaction();

  TransactionPage makePage(List<Transaction> txs, {bool hasMore = false}) =>
      TransactionPage(transactions: txs, hasMore: hasMore, cursor: null);

  const tAggregates = (totalIncome: 3000.0, totalExpense: 0.0);

  void stubLoadSuccess({
    List<Transaction>? transactions,
    bool hasMore = false,
  }) {
    final txs = transactions ?? [tTransaction];
    when(() => mockGetTransactions(
          any(),
          pageToken: any(named: 'pageToken'),
          category: any(named: 'category'),
          searchTitle: any(named: 'searchTitle'),
          hasReceipt: any(named: 'hasReceipt'),
          dateRangeDays: any(named: 'dateRangeDays'),
          type: any(named: 'type'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => makePage(txs, hasMore: hasMore));
    when(() => mockGetAggregates(any())).thenAnswer((_) async => tAggregates);
  }

  void stubLoadFailure() {
    when(() => mockGetTransactions(
          any(),
          pageToken: any(named: 'pageToken'),
          category: any(named: 'category'),
          searchTitle: any(named: 'searchTitle'),
          hasReceipt: any(named: 'hasReceipt'),
          dateRangeDays: any(named: 'dateRangeDays'),
          type: any(named: 'type'),
          limit: any(named: 'limit'),
        )).thenThrow(Exception('Erro de rede'));
    when(() => mockGetAggregates(any())).thenThrow(Exception('Erro de rede'));
  }

  group('LoadTransactions', () {
    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionLoading e TransactionLoaded com sucesso',
      build: () {
        stubLoadSuccess();
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadTransactions(userId: 'user-1')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>()
            .having((s) => s.transactions, 'transactions', [tTransaction])
            .having((s) => s.totalIncome, 'totalIncome', 3000.0)
            .having((s) => s.isFromCache, 'isFromCache', isFalse),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionLoading e TransactionError quando todas as fontes falham',
      build: () {
        stubLoadFailure();
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadTransactions(userId: 'user-1')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionError>(),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionLoaded com isFromCache=true quando apenas aggregates carrega',
      build: () {
        when(() => mockGetTransactions(
              any(),
              pageToken: any(named: 'pageToken'),
              category: any(named: 'category'),
              searchTitle: any(named: 'searchTitle'),
              hasReceipt: any(named: 'hasReceipt'),
              dateRangeDays: any(named: 'dateRangeDays'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('Erro'));
        when(() => mockGetAggregates(any())).thenAnswer((_) async => tAggregates);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadTransactions(userId: 'user-1')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>()
            .having((s) => s.isFromCache, 'isFromCache', isTrue),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'reseta cursor ao usar refresh=true',
      build: () {
        stubLoadSuccess();
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadTransactions(userId: 'user-1', refresh: true)),
      expect: () => [isA<TransactionLoading>(), isA<TransactionLoaded>()],
    );
  });

  group('LoadMoreTransactions', () {
    blocTest<TransactionBloc, TransactionState>(
      'acumula transações quando hasMore é true',
      build: () {
        final firstTx = makeTransaction(id: 'tx-1');
        final secondTx = makeTransaction(id: 'tx-2');

        var callCount = 0;
        when(() => mockGetTransactions(
              any(),
              pageToken: any(named: 'pageToken'),
              category: any(named: 'category'),
              searchTitle: any(named: 'searchTitle'),
              hasReceipt: any(named: 'hasReceipt'),
              dateRangeDays: any(named: 'dateRangeDays'),
              type: any(named: 'type'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return makePage([firstTx], hasMore: true);
          return makePage([secondTx], hasMore: false);
        });
        when(() => mockGetAggregates(any())).thenAnswer((_) async => tAggregates);

        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(LoadTransactions(userId: 'user-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const LoadMoreTransactions());
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>().having((s) => s.transactions.length, 'length', 1),
        isA<TransactionLoaded>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<TransactionLoaded>().having((s) => s.transactions.length, 'length', 2),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'não emite nenhum estado quando hasMore é false',
      build: () {
        stubLoadSuccess(hasMore: false);
        return buildBloc();
      },
      seed: () => TransactionLoaded(
        transactions: [tTransaction],
        allTransactions: const [],
        totalIncome: 3000.0,
        totalExpense: 0.0,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreTransactions()),
      expect: () => [],
    );
  });

  group('AddTransactionRequested', () {
    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionActionSuccess após adicionar com sucesso',
      build: () {
        stubLoadSuccess();
        when(() => mockAddTransaction(any(), receiptBytes: any(named: 'receiptBytes')))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(LoadTransactions(userId: 'user-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(AddTransactionRequested(transaction: tTransaction));
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
        isA<TransactionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<TransactionActionSuccess>(),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionActionFailure quando add falha',
      build: () {
        when(() => mockAddTransaction(any(), receiptBytes: any(named: 'receiptBytes')))
            .thenThrow(Exception('Sem conexão'));
        return buildBloc();
      },
      seed: () => TransactionLoaded(
        transactions: const [],
        allTransactions: const [],
        totalIncome: 0.0,
        totalExpense: 0.0,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(AddTransactionRequested(transaction: tTransaction)),
      expect: () => [
        isA<TransactionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<TransactionActionFailure>()
            .having((s) => s.message, 'message', 'Sem conexão'),
      ],
    );
  });

  group('UpdateTransactionRequested', () {
    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionActionSuccess após atualizar com sucesso',
      build: () {
        stubLoadSuccess();
        when(() => mockUpdateTransaction(any(), receiptBytes: any(named: 'receiptBytes')))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => TransactionLoaded(
        transactions: [tTransaction],
        allTransactions: const [],
        totalIncome: 3000.0,
        totalExpense: 0.0,
        hasMore: false,
      ),
      act: (bloc) async {
        bloc.add(LoadTransactions(userId: 'user-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(UpdateTransactionRequested(transaction: tTransaction));
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
        isA<TransactionLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
        isA<TransactionActionSuccess>(),
      ],
    );
  });

  group('DeleteTransactionRequested', () {
    blocTest<TransactionBloc, TransactionState>(
      'emite TransactionActionSuccess após deletar com sucesso',
      build: () {
        stubLoadSuccess();
        when(() => mockDeleteTransaction(any())).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(LoadTransactions(userId: 'user-1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(DeleteTransactionRequested(tTransaction));
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
        isA<TransactionActionSuccess>()
            .having((s) => s.message, 'message', 'Transação excluída com sucesso'),
      ],
    );
  });

  group('ClearTransactionFilters', () {
    blocTest<TransactionBloc, TransactionState>(
      'recarrega transações sem filtros após limpar filtros',
      build: () {
        stubLoadSuccess();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(LoadTransactions(userId: 'user-1', category: 'Alimentação'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const ClearTransactionFilters());
      },
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
        isA<TransactionLoading>(),
        isA<TransactionLoaded>(),
      ],
    );
  });
}
