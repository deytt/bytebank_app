import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';

class DashboardBalanceCard extends StatefulWidget {
  final TransactionLoaded? loaded;

  const DashboardBalanceCard({super.key, required this.loaded});

  @override
  State<DashboardBalanceCard> createState() => _DashboardBalanceCardState();
}

class _DashboardBalanceCardState extends State<DashboardBalanceCard> {
  bool _obscured = false;

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final balance = widget.loaded?.balance ?? 0.0;
    final income = widget.loaded?.totalIncome ?? 0.0;
    final expense = widget.loaded?.totalExpense ?? 0.0;
    final isPositive = balance >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.balanceSurface.withValues(alpha: 0.55), t.surface],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.gradientBlue.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Saldo atual',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      key: ValueKey(_obscured),
                      color: t.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _obscured
                ? Text(
                    '••••••',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: t.textSecondary,
                      letterSpacing: 4,
                    ),
                  )
                : AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? t.success : t.error,
                    ),
                    child: Text(Formatters.formatCurrency(balance)),
                  ),
            const Divider(height: 28, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BalanceItem(
                  label: 'Receitas',
                  value: income,
                  color: t.success,
                  icon: Icons.arrow_upward_rounded,
                  obscured: _obscured,
                ),
                _BalanceItem(
                  label: 'Despesas',
                  value: expense,
                  color: t.error,
                  icon: Icons.arrow_downward_rounded,
                  obscured: _obscured,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final bool obscured;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.obscured,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
            Text(
              obscured ? '•••••' : Formatters.formatCurrency(value),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
