part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String userId;
  final String? category;
  final String? searchTitle;
  final bool? hasReceipt;
  final int? dateRangeDays;
  final TransactionType? type;
  final bool refresh;

  const LoadTransactions({
    required this.userId,
    this.category,
    this.searchTitle,
    this.hasReceipt,
    this.dateRangeDays,
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [userId, category, searchTitle, hasReceipt, dateRangeDays, type, refresh];
}

class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

class AddTransactionRequested extends TransactionEvent {
  final TransactionModel transaction;
  final XFile? receiptFile;

  const AddTransactionRequested({required this.transaction, this.receiptFile});

  @override
  List<Object?> get props => [transaction.id];
}

class UpdateTransactionRequested extends TransactionEvent {
  final TransactionModel transaction;
  final XFile? receiptFile;

  const UpdateTransactionRequested({required this.transaction, this.receiptFile});

  @override
  List<Object?> get props => [transaction.id];
}

class DeleteTransactionRequested extends TransactionEvent {
  final TransactionModel transaction;

  const DeleteTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction.id];
}

class ClearTransactionFilters extends TransactionEvent {
  const ClearTransactionFilters();
}
