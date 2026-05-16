import 'dart:typed_data';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<void> call(Transaction transaction, {Uint8List? receiptBytes}) async {
    String? receiptUrl;
    if (receiptBytes != null) {
      receiptUrl = await _repository.uploadReceipt(receiptBytes, transaction.userId);
    }
    final withReceipt = transaction.copyWith(receiptUrl: receiptUrl);
    await _repository.add(withReceipt);
  }
}
