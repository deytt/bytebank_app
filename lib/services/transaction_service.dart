import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection(_collection).add(transaction.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar transação');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.id == null) {
        throw Exception('ID da transação não pode ser nulo');
      }
      await _firestore.collection(_collection).doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar transação');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar transação');
    }
  }

  Future<Map<String, dynamic>> getTransactionsPaginated(
    String userId, {
    DocumentSnapshot? lastDocument,
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int? dateRangeDays,
    TransactionType? type,
    int limit = 20,
  }) async {
    try {
      final hasLocalFilter =
          (searchTitle != null && searchTitle.isNotEmpty) || hasReceipt != null || type != null;
      final effectiveLimit = hasLocalFilter ? 1000 : limit;

      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(effectiveLimit);

      if (!hasLocalFilter && lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (dateRangeDays != null) {
        final startDate = DateTime.now().subtract(Duration(days: dateRangeDays));
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      final snapshot = await query.get();

      List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (searchTitle != null && searchTitle.isNotEmpty) {
        transactions = transactions
            .where((t) => t.title.toLowerCase().contains(searchTitle.toLowerCase()))
            .toList();
      }

      if (hasReceipt != null) {
        transactions = transactions
            .where((t) => hasReceipt ? t.receiptUrl != null : t.receiptUrl == null)
            .toList();
      }

      if (type != null) {
        transactions = transactions.where((t) => t.type == type).toList();
      }

      return {
        'transactions': transactions,
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'hasMore': !hasLocalFilter && snapshot.docs.length >= limit,
      };
    } catch (e) {
      throw Exception('Erro ao carregar transações');
    }
  }
}
