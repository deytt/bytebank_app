import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  Future<void> call(Transaction transaction) async {
    if (transaction.receiptUrl != null) {
      await _repository.deleteReceipt(transaction.receiptUrl!);
    }
    await _repository.delete(transaction.id!);
  }
}
