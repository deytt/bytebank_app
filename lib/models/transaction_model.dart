import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String? id;
  final String userId;
  final String title;
  final double value;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? receiptUrl;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.value,
    required this.category,
    required this.type,
    required this.date,
    this.receiptUrl,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      value: (map['value'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: (map['date'] as Timestamp).toDate(),
      receiptUrl: map['receiptUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'value': value,
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'date': Timestamp.fromDate(date),
      'receiptUrl': receiptUrl,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? value,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? receiptUrl,
  }) {
    return TransactionModel(
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
