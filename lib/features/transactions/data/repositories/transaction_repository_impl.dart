import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collection = 'transactions';
  static const int _maxUploadSizeBytes = 30 * 1024 * 1024;

  /// Returns the Hive box name for a given user's transaction cache.
  String _boxName(String userId) => 'tx_$userId';

  /// Converts a TransactionModel to a cache-safe map (no Firestore types).
  Map<String, dynamic> _toCacheMap(TransactionModel model) {
    final map = model.toMap();
    return {
      ...map,
      'id': model.id,
      // Replace Timestamp with int so Hive can persist it
      'date': model.date.millisecondsSinceEpoch,
    };
  }

  /// Builds a TransactionModel from a cache map.
  TransactionModel _fromCacheMap(Map map) {
    final raw = Map<String, dynamic>.from(map);
    // Restore the date from millisecondsSinceEpoch
    final dateMs = raw['date'] as int;
    return TransactionModel(
      id: raw['id'] as String?,
      userId: raw['userId'] as String,
      // title is stored encrypted; fromMap handles decryption via EncryptionService
      title: raw['title'] as String,
      value: (raw['value'] as num).toDouble(),
      category: raw['category'] as String,
      type: raw['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      receiptUrl: raw['receiptUrl'] as String?,
    );
  }

  Future<Box> _openBox(String userId) async {
    final name = _boxName(userId);
    if (Hive.isBoxOpen(name)) return Hive.box(name);
    return Hive.openBox(name);
  }

  Future<void> _saveToCache(String userId, List<TransactionModel> models) async {
    try {
      final box = await _openBox(userId);
      final maps = models.map(_toCacheMap).toList();
      await box.put('transactions', maps);
    } catch (_) {
      // Cache write failure must never break the main flow
    }
  }

  Future<List<TransactionModel>> _readFromCache(String userId) async {
    try {
      final box = await _openBox(userId);
      final cached = box.get('transactions');
      if (cached == null) return [];
      return (cached as List).map((e) => _fromCacheMap(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _clearCache(String userId) async {
    try {
      final box = await _openBox(userId);
      await box.delete('transactions');
    } catch (_) {
      // Ignore cache errors
    }
  }

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

      // Persist first unfiltered page to cache for offline access
      final isFirstPage = pageToken == null && !hasLocalFilter;
      if (isFirstPage) {
        await _saveToCache(userId, transactions);
      }

      return TransactionPage(
        transactions: transactions,
        hasMore: !hasLocalFilter && snapshot.docs.length >= limit,
        cursor: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      // Firestore unreachable — serve cached data if available
      if (pageToken == null) {
        final cached = await _readFromCache(userId);
        if (cached.isNotEmpty) {
          return TransactionPage(transactions: cached, hasMore: false, cursor: null);
        }
      }
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
      await _clearCache(model.userId);
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
      await _clearCache(model.userId);
    } catch (e) {
      throw Exception('Erro ao atualizar transação');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      final data = doc.data();
      final userId = data?['userId'];
      await _firestore.collection(_collection).doc(id).delete();
      if (userId != null) await _clearCache(userId);
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
