import 'package:flutter_test/flutter_test.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';

void main() {
  final baseDate = DateTime(2024, 6, 15);

  final transaction = Transaction(
    id: 'tx-001',
    userId: 'user-123',
    title: 'Salário',
    value: 5000.0,
    category: 'Renda',
    type: TransactionType.income,
    date: baseDate,
    receiptUrl: null,
  );

  group('Transaction.copyWith', () {
    test('retorna cópia com todos os campos originais quando nenhum parâmetro é passado', () {
      final copy = transaction.copyWith();

      expect(copy.id, equals(transaction.id));
      expect(copy.userId, equals(transaction.userId));
      expect(copy.title, equals(transaction.title));
      expect(copy.value, equals(transaction.value));
      expect(copy.category, equals(transaction.category));
      expect(copy.type, equals(transaction.type));
      expect(copy.date, equals(transaction.date));
      expect(copy.receiptUrl, isNull);
    });

    test('atualiza apenas os campos informados mantendo os demais', () {
      final updated = transaction.copyWith(
        title: 'Salário Atualizado',
        value: 6000.0,
      );

      expect(updated.title, equals('Salário Atualizado'));
      expect(updated.value, equals(6000.0));
      expect(updated.id, equals(transaction.id));
      expect(updated.userId, equals(transaction.userId));
      expect(updated.category, equals(transaction.category));
      expect(updated.type, equals(transaction.type));
      expect(updated.date, equals(transaction.date));
    });

    test('substitui todos os campos quando todos os parâmetros são fornecidos', () {
      final newDate = DateTime(2025, 1, 1);
      final updated = transaction.copyWith(
        id: 'tx-999',
        userId: 'user-456',
        title: 'Aluguel',
        value: 1200.0,
        category: 'Moradia',
        type: TransactionType.expense,
        date: newDate,
        receiptUrl: 'https://storage.example.com/receipt.jpg',
      );

      expect(updated.id, equals('tx-999'));
      expect(updated.userId, equals('user-456'));
      expect(updated.title, equals('Aluguel'));
      expect(updated.value, equals(1200.0));
      expect(updated.category, equals('Moradia'));
      expect(updated.type, equals(TransactionType.expense));
      expect(updated.date, equals(newDate));
      expect(updated.receiptUrl, equals('https://storage.example.com/receipt.jpg'));
    });

    test('pode atualizar o tipo de income para expense', () {
      final updated = transaction.copyWith(type: TransactionType.expense);
      expect(updated.type, equals(TransactionType.expense));
      expect(transaction.type, equals(TransactionType.income));
    });

    test('pode definir receiptUrl em uma transação sem recibo', () {
      final updated = transaction.copyWith(receiptUrl: 'https://example.com/rec.jpg');
      expect(updated.receiptUrl, equals('https://example.com/rec.jpg'));
    });
  });

  group('TransactionType', () {
    test('contém os valores income e expense', () {
      expect(TransactionType.values, containsAll([TransactionType.income, TransactionType.expense]));
    });
  });
}
