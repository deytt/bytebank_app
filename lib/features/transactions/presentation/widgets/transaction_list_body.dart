import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../pages/transaction_form_screen.dart';
import 'transaction_card.dart';

class TransactionListBody extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController scrollController;

  const TransactionListBody({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);

    if (isLoading && transactions.isEmpty) {
      return Center(child: CircularProgressIndicator(color: t.primaryLight));
    }

    if (transactions.isEmpty) {
      return _TransactionListEmpty();
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: transactions.length + 1,
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!hasMore) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Todas as transações foram carregadas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final transaction = transactions[index];
        return TransactionCard(
          transaction: transaction,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TransactionFormScreen(transaction: transaction),
              ),
            );
          },
          onDelete: () => confirmDeleteTransaction(context, transaction),
        );
      },
    );
  }
}

class _TransactionListEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 56,
            color: t.textSecondary.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

Future<void> confirmDeleteTransaction(BuildContext context, TransactionModel transaction) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final td = AppTheme.of(ctx);
      return AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: td.error),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  if (confirm == true && context.mounted) {
    context.read<TransactionBloc>().add(DeleteTransactionRequested(transaction));
  }
}
