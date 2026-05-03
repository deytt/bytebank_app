import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/transactions/data/models/transaction_model.dart';
import '../../../features/transactions/domain/entities/transaction.dart';

enum ChartPeriod { total, last12Months, last3Months }

enum ChartType { line, bar, pie }

class DashboardChartCard extends StatefulWidget {
  final List<TransactionModel> transactions;

  const DashboardChartCard({super.key, required this.transactions});

  @override
  State<DashboardChartCard> createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard> {
  ChartPeriod _selectedPeriod = ChartPeriod.last12Months;
  ChartType _selectedChartType = ChartType.line;
  late PageController _pageController;

  static const _pieColors = [
    AppTheme.primaryLight,
    AppTheme.success,
    AppTheme.error,
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    AppTheme.textSecondary,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _chartTitle {
    switch (_selectedChartType) {
      case ChartType.line:
        return 'Saldo Acumulado';
      case ChartType.bar:
        return 'Receitas e Despesas';
      case ChartType.pie:
        return 'Despesas por Categoria';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = widget.transactions;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary.withValues(alpha: 0.30), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _chartTitle,
                key: ValueKey(_chartTitle),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: transactions.isEmpty
                  ? _buildEmptyChart()
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedChartType = const [
                            ChartType.line,
                            ChartType.bar,
                            ChartType.pie,
                          ][index];
                        });
                      },
                      children: [
                        _buildLineChart(transactions),
                        _buildBarChart(transactions),
                        _buildPieChart(transactions),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 44, child: _buildChartLegend(transactions)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active =
                    const [ChartType.line, ChartType.bar, ChartType.pie][i] ==
                    _selectedChartType;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.primaryLight
                          : AppTheme.primaryLight.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PeriodTag(
          label: '3m',
          selected: _selectedPeriod == ChartPeriod.last3Months,
          onTap: () => setState(() => _selectedPeriod = ChartPeriod.last3Months),
        ),
        const SizedBox(width: 6),
        _PeriodTag(
          label: '12m',
          selected: _selectedPeriod == ChartPeriod.last12Months,
          onTap: () => setState(() => _selectedPeriod = ChartPeriod.last12Months),
        ),
        const SizedBox(width: 6),
        _PeriodTag(
          label: 'Total',
          selected: _selectedPeriod == ChartPeriod.total,
          onTap: () => setState(() => _selectedPeriod = ChartPeriod.total),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 8),
            Text('Nenhuma transação ainda', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  List<_MonthData> _getChartData(List<TransactionModel> transactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case ChartPeriod.last3Months:
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case ChartPeriod.last12Months:
        startDate = DateTime(now.year, now.month - 11, 1);
        break;
      case ChartPeriod.total:
        if (transactions.isEmpty) return [];
        final oldest = transactions.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
        startDate = DateTime(oldest.date.year, oldest.date.month, 1);
        break;
    }

    final Map<String, _MonthData> monthMap = {};
    DateTime current = startDate;
    final end = DateTime(now.year, now.month + 1, 0);

    while (current.isBefore(end) || current.month == end.month) {
      final key = '${current.year}-${current.month.toString().padLeft(2, '0')}';
      monthMap[key] = _MonthData(year: current.year, month: current.month, income: 0, expense: 0);
      current = DateTime(current.year, current.month + 1, 1);
    }

    for (final t in transactions) {
      if (t.date.isBefore(startDate)) continue;
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      if (!monthMap.containsKey(key)) continue;
      if (t.type == TransactionType.income) {
        monthMap[key] = monthMap[key]!.copyWith(income: monthMap[key]!.income + t.value);
      } else {
        monthMap[key] = monthMap[key]!.copyWith(expense: monthMap[key]!.expense + t.value);
      }
    }

    final sorted = monthMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    double cumulativeBalance = 0;
    final result = <_MonthData>[];

    for (final entry in sorted) {
      cumulativeBalance += entry.value.income - entry.value.expense;
      result.add(entry.value.copyWith(balance: cumulativeBalance));
    }

    return result;
  }

  List<TransactionModel> _filterByPeriod(List<TransactionModel> transactions) {
    if (_selectedPeriod == ChartPeriod.total) return List.from(transactions);
    final now = DateTime.now();
    final startDate = _selectedPeriod == ChartPeriod.last3Months
        ? DateTime(now.year, now.month - 2, 1)
        : DateTime(now.year, now.month - 11, 1);
    return transactions.where((t) => !t.date.isBefore(startDate)).toList();
  }

  Map<String, double> _getPieChartData(List<TransactionModel> transactions) {
    final expenses = _filterByPeriod(transactions)
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final Map<String, double> categoryTotals = {};
    for (final t in expenses) {
      final cat = t.category.trim().isEmpty ? 'Outros' : t.category;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + t.value;
    }

    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final Map<String, double> result = {};
    double others = 0;

    for (int i = 0; i < sorted.length; i++) {
      if (i < 5) {
        result[sorted[i].key] = sorted[i].value;
      } else {
        others += sorted[i].value;
      }
    }
    if (others > 0) result['Outros'] = (result['Outros'] ?? 0) + others;
    return result;
  }

  Widget _buildLineChart(List<TransactionModel> transactions) {
    final data = _getChartData(transactions);
    if (data.isEmpty) return _buildEmptyChart();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.balance);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.surface.withValues(alpha: 0.5), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Text(
                _formatChartValue(value),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: data.length > 6 ? (data.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final d = data[idx];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _monthLabel(d.month),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppTheme.primaryLight,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: spots.length <= 6,
              getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryLight,
                strokeWidth: 2,
                strokeColor: AppTheme.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryLight.withValues(alpha: 0.3),
                  AppTheme.primaryLight.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= data.length) return null;
                final d = data[idx];
                return LineTooltipItem(
                  '${_monthLabel(d.month)}/${d.year}\n${Formatters.formatCurrency(spot.y)}',
                  const TextStyle(
                    color: AppTheme.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildBarChart(List<TransactionModel> transactions) {
    final data = _getChartData(transactions);
    if (data.isEmpty) return _buildEmptyChart();

    final maxY = data
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppTheme.surface.withValues(alpha: 0.5), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Text(
                _formatChartValue(value),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final d = data[idx];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _monthLabel(d.month),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final idx = entry.key;
          final d = entry.value;
          return BarChartGroupData(
            x: idx,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: d.income,
                color: AppTheme.success.withValues(alpha: 0.85),
                width: 10,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: d.expense,
                color: AppTheme.error.withValues(alpha: 0.85),
                width: 10,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final d = data[group.x];
              final label = rodIndex == 0 ? 'Receita' : 'Despesa';
              return BarTooltipItem(
                '${_monthLabel(d.month)}/${d.year}\n$label: ${Formatters.formatCurrency(rod.toY)}',
                const TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildPieChart(List<TransactionModel> transactions) {
    final data = _getPieChartData(transactions);
    if (data.isEmpty) return _buildEmptyChart();

    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final entries = data.entries.toList();

    return StatefulBuilder(
      builder: (context, setLocalState) {
        int touchedIndex = -1;
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                centerSpaceRadius: 54,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setLocalState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  final color = _pieColors[i % _pieColors.length];
                  final isTouched = i == touchedIndex;
                  final pct = total > 0 ? (entry.value / total * 100) : 0.0;
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                    radius: isTouched ? 65 : 56,
                    titleStyle: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 300),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  Formatters.formatCurrency(total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartLegend(List<TransactionModel> transactions) {
    if (_selectedChartType == ChartType.pie) {
      final data = _getPieChartData(transactions);
      if (data.isEmpty) return const SizedBox.shrink();
      final entries = data.entries.toList();
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: entries.asMap().entries.map((e) {
          final color = _pieColors[e.key % _pieColors.length];
          return SizedBox(
            width: 90,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    e.value.key,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_selectedChartType == ChartType.bar) ...[
          _LegendItem(color: AppTheme.success, label: 'Receitas'),
          const SizedBox(width: 16),
          _LegendItem(color: AppTheme.error, label: 'Despesas'),
        ] else ...[
          _LegendItem(color: AppTheme.primaryLight, label: 'Saldo acumulado'),
        ],
      ],
    );
  }

  String _formatChartValue(double value) {
    if (value.abs() >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$ ${value.toStringAsFixed(0)}';
  }

  String _monthLabel(int month) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return months[month - 1];
  }
}

class _PeriodTag extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodTag({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryLight
                : AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primaryLight : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MonthData {
  final int year;
  final int month;
  final double income;
  final double expense;
  final double balance;

  const _MonthData({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    this.balance = 0,
  });

  _MonthData copyWith({double? income, double? expense, double? balance}) {
    return _MonthData(
      year: year,
      month: month,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
    );
  }
}
