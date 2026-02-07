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
      await _firestore.collection(_collection).doc(transaction.id).update(transaction.toMap());
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

  Future<Map<String, dynamic>> getTransactionsPaginated(
    String userId, {
    DocumentSnapshot? lastDocument,
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int limit = 20,
  }) async {
    try {
      // Aumenta limit quando há filtro local (título ou recibo)
      int effectiveLimit = limit;
      if (searchTitle != null && searchTitle.isNotEmpty) {
        effectiveLimit = limit * 5;
      } else if (hasReceipt != null) {
        effectiveLimit = limit * 2;
      }

      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(effectiveLimit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      List<TransactionModel> transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filtros aplicados localmente (apenas para campos que não podem ser indexados)
      if (searchTitle != null && searchTitle.isNotEmpty) {
        transactions = transactions.where((t) {
          return t.title.toLowerCase().contains(searchTitle.toLowerCase());
        }).toList();
      }

      if (hasReceipt != null) {
        transactions = transactions.where((t) {
          return hasReceipt ? t.receiptUrl != null : t.receiptUrl == null;
        }).toList();
      }

      return {
        'transactions': transactions.take(limit).toList(),
        'lastDocument': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'hasMore': snapshot.docs.length >= effectiveLimit,
      };
    } catch (e) {
      throw Exception('Erro ao carregar transações: ${e.toString()}');
    }
  }
}
