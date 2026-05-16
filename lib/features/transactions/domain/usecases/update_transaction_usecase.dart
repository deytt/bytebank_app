import 'dart:typed_data';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  Future<void> call(Transaction transaction, {Uint8List? receiptBytes}) async {
    String? receiptUrl = transaction.receiptUrl;

    if (receiptBytes != null) {
      if (receiptUrl != null) {
        await _repository.deleteReceipt(receiptUrl);
      }
      receiptUrl = await _repository.uploadReceipt(receiptBytes, transaction.userId);
    }

    final updated = transaction.copyWith(receiptUrl: receiptUrl);
    await _repository.update(updated);
  }
}
