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
  final List<TransactionModel> transactions;

  /// Recent transactions used for chart rendering (capped at 200).
  final List<TransactionModel> allTransactions;

  /// Totals from Firestore aggregation queries — not computed from allTransactions.
  final double totalIncome;
  final double totalExpense;

  final bool hasMore;
  final bool isLoadingMore;
  final bool isSubmitting;

  const TransactionLoaded({
    required this.transactions,
    required this.allTransactions,
    required this.totalIncome,
    required this.totalExpense,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
  });

  double get balance => totalIncome - totalExpense;

  TransactionLoaded copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? allTransactions,
    double? totalIncome,
    double? totalExpense,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSubmitting,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      allTransactions: allTransactions ?? this.allTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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

  const TransactionActionFailure({required this.message, this.data});

  @override
  List<Object?> get props => [message];
}
