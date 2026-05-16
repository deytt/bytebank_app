part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  final List<Transaction> allTransactions;

  final double totalIncome;
  final double totalExpense;

  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  final bool isFromCache;

  const TransactionLoaded({
    required this.transactions,
    required this.allTransactions,
    required this.totalIncome,
    required this.totalExpense,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.isFromCache = false,
  });

  double get balance => totalIncome - totalExpense;

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? allTransactions,
    double? totalIncome,
    double? totalExpense,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool? isFromCache,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        allTransactions,
        totalIncome,
        totalExpense,
        hasMore,
        isLoadingMore,
        isSubmitting,
        isFromCache,
      ];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionActionSuccess extends TransactionState {
  final String message;
  final TransactionLoaded data;

  const TransactionActionSuccess({required this.message, required this.data});

  @override
  List<Object?> get props => [message, data];
}

class TransactionActionFailure extends TransactionState {
  final String message;
  final TransactionLoaded? data;
  final DateTime timestamp;

  TransactionActionFailure({required this.message, this.data})
      : timestamp = DateTime.now();

  @override
  List<Object?> get props => [message, timestamp];
}
