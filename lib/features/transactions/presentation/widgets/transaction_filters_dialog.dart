import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart' show TransactionType;

class TransactionFilters {
  final String? category;
  final bool? hasReceipt;
  final int? dateRange;
  final TransactionType? type;

  const TransactionFilters({
    this.category,
    this.hasReceipt,
    this.dateRange,
    this.type,
  });
}

Future<TransactionFilters?> showTransactionFiltersDialog(
  BuildContext context, {
  required TransactionFilters current,
  required List<String> categories,
}) {
  String? tempCategory = current.category;
  bool? tempHasReceipt = current.hasReceipt;
  int? tempDateRange = current.dateRange;
  TransactionType? tempType = current.type;

  return showDialog<TransactionFilters>(
    context: context,
    builder: (context) {
      final td = AppTheme.of(context);
      return AlertDialog(
        backgroundColor: td.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Filtros'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categoria', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChoiceChip(
                      label: 'Todas',
                      selected: tempCategory == null,
                      onSelected: (_) => setDialogState(() => tempCategory = null),
                    ),
                    ...categories.map(
                      (category) => _FilterChoiceChip(
                        label: category,
                        selected: tempCategory == category,
                        onSelected: (selected) =>
                            setDialogState(() => tempCategory = selected ? category : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Recibo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChoiceChip(
                      label: 'Todos',
                      selected: tempHasReceipt == null,
                      onSelected: (_) => setDialogState(() => tempHasReceipt = null),
                    ),
                    _FilterChoiceChip(
                      label: 'Com recibo',
                      selected: tempHasReceipt == true,
                      onSelected: (s) => setDialogState(() => tempHasReceipt = s ? true : null),
                    ),
                    _FilterChoiceChip(
                      label: 'Sem recibo',
                      selected: tempHasReceipt == false,
                      onSelected: (s) => setDialogState(() => tempHasReceipt = s ? false : null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Período', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChoiceChip(
                      label: 'Todos',
                      selected: tempDateRange == null,
                      onSelected: (_) => setDialogState(() => tempDateRange = null),
                    ),
                    _FilterChoiceChip(
                      label: 'Últimos 15 dias',
                      selected: tempDateRange == 15,
                      onSelected: (s) => setDialogState(() => tempDateRange = s ? 15 : null),
                    ),
                    _FilterChoiceChip(
                      label: 'Últimos 30 dias',
                      selected: tempDateRange == 30,
                      onSelected: (s) => setDialogState(() => tempDateRange = s ? 30 : null),
                    ),
                    _FilterChoiceChip(
                      label: 'Últimos 90 dias',
                      selected: tempDateRange == 90,
                      onSelected: (s) => setDialogState(() => tempDateRange = s ? 90 : null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Tipo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChoiceChip(
                      label: 'Todos',
                      selected: tempType == null,
                      onSelected: (_) => setDialogState(() => tempType = null),
                    ),
                    _FilterChoiceChip(
                      label: 'Receita',
                      selected: tempType == TransactionType.income,
                      onSelected: (s) =>
                          setDialogState(() => tempType = s ? TransactionType.income : null),
                    ),
                    _FilterChoiceChip(
                      label: 'Despesa',
                      selected: tempType == TransactionType.expense,
                      onSelected: (s) =>
                          setDialogState(() => tempType = s ? TransactionType.expense : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                TransactionFilters(
                  category: tempCategory,
                  hasReceipt: tempHasReceipt,
                  dateRange: tempDateRange,
                  type: tempType,
                ),
              );
            },
            child: const Text('Aplicar'),
          ),
        ],
      );
    },
  );
}

class TransactionFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const TransactionFilterChip({super.key, required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: t.white, fontWeight: FontWeight.w600),
        ),
        deleteIcon: Icon(Icons.close_rounded, size: 16, color: t.white),
        onDeleted: onDeleted,
        backgroundColor: t.primary,
        side: BorderSide(color: t.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.only(left: 8, right: 4),
      ),
    );
  }
}

class _FilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? t.white : t.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: t.primary,
      backgroundColor: t.transactionCardFill,
      side: BorderSide(color: selected ? t.primary : t.neutralBorder),
      onSelected: onSelected,
    );
  }
}
