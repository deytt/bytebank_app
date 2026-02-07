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

  // Filtros atuais
  String? _currentCategory;
  String? _currentSearchTitle;
  bool? _currentHasReceipt;
  String? _currentUserId;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get currentCategory => _currentCategory;
  String? get currentSearchTitle => _currentSearchTitle;
  bool? get currentHasReceipt => _currentHasReceipt;

  double get totalIncome {
    final transactions = _allTransactions;
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.value);
  }

  double get totalExpense {
    final transactions = _allTransactions;
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.value);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> loadAllTransactions(String userId) async {
    try {
      final result = await _transactionService.getTransactionsPaginated(
        userId,
        limit: 1000, // Carrega muitas para ter totais precisos
      );

      _allTransactions = (result['transactions'] as List<TransactionModel>?) ?? [];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _allTransactions = [];
      notifyListeners();
    }
  }

  Future<void> loadTransactions(
    String userId, {
    String? category,
    String? searchTitle,
    bool? hasReceipt,
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
    notifyListeners();

    try {
      final result = await _transactionService.getTransactionsPaginated(
        userId,
        category: category,
        searchTitle: searchTitle,
        hasReceipt: hasReceipt,
      );

      _transactions = result['transactions'] as List<TransactionModel>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      _hasMore = result['hasMore'] as bool;
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

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _transactionService.getTransactionsPaginated(
        _currentUserId!,
        lastDocument: _lastDocument,
        category: _currentCategory,
        searchTitle: _currentSearchTitle,
        hasReceipt: _currentHasReceipt,
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

  Future<void> refreshTransactions() async {
    if (_currentUserId != null) {
      await loadTransactions(
        _currentUserId!,
        category: _currentCategory,
        searchTitle: _currentSearchTitle,
        hasReceipt: _currentHasReceipt,
        refresh: true,
      );
    }
  }

  void clearFilters() {
    _currentCategory = null;
    _currentSearchTitle = null;
    _currentHasReceipt = null;
    if (_currentUserId != null) {
      loadTransactions(_currentUserId!, refresh: true);
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
      // Recarregar transações após adicionar
      if (_currentUserId != null) {
        await loadAllTransactions(_currentUserId!);
        await refreshTransactions();
      }
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
        // Deletar recibo antigo se existir
        if (receiptUrl != null) {
          await _storageService.deleteReceipt(receiptUrl);
        }

        receiptUrl = await _storageService.uploadReceipt(receiptFile, transaction.userId);
      }

      final transactionWithReceipt = transaction.copyWith(receiptUrl: receiptUrl);

      await _transactionService.updateTransaction(transactionWithReceipt);
      _isLoading = false;
      // Recarregar transações após atualizar
      if (_currentUserId != null) {
        await loadAllTransactions(_currentUserId!);
        await refreshTransactions();
      }
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
      // Recarregar transações após deletar
      if (_currentUserId != null) {
        await loadAllTransactions(_currentUserId!);
        await refreshTransactions();
      }
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
