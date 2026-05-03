import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<TransactionPage> call(
    String userId, {
    Object? pageToken,
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int? dateRangeDays,
    TransactionType? type,
    int limit = 20,
  }) {
    return _repository.getTransactionsPaginated(
      userId,
      pageToken: pageToken,
      category: category,
      searchTitle: searchTitle,
      hasReceipt: hasReceipt,
      dateRangeDays: dateRangeDays,
      type: type,
      limit: limit,
    );
  }
}
