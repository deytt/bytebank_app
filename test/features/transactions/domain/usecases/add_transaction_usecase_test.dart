import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/add_transaction_usecase.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;
  late AddTransactionUseCase useCase;

  setUpAll(registerFallbacks);

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  final tTransaction = Transaction(
    id: null,
    userId: 'user-1',
    title: 'Almoço',
    value: 35.0,
    category: 'Alimentação',
    type: TransactionType.expense,
    date: DateTime(2024, 6, 1),
  );

  test('chama apenas add quando receiptBytes é null', () async {
    when(() => mockRepository.add(any())).thenAnswer((_) async {});

    await useCase(tTransaction);

    verify(() => mockRepository.add(any())).called(1);
    verifyNever(() => mockRepository.uploadReceipt(any(), any()));
  });

  test('faz upload do recibo e chama add com receiptUrl quando receiptBytes é fornecido', () async {
    final tBytes = Uint8List.fromList([1, 2, 3]);
    const tUrl = 'https://storage.example.com/receipt.jpg';

    when(() => mockRepository.uploadReceipt(tBytes, 'user-1'))
        .thenAnswer((_) async => tUrl);
    when(() => mockRepository.add(any())).thenAnswer((_) async {});

    await useCase(tTransaction, receiptBytes: tBytes);

    verify(() => mockRepository.uploadReceipt(tBytes, 'user-1')).called(1);
    final captured = verify(() => mockRepository.add(captureAny())).captured;
    final addedTransaction = captured.first as Transaction;
    expect(addedTransaction.receiptUrl, equals(tUrl));
  });

  test('propaga Exception lançada pelo add no repositório', () async {
    when(() => mockRepository.add(any()))
        .thenThrow(Exception('Sem conexão'));

    expect(() => useCase(tTransaction), throwsException);
  });

  test('propaga Exception lançada pelo uploadReceipt', () async {
    final tBytes = Uint8List.fromList([1, 2, 3]);
    when(() => mockRepository.uploadReceipt(any(), any()))
        .thenThrow(Exception('Falha no upload'));

    expect(() => useCase(tTransaction, receiptBytes: tBytes), throwsException);
    verifyNever(() => mockRepository.add(any()));
  });
}
