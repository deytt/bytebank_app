import '../repositories/transaction_repository.dart';

class GetTransactionAggregatesUseCase {
  final TransactionRepository _repository;

  GetTransactionAggregatesUseCase(this._repository);

  Future<({double totalIncome, double totalExpense})> call(String userId) =>
      _repository.getAggregates(userId);
}
