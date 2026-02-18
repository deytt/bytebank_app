import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final StorageService _storageService = StorageService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  DocumentSnapshot? _lastDocument;
  String? _currentUserId;
  String? _currentCategory;
  String? _currentSearchTitle;
  bool? _currentHasReceipt;
  int? _currentDateRangeDays;
  TransactionType? _currentType;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  double get totalIncome {
    return _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (total, t) => total + t.value);
  }

  double get totalExpense {
    return _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (total, t) => total + t.value);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions(
    String userId, {
    String? category,
    String? searchTitle,
    bool? hasReceipt,
    int? dateRangeDays,
    TransactionType? type,
    bool refresh = false,
  }) async {
    if (refresh) {
      _transactions = [];
      _lastDocument = null;
      _hasMore = true;
    }

    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    _errorMessage = null;
    _currentUserId = userId;
    _currentCategory = category;
    _currentSearchTitle = searchTitle;
    _currentHasReceipt = hasReceipt;
    _currentDateRangeDays = dateRangeDays;
    _currentType = type;
    notifyListeners();

    try {
      final result = await _transactionService.getTransactionsPaginated(
        userId,
        category: category,
        searchTitle: searchTitle,
        hasReceipt: hasReceipt,
        dateRangeDays: dateRangeDays,
        type: type,
      );

      _transactions = result['transactions'] as List<TransactionModel>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      _hasMore = result['hasMore'] as bool;

      await _loadAllTransactions(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore || _currentUserId == null) return;

    final hasLocalFilter =
        (_currentSearchTitle != null && _currentSearchTitle!.isNotEmpty) ||
        _currentHasReceipt != null;

    if (hasLocalFilter) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _transactionService.getTransactionsPaginated(
        _currentUserId!,
        lastDocument: _lastDocument,
        category: _currentCategory,
      );

      final newTransactions = result['transactions'] as List<TransactionModel>;
      _transactions.addAll(newTransactions);
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      _hasMore = result['hasMore'] as bool;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _currentCategory = null;
    _currentSearchTitle = null;
    _currentHasReceipt = null;
    _currentDateRangeDays = null;
    _currentType = null;
    if (_currentUserId != null) {
      loadTransactions(_currentUserId!, refresh: true);
    }
  }

  Future<void> _loadAllTransactions(String userId) async {
    try {
      final result = await _transactionService.getTransactionsPaginated(userId, limit: 1000);
      _allTransactions = result['transactions'] as List<TransactionModel>;
    } catch (e) {
      _allTransactions = [];
    }
  }

  Future<void> _reloadTransactions() async {
    if (_currentUserId != null) {
      await _loadAllTransactions(_currentUserId!);
      await loadTransactions(
        _currentUserId!,
        category: _currentCategory,
        searchTitle: _currentSearchTitle,
        hasReceipt: _currentHasReceipt,
        dateRangeDays: _currentDateRangeDays,
        type: _currentType,
        refresh: true,
      );
    }
  }

  Future<bool> addTransaction(TransactionModel transaction, {XFile? receiptFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? receiptUrl;
      if (receiptFile != null) {
        receiptUrl = await _storageService.uploadReceipt(receiptFile, transaction.userId);
      }

      final transactionWithReceipt = transaction.copyWith(receiptUrl: receiptUrl);
      await _transactionService.addTransaction(transactionWithReceipt);

      _isLoading = false;
      await _reloadTransactions();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction, {XFile? receiptFile}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? receiptUrl = transaction.receiptUrl;

      if (receiptFile != null) {
        if (receiptUrl != null) {
          await _storageService.deleteReceipt(receiptUrl);
        }
        receiptUrl = await _storageService.uploadReceipt(receiptFile, transaction.userId);
      }

      final transactionWithReceipt = transaction.copyWith(receiptUrl: receiptUrl);
      await _transactionService.updateTransaction(transactionWithReceipt);

      _isLoading = false;
      await _reloadTransactions();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (transaction.receiptUrl != null) {
        await _storageService.deleteReceipt(transaction.receiptUrl!);
      }

      await _transactionService.deleteTransaction(transaction.id!);

      _isLoading = false;
      await _reloadTransactions();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
