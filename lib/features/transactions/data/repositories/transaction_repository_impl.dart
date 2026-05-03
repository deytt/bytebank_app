import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collection = 'transactions';
  static const int _maxUploadSizeBytes = 30 * 1024 * 1024;

  @override
  Future<TransactionPage> getTransactionsPaginated(
    String userId, {
    Object? pageToken,
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int? dateRangeDays,
    TransactionType? type,
    int limit = 20,
  }) async {
    try {
      final hasLocalFilter =
          (searchTitle != null && searchTitle.isNotEmpty) ||
          hasReceipt != null ||
          type != null;
      final effectiveLimit = hasLocalFilter ? 1000 : limit;

      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(effectiveLimit);

      if (!hasLocalFilter && pageToken != null) {
        query = query.startAfterDocument(pageToken as DocumentSnapshot);
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

      return TransactionPage(
        transactions: transactions,
        hasMore: !hasLocalFilter && snapshot.docs.length >= limit,
        cursor: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      throw Exception('Erro ao carregar transações');
    }
  }

  @override
  Future<void> add(Transaction transaction) async {
    try {
      final model = transaction is TransactionModel
          ? transaction
          : TransactionModel(
              id: transaction.id,
              userId: transaction.userId,
              title: transaction.title,
              value: transaction.value,
              category: transaction.category,
              type: transaction.type,
              date: transaction.date,
              receiptUrl: transaction.receiptUrl,
            );
      await _firestore.collection(_collection).add(model.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar transação');
    }
  }

  @override
  Future<void> update(Transaction transaction) async {
    try {
      if (transaction.id == null) throw Exception('ID da transação não pode ser nulo');
      final model = transaction is TransactionModel
          ? transaction
          : TransactionModel(
              id: transaction.id,
              userId: transaction.userId,
              title: transaction.title,
              value: transaction.value,
              category: transaction.category,
              type: transaction.type,
              date: transaction.date,
              receiptUrl: transaction.receiptUrl,
            );
      await _firestore.collection(_collection).doc(transaction.id).update(model.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar transação');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar transação');
    }
  }

  @override
  Future<String> uploadReceipt(XFile file, String userId) async {
    try {
      final fileSize = await file.length();
      if (fileSize > _maxUploadSizeBytes) {
        throw Exception('Arquivo muito grande. Limite: 30 MB');
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('receipts/$userId/$fileName');
      final bytes = await file.readAsBytes();
      final uploadTask = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload');
    }
  }

  @override
  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Erro ao deletar arquivo');
    }
  }
}
