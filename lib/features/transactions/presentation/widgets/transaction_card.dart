import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/entities/transaction.dart' show TransactionType;

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({super.key, required this.transaction, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? t.success : t.error;
    final icon = isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final dateStr = DateFormat('dd/MM/yyyy').format(transaction.date);
    final dateStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          height: 1.2,
          color: t.textSecondary.withValues(alpha: 0.95),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: DecoratedBox(
        decoration: t.transactionListItemDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            transaction.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.category,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${isIncome ? '+' : '-'} ${Formatters.formatCurrency(transaction.value)}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        dateStr,
                                        style: dateStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (transaction.receiptUrl != null) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        color: t.textSecondary.withValues(alpha: 0.85),
                                        size: 13,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (onDelete != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: t.error.withValues(alpha: 0.9),
                                  ),
                                  iconSize: 21,
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: onDelete,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
