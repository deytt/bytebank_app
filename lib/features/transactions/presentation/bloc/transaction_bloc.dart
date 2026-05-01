import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/transaction_model.dart';
import '../../../../services/transaction_service.dart';
import '../../../../services/storage_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;
  final StorageService _storageService;

  String? _currentUserId;
  String? _currentCategory;
  String? _currentSearchTitle;
  bool? _currentHasReceipt;
  int? _currentDateRangeDays;
  TransactionType? _currentType;
  DocumentSnapshot? _lastDocument;

  TransactionBloc({
    TransactionService? transactionService,
    StorageService? storageService,
  })  : _transactionService = transactionService ?? TransactionService(),
        _storageService = storageService ?? StorageService(),
        super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
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
      _lastDocument = null;
    }

    emit(const TransactionLoading());

    _currentUserId = event.userId;
    _currentCategory = event.category;
    _currentSearchTitle = event.searchTitle;
    _currentHasReceipt = event.hasReceipt;
    _currentDateRangeDays = event.dateRangeDays;
    _currentType = event.type;

    try {
      final result = await _transactionService.getTransactionsPaginated(
        event.userId,
        category: event.category,
        searchTitle: event.searchTitle,
        hasReceipt: event.hasReceipt,
        dateRangeDays: event.dateRangeDays,
        type: event.type,
      );

      final transactions = result['transactions'] as List<TransactionModel>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      final hasMore = result['hasMore'] as bool;

      final allResult = await _transactionService.getTransactionsPaginated(
        event.userId,
        limit: 1000,
      );
      final allTransactions = allResult['transactions'] as List<TransactionModel>;

      emit(TransactionLoaded(
        transactions: transactions,
        allTransactions: allTransactions,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
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
      final result = await _transactionService.getTransactionsPaginated(
        _currentUserId!,
        lastDocument: _lastDocument,
        category: _currentCategory,
      );

      final newTransactions = result['transactions'] as List<TransactionModel>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      final hasMore = result['hasMore'] as bool;

      emit(current.copyWith(
        transactions: [...current.transactions, ...newTransactions],
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
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
      String? receiptUrl;
      if (event.receiptFile != null) {
        receiptUrl = await _storageService.uploadReceipt(
          event.receiptFile!,
          event.transaction.userId,
        );
      }

      final transactionWithReceipt = event.transaction.copyWith(receiptUrl: receiptUrl);
      await _transactionService.addTransaction(transactionWithReceipt);

      await _reloadAll(emit, 'Transação adicionada com sucesso');
    } catch (e) {
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
      String? receiptUrl = event.transaction.receiptUrl;

      if (event.receiptFile != null) {
        if (receiptUrl != null) {
          await _storageService.deleteReceipt(receiptUrl);
        }
        receiptUrl = await _storageService.uploadReceipt(
          event.receiptFile!,
          event.transaction.userId,
        );
      }

      final updated = event.transaction.copyWith(receiptUrl: receiptUrl);
      await _transactionService.updateTransaction(updated);

      await _reloadAll(emit, 'Transação atualizada com sucesso');
    } catch (e) {
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
      if (event.transaction.receiptUrl != null) {
        await _storageService.deleteReceipt(event.transaction.receiptUrl!);
      }
      await _transactionService.deleteTransaction(event.transaction.id!);

      await _reloadAll(emit, 'Transação excluída com sucesso');
    } catch (e) {
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
    _lastDocument = null;

    if (_currentUserId != null) {
      add(LoadTransactions(userId: _currentUserId!, refresh: true));
    }
  }

  Future<void> _reloadAll(Emitter<TransactionState> emit, String successMessage) async {
    if (_currentUserId == null) return;

    try {
      final result = await _transactionService.getTransactionsPaginated(
        _currentUserId!,
        category: _currentCategory,
        searchTitle: _currentSearchTitle,
        hasReceipt: _currentHasReceipt,
        dateRangeDays: _currentDateRangeDays,
        type: _currentType,
      );

      final transactions = result['transactions'] as List<TransactionModel>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      final hasMore = result['hasMore'] as bool;

      final allResult = await _transactionService.getTransactionsPaginated(
        _currentUserId!,
        limit: 1000,
      );
      final allTransactions = allResult['transactions'] as List<TransactionModel>;

      final loaded = TransactionLoaded(
        transactions: transactions,
        allTransactions: allTransactions,
        hasMore: hasMore,
      );

      emit(TransactionActionSuccess(message: successMessage, data: loaded));
    } catch (e) {
      emit(TransactionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
