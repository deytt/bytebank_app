import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../../../core/utils/encryption_service.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.userId,
    required super.title,
    required super.value,
    required super.category,
    required super.type,
    required super.date,
    super.receiptUrl,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      title: EncryptionService().decrypt(map['title'] ?? ''),
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
      'title': EncryptionService().encrypt(title),
      'value': value,
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'date': Timestamp.fromDate(date),
      'receiptUrl': receiptUrl,
    };
  }

  @override
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
