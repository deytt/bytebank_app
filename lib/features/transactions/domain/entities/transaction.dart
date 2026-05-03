enum TransactionType { income, expense }

class Transaction {
  final String? id;
  final String userId;
  final String title;
  final double value;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? receiptUrl;

  const Transaction({
    this.id,
    required this.userId,
    required this.title,
    required this.value,
    required this.category,
    required this.type,
    required this.date,
    this.receiptUrl,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? title,
    double? value,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? receiptUrl,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
