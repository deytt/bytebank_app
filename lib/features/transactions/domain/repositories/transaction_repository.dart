import 'package:image_picker/image_picker.dart';
import '../entities/transaction.dart';

class TransactionPage {
  final List<Transaction> transactions;
  final bool hasMore;

  final Object? cursor;

  const TransactionPage({
    required this.transactions,
    required this.hasMore,
    this.cursor,
  });
}

abstract class TransactionRepository {
  Future<TransactionPage> getTransactionsPaginated(
    String userId, {
    Object? pageToken,
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int? dateRangeDays,
    TransactionType? type,
    int limit,
  });

  Future<void> add(Transaction transaction);

  Future<void> update(Transaction transaction);

  Future<void> delete(String id);

  Future<({double totalIncome, double totalExpense})> getAggregates(String userId);

  Future<String> uploadReceipt(XFile file, String userId);

  Future<void> deleteReceipt(String url);
}
