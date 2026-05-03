import 'package:image_picker/image_picker.dart';
import '../entities/transaction.dart';

class TransactionPage {
  final List<Transaction> transactions;
  final bool hasMore;

  /// Opaque cursor used internally by the repository implementation for pagination.
  /// The BLoC stores it and passes it back on the next page request.
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

  Future<String> uploadReceipt(XFile file, String userId);

  Future<void> deleteReceipt(String url);
}
