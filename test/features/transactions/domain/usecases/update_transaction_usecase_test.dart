import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/update_transaction_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late UpdateTransactionUseCase useCase;

  setUpAll(registerFallbacks);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = UpdateTransactionUseCase(mockRepository);
  });

  final tTransactionSemRecibo = Transaction(
    id: 'tx-1',
    userId: 'user-1',
    title: 'Mercado',
    value: 200.0,
    category: 'Alimentação',
    type: TransactionType.expense,
    date: DateTime(2024, 6, 1),
    receiptUrl: null,
  );

  final tTransactionComRecibo = tTransactionSemRecibo.copyWith(
    receiptUrl: 'https://storage.example.com/old_receipt.jpg',
  );

  test('chama apenas update quando receiptBytes é null', () async {
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await useCase(tTransactionSemRecibo);

    verify(() => mockRepository.update(any())).called(1);
    verifyNever(() => mockRepository.uploadReceipt(any(), any()));
    verifyNever(() => mockRepository.deleteReceipt(any()));
  });

  test('faz upload e chama update sem deletar quando não há receiptUrl anterior', () async {
    final tBytes = Uint8List.fromList([4, 5, 6]);
    const tNewUrl = 'https://storage.example.com/new_receipt.jpg';

    when(() => mockRepository.uploadReceipt(tBytes, 'user-1'))
        .thenAnswer((_) async => tNewUrl);
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await useCase(tTransactionSemRecibo, receiptBytes: tBytes);

    verifyNever(() => mockRepository.deleteReceipt(any()));
    verify(() => mockRepository.uploadReceipt(tBytes, 'user-1')).called(1);
    final captured = verify(() => mockRepository.update(captureAny())).captured;
    final updated = captured.first as Transaction;
    expect(updated.receiptUrl, equals(tNewUrl));
  });

  test('deleta recibo antigo, faz upload e chama update quando há receiptUrl anterior', () async {
    final tBytes = Uint8List.fromList([7, 8, 9]);
    const tOldUrl = 'https://storage.example.com/old_receipt.jpg';
    const tNewUrl = 'https://storage.example.com/new_receipt.jpg';

    when(() => mockRepository.deleteReceipt(tOldUrl)).thenAnswer((_) async {});
    when(() => mockRepository.uploadReceipt(tBytes, 'user-1'))
        .thenAnswer((_) async => tNewUrl);
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await useCase(tTransactionComRecibo, receiptBytes: tBytes);

    verify(() => mockRepository.deleteReceipt(tOldUrl)).called(1);
    verify(() => mockRepository.uploadReceipt(tBytes, 'user-1')).called(1);
    final captured = verify(() => mockRepository.update(captureAny())).captured;
    final updated = captured.first as Transaction;
    expect(updated.receiptUrl, equals(tNewUrl));
  });

  test('mantém receiptUrl original quando receiptBytes é null e já havia recibo', () async {
    when(() => mockRepository.update(any())).thenAnswer((_) async {});

    await useCase(tTransactionComRecibo);

    final captured = verify(() => mockRepository.update(captureAny())).captured;
    final updated = captured.first as Transaction;
    expect(updated.receiptUrl, equals(tTransactionComRecibo.receiptUrl));
  });

  test('propaga Exception lançada pelo update', () async {
    when(() => mockRepository.update(any()))
        .thenThrow(Exception('Sem conexão'));

    expect(() => useCase(tTransactionSemRecibo), throwsException);
  });
}
