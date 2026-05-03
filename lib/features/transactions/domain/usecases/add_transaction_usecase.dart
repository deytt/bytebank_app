import 'package:image_picker/image_picker.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<void> call(Transaction transaction, {XFile? receiptFile}) async {
    String? receiptUrl;
    if (receiptFile != null) {
      receiptUrl = await _repository.uploadReceipt(receiptFile, transaction.userId);
    }
    final withReceipt = transaction.copyWith(receiptUrl: receiptUrl);
    await _repository.add(withReceipt);
  }
}
