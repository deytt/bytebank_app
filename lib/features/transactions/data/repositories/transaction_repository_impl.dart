import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/encryption_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collection = 'transactions';
  static const int _maxUploadSizeBytes = 30 * 1024 * 1024;

  String _boxName(String userId) => 'tx_$userId';

  Map<String, dynamic> _toCacheMap(TransactionModel model) {
    final map = model.toMap();
    return {
      ...map,
      'id': model.id,
      'date': model.date.millisecondsSinceEpoch,
    };
  }

  TransactionModel _fromCacheMap(Map map) {
    final raw = Map<String, dynamic>.from(map);
    final dateMs = raw['date'] as int;
    return TransactionModel(
      id: raw['id'] as String?,
      userId: raw['userId'] as String,
      title: EncryptionService().decrypt(raw['title'] as String? ?? ''),
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

  Future<void> _saveToCache(
    String userId,
    List<TransactionModel> models, {
    ({double totalIncome, double totalExpense})? aggregates,
    List<TransactionModel>? chartTransactions,
  }) async {
    try {
      final box = await _openBox(userId);
      await box.put('transactions', models.map(_toCacheMap).toList());
      if (aggregates != null) {
        await box.put('aggregates', {
          'totalIncome': aggregates.totalIncome,
          'totalExpense': aggregates.totalExpense,
          'savedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
      if (chartTransactions != null) {
        await box.put('chart_transactions', chartTransactions.map(_toCacheMap).toList());
      }
    } catch (_) {}
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

  Future<({double totalIncome, double totalExpense})?> _readAggregatesFromCache(
    String userId,
  ) async {
    try {
      final box = await _openBox(userId);
      final cached = box.get('aggregates') as Map?;
      if (cached == null) return null;
      return (
        totalIncome: (cached['totalIncome'] as num).toDouble(),
        totalExpense: (cached['totalExpense'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TransactionModel>> _readChartFromCache(String userId) async {
    try {
      final box = await _openBox(userId);
      final cached = box.get('chart_transactions');
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
      await box.delete('aggregates');
      await box.delete('chart_transactions');
    } catch (_) {}
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
          (searchTitle != null && searchTitle.isNotEmpty) || hasReceipt != null || type != null;
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

      final snapshot = await query.get().timeout(const Duration(seconds: 5));

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

      final isFirstPage = pageToken == null && !hasLocalFilter;
      if (isFirstPage) {
        if (limit > 20) {
          await _saveToCache(userId, [], chartTransactions: transactions);
        } else {
          await _saveToCache(userId, transactions);
        }
      }

      return TransactionPage(
        transactions: transactions,
        hasMore: !hasLocalFilter && snapshot.docs.length >= limit,
        cursor: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      if (pageToken == null) {
        final cached = await _readFromCache(userId);
        if (cached.isNotEmpty) {
          return TransactionPage(transactions: cached, hasMore: false, cursor: null);
        }
        if (limit > 20) {
          final chartCached = await _readChartFromCache(userId);
          if (chartCached.isNotEmpty) {
            return TransactionPage(transactions: chartCached, hasMore: false, cursor: null);
          }
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
      await _firestore
          .collection(_collection)
          .add(model.toMap())
          .timeout(const Duration(seconds: 5));
      await _clearCache(model.userId);
    } catch (e) {
      debugPrint('add error: $e');
      throw Exception('Sem conexão. Verifique sua internet e tente novamente.');
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
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(model.toMap())
          .timeout(const Duration(seconds: 5));
      await _clearCache(model.userId);
    } catch (e) {
      debugPrint('update error: $e');
      throw Exception('Sem conexão. Verifique sua internet e tente novamente.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 5));
      final data = doc.data();
      final userId = data?['userId'];
      await _firestore.collection(_collection).doc(id).delete().timeout(const Duration(seconds: 5));
      if (userId != null) await _clearCache(userId);
    } catch (e) {
      debugPrint('delete error: $e');
      throw Exception('Sem conexão. Verifique sua internet e tente novamente.');
    }
  }

  @override
  Future<({double totalIncome, double totalExpense})> getAggregates(String userId) async {
    try {
      final base = _firestore.collection(_collection).where('userId', isEqualTo: userId);

      final incomeResult = await base
          .where('type', isEqualTo: 'income')
          .aggregate(sum('value'))
          .get()
          .timeout(const Duration(seconds: 5));

      final expenseResult = await base
          .where('type', isEqualTo: 'expense')
          .aggregate(sum('value'))
          .get()
          .timeout(const Duration(seconds: 5));

      final result = (
        totalIncome: (incomeResult.getSum('value') ?? 0).toDouble(),
        totalExpense: (expenseResult.getSum('value') ?? 0).toDouble(),
      );
      await _saveToCache(userId, [], aggregates: result);
      return result;
    } catch (e, st) {
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('FAILED_PRECONDITION')) {
        debugPrint('getAggregates: index not ready, using fallback');
        final fallback = await _computeAggregatesFallback(userId);
        await _saveToCache(userId, [], aggregates: fallback);
        return fallback;
      }
      debugPrint('getAggregates error: $e\n$st');
      final cached = await _readAggregatesFromCache(userId);
      if (cached != null) return cached;
      throw Exception('Erro ao calcular totais');
    }
  }

  Future<({double totalIncome, double totalExpense})> _computeAggregatesFallback(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      double totalIncome = 0;
      double totalExpense = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final value = (data['value'] as num?)?.toDouble() ?? 0;
        final type = data['type'] as String?;
        if (type == 'income') {
          totalIncome += value;
        } else if (type == 'expense') {
          totalExpense += value;
        }
      }
      return (totalIncome: totalIncome, totalExpense: totalExpense);
    } catch (e) {
      debugPrint('getAggregates fallback error: $e');
      throw Exception('Erro ao calcular totais');
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
      final uploadTask = await ref
          .putData(bytes, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(const Duration(seconds: 10));
      return await uploadTask.ref.getDownloadURL().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('uploadReceipt error: $e');
      throw Exception('Sem conexão. Verifique sua internet e tente novamente.');
    }
  }

  @override
  Future<void> deleteReceipt(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('deleteReceipt error: $e');
      throw Exception('Sem conexão. Verifique sua internet e tente novamente.');
    }
  }
}
