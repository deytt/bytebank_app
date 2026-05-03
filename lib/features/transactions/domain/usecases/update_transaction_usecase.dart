import 'package:image_picker/image_picker.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  Future<void> call(Transaction transaction, {XFile? receiptFile}) async {
    String? receiptUrl = transaction.receiptUrl;

    if (receiptFile != null) {
      if (receiptUrl != null) {
        await _repository.deleteReceipt(receiptUrl);
      }
      receiptUrl = await _repository.uploadReceipt(receiptFile, transaction.userId);
    }

    final updated = transaction.copyWith(receiptUrl: receiptUrl);
    await _repository.update(updated);
  }
}
