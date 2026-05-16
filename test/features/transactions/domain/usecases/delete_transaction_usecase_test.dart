import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/delete_transaction_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late DeleteTransactionUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransactionUseCase(mockRepository);
  });

  final tTransactionSemRecibo = Transaction(
    id: 'tx-1',
    userId: 'user-1',
    title: 'Conta de luz',
    value: 150.0,
    category: 'Moradia',
    type: TransactionType.expense,
    date: DateTime(2024, 6, 1),
    receiptUrl: null,
  );

  final tTransactionComRecibo = tTransactionSemRecibo.copyWith(
    receiptUrl: 'https://storage.example.com/receipt.jpg',
  );

  test('chama apenas delete quando não há receiptUrl', () async {
    when(() => mockRepository.delete('tx-1')).thenAnswer((_) async {});

    await useCase(tTransactionSemRecibo);

    verify(() => mockRepository.delete('tx-1')).called(1);
    verifyNever(() => mockRepository.deleteReceipt(any()));
  });

  test('chama deleteReceipt e depois delete quando há receiptUrl', () async {
    const tUrl = 'https://storage.example.com/receipt.jpg';
    when(() => mockRepository.deleteReceipt(tUrl)).thenAnswer((_) async {});
    when(() => mockRepository.delete('tx-1')).thenAnswer((_) async {});

    await useCase(tTransactionComRecibo);

    verify(() => mockRepository.deleteReceipt(tUrl)).called(1);
    verify(() => mockRepository.delete('tx-1')).called(1);
  });

  test('propaga Exception lançada pelo delete', () async {
    when(() => mockRepository.delete(any()))
        .thenThrow(Exception('Sem conexão'));

    expect(() => useCase(tTransactionSemRecibo), throwsException);
  });

  test('propaga Exception lançada pelo deleteReceipt', () async {
    when(() => mockRepository.deleteReceipt(any()))
        .thenThrow(Exception('Falha ao deletar recibo'));

    expect(() => useCase(tTransactionComRecibo), throwsException);
    verifyNever(() => mockRepository.delete(any()));
  });
}
