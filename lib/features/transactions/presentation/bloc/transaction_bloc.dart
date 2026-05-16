import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/get_transaction_aggregates_usecase.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactions;
  final GetTransactionAggregatesUseCase _getAggregates;
  final AddTransactionUseCase _addTransaction;
  final UpdateTransactionUseCase _updateTransaction;
  final DeleteTransactionUseCase _deleteTransaction;

  String? _currentUserId;
  String? _currentCategory;
  String? _currentSearchTitle;
  bool? _currentHasReceipt;
  int? _currentDateRangeDays;
  TransactionType? _currentType;
  Object? _lastCursor;

  TransactionBloc({
    required GetTransactionsUseCase getTransactions,
    required GetTransactionAggregatesUseCase getAggregates,
    required AddTransactionUseCase addTransaction,
    required UpdateTransactionUseCase updateTransaction,
    required DeleteTransactionUseCase deleteTransaction,
  })  : _getTransactions = getTransactions,
        _getAggregates = getAggregates,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions, transformer: restartable());
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<AddTransactionRequested>(_onAddTransaction);
    on<UpdateTransactionRequested>(_onUpdateTransaction);
    on<DeleteTransactionRequested>(_onDeleteTransaction);
    on<ClearTransactionFilters>(_onClearFilters);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (event.refresh) {
      _lastCursor = null;
    }

    emit(const TransactionLoading());

    _currentUserId = event.userId;
    _currentCategory = event.category;
    _currentSearchTitle = event.searchTitle;
    _currentHasReceipt = event.hasReceipt;
    _currentDateRangeDays = event.dateRangeDays;
    _currentType = event.type;

    TransactionPage? page;
    ({double totalIncome, double totalExpense})? aggregates;
    TransactionPage? chartPage;

    try {
      page = await _getTransactions(
        event.userId,
        category: event.category,
        searchTitle: event.searchTitle,
        hasReceipt: event.hasReceipt,
        dateRangeDays: event.dateRangeDays,
        type: event.type,
      );
    } catch (_) {}

    try {
      aggregates = await _getAggregates(event.userId);
    } catch (_) {}

    try {
      chartPage = await _getTransactions(event.userId, limit: 200);
    } catch (_) {}

    if (emit.isDone) return;

    if (page == null && aggregates == null) {
      emit(const TransactionError('Sem conexão e sem dados em cache'));
      return;
    }

    final isFromCache = page == null || aggregates == null || chartPage == null;

    _lastCursor = page?.cursor;

    emit(TransactionLoaded(
      transactions: page?.transactions ?? [],
      allTransactions: chartPage?.transactions ?? [],
      totalIncome: aggregates?.totalIncome ?? 0,
      totalExpense: aggregates?.totalExpense ?? 0,
      hasMore: page?.hasMore ?? false,
      isFromCache: isFromCache,
    ));
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransactionLoaded) return;
    if (current.isLoadingMore || !current.hasMore || _currentUserId == null) return;

    final hasLocalFilter =
        (_currentSearchTitle != null && _currentSearchTitle!.isNotEmpty) ||
        _currentHasReceipt != null;
    if (hasLocalFilter) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final page = await _getTransactions(
        _currentUserId!,
        pageToken: _lastCursor,
        category: _currentCategory,
        dateRangeDays: _currentDateRangeDays,
        type: _currentType,
      );

      _lastCursor = page.cursor;

      emit(current.copyWith(
        transactions: [
          ...current.transactions,
          ...page.transactions,
        ],
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      debugPrint('LoadMoreTransactions error: $e');
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    final currentLoaded = current is TransactionLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    try {
      final receiptBytes = await event.receiptFile?.readAsBytes();
      await _addTransaction(event.transaction, receiptBytes: receiptBytes);
      await _reloadAll(emit, 'Transação adicionada com sucesso');
    } catch (e) {
      debugPrint('AddTransaction error: $e');
      if (currentLoaded != null) {
        emit(TransactionActionFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          data: currentLoaded.copyWith(isSubmitting: false),
        ));
      } else {
        emit(TransactionActionFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    final currentLoaded = current is TransactionLoaded ? current : null;

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(isSubmitting: true));
    }

    try {
      final receiptBytes = await event.receiptFile?.readAsBytes();
      await _updateTransaction(event.transaction, receiptBytes: receiptBytes);
      await _reloadAll(emit, 'Transação atualizada com sucesso');
    } catch (e) {
      debugPrint('UpdateTransaction error: $e');
      if (currentLoaded != null) {
        emit(TransactionActionFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          data: currentLoaded.copyWith(isSubmitting: false),
        ));
      } else {
        emit(TransactionActionFailure(
          message: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _deleteTransaction(event.transaction);
      await _reloadAll(emit, 'Transação excluída com sucesso');
    } catch (e) {
      debugPrint('DeleteTransaction error: $e');
      final current = state;
      if (current is TransactionLoaded) {
        emit(TransactionActionFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          data: current,
        ));
      }
    }
  }

  Future<void> _onClearFilters(
    ClearTransactionFilters event,
    Emitter<TransactionState> emit,
  ) async {
    _currentCategory = null;
    _currentSearchTitle = null;
    _currentHasReceipt = null;
    _currentDateRangeDays = null;
    _currentType = null;
    _lastCursor = null;

    if (_currentUserId != null) {
      add(LoadTransactions(userId: _currentUserId!, refresh: true));
    }
  }

  Future<void> _reloadAll(Emitter<TransactionState> emit, String successMessage) async {
    if (_currentUserId == null) return;

    TransactionPage? page;
    ({double totalIncome, double totalExpense})? aggregates;
    TransactionPage? chartPage;

    try {
      page = await _getTransactions(
        _currentUserId!,
        category: _currentCategory,
        searchTitle: _currentSearchTitle,
        hasReceipt: _currentHasReceipt,
        dateRangeDays: _currentDateRangeDays,
        type: _currentType,
      );
    } catch (_) {}

    try {
      aggregates = await _getAggregates(_currentUserId!);
    } catch (_) {}

    try {
      chartPage = await _getTransactions(_currentUserId!, limit: 200);
    } catch (_) {}

    if (emit.isDone) return;

    if (page == null && aggregates == null) {
      emit(const TransactionError('Sem conexão e sem dados em cache'));
      return;
    }

    _lastCursor = page?.cursor;

    final loaded = TransactionLoaded(
      transactions: page?.transactions ?? [],
      allTransactions: chartPage?.transactions ?? [],
      totalIncome: aggregates?.totalIncome ?? 0,
      totalExpense: aggregates?.totalExpense ?? 0,
      hasMore: page?.hasMore ?? false,
    );

    emit(TransactionActionSuccess(message: successMessage, data: loaded));
  }
}
