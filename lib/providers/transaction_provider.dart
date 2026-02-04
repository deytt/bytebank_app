import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final StorageService _storageService = StorageService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.value);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.value);
  }

  double get balance => totalIncome - totalExpense;

  void loadTransactions(String userId) {
    _transactionService.getTransactions(userId).listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    });
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
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<TransactionModel> filterByCategory(String? category) {
    if (category == null || category.isEmpty) {
      return _transactions;
    }
    return _transactions.where((t) => t.category == category).toList();
  }

  List<TransactionModel> filterByPeriod(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return _transactions;
    }
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
