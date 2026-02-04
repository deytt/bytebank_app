import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection(_collection).add(transaction.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar transação: ${e.toString()}');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.id == null) {
        throw Exception('ID da transação não pode ser nulo');
      }
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar transação: ${e.toString()}');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar transação: ${e.toString()}');
    }
  }

  Stream<List<TransactionModel>> getTransactions(
    String userId, {
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  Future<List<TransactionModel>> getTransactionsPaginated(
    String userId, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar transações: ${e.toString()}');
    }
  }
}
