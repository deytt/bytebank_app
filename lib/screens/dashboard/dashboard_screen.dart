import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../transactions/transaction_list_screen.dart';

enum _ChartPeriod { total, last12Months, last3Months }

enum _ChartType { line, bar }

class _ServiceCardData {
  final IconData icon;
  final String label;
  final Color color;

  const _ServiceCardData({required this.icon, required this.label, required this.color});
}

class _CarouselItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _CarouselItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  _ChartPeriod _selectedPeriod = _ChartPeriod.last12Months;
  _ChartType _selectedChartType = _ChartType.line;

  late AnimationController _headerController;
  late AnimationController _balanceController;
  late AnimationController _chartController;
  late AnimationController _actionsController;

  late AnimationController _services1Controller;
  late AnimationController _services2Controller;
  late AnimationController _carouselController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _balanceFade;
  late Animation<Offset> _balanceSlide;
  late Animation<double> _chartFade;
  late Animation<Offset> _chartSlide;
  late Animation<double> _actionsFade;

  late Animation<double> _services1Fade;
  late Animation<Offset> _services1Slide;
  late Animation<double> _services2Fade;
  late Animation<Offset> _services2Slide;
  late Animation<double> _carouselFade;
  late Animation<Offset> _carouselSlide;

  static const _dailyServices = [
    _ServiceCardData(icon: Icons.account_balance, label: 'Meus bancos', color: AppTheme.primary),
    _ServiceCardData(
      icon: Icons.smartphone,
      label: 'Vender pelo celular',
      color: AppTheme.primaryLight,
    ),
    _ServiceCardData(icon: Icons.credit_card, label: 'Limite de crédito', color: AppTheme.success),
    _ServiceCardData(icon: Icons.calendar_today, label: 'Agendamentos', color: AppTheme.primary),
    _ServiceCardData(
      icon: Icons.receipt_long,
      label: 'Buscador de boletos - DDA',
      color: AppTheme.primaryLight,
    ),
    _ServiceCardData(
      icon: Icons.arrow_forward_ios,
      label: 'Ver Mais',
      color: AppTheme.textSecondary,
    ),
  ];

  static const _financialServices = [
    _ServiceCardData(
      icon: Icons.handshake,
      label: 'Renegociação de dívidas',
      color: AppTheme.error,
    ),
    _ServiceCardData(icon: Icons.group, label: 'Consórcio', color: AppTheme.primaryLight),
    _ServiceCardData(icon: Icons.trending_up, label: 'Capitalização', color: AppTheme.success),
    _ServiceCardData(icon: Icons.currency_exchange, label: 'Câmbio', color: AppTheme.primary),
    _ServiceCardData(icon: Icons.security, label: 'Seguros', color: AppTheme.primaryLight),
    _ServiceCardData(
      icon: Icons.arrow_forward_ios,
      label: 'Ver Mais',
      color: AppTheme.textSecondary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runAnimationSequence();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _actionsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _services1Controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _services2Controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _headerFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _balanceFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _balanceController, curve: Curves.easeOut));
    _balanceSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic));

    _chartFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _chartController, curve: Curves.easeOut));
    _chartSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic));

    _actionsFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _actionsController, curve: Curves.easeOut));

    _services1Fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _services1Controller, curve: Curves.easeOut));
    _services1Slide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _services1Controller, curve: Curves.easeOutCubic));

    _services2Fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _services2Controller, curve: Curves.easeOut));
    _services2Slide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _services2Controller, curve: Curves.easeOutCubic));

    _carouselFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _carouselController, curve: Curves.easeOut));
    _carouselSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _carouselController, curve: Curves.easeOutCubic));
  }

  Future<void> _runAnimationSequence() async {
    await _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _balanceController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _chartController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _actionsController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _services1Controller.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _services2Controller.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _carouselController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _balanceController.dispose();
    _chartController.dispose();
    _actionsController.dispose();
    _services1Controller.dispose();
    _services2Controller.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar logout'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            final loaded = txState is TransactionLoaded
                ? txState
                : txState is TransactionActionSuccess
                ? txState.data
                : null;

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  _confirmLogout(context);
                }
              },
              child: Scaffold(
                backgroundColor: AppTheme.background,
                appBar: _buildAppBar(context, user),
                body: RefreshIndicator(
                  onRefresh: () async {
                    if (user != null) {
                      context.read<TransactionBloc>().add(
                        LoadTransactions(userId: user.id, refresh: true),
                      );
                    }
                  },
                  child: loaded == null && txState is TransactionLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildBody(context, loaded),
                ),
                floatingActionButton: FadeTransition(
                  opacity: _actionsFade,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                      );
                    },
                    backgroundColor: AppTheme.primary,
                    icon: const Icon(Icons.list),
                    label: const Text('Transações'),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, UserModel? user) {
    return AppBar(
      title: SlideTransition(
        position: _headerSlide,
        child: FadeTransition(
          opacity: _headerFade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Olá, ${user?.firstName ?? 'Usuário'} 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Dashboard', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showUserModal(context, user),
              child: Hero(
                tag: 'user_avatar',
                child: _UserAvatar(user: user),
              ),
            ),
          ),
        IconButton(icon: const Icon(Icons.logout), onPressed: () => _confirmLogout(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, TransactionLoaded? loaded) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideTransition(
            position: _balanceSlide,
            child: FadeTransition(
              opacity: _balanceFade,
              child: _BalanceCard(loaded: loaded),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _chartSlide,
            child: FadeTransition(opacity: _chartFade, child: _buildChartCard(loaded)),
          ),
          const SizedBox(height: 24),
          SlideTransition(
            position: _services1Slide,
            child: FadeTransition(
              opacity: _services1Fade,
              child: _HorizontalScrollSection(title: 'Para seu dia a dia', items: _dailyServices),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _services2Slide,
            child: FadeTransition(
              opacity: _services2Fade,
              child: _HorizontalScrollSection(
                title: 'Mais serviços financeiros',
                items: _financialServices,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _carouselSlide,
            child: FadeTransition(opacity: _carouselFade, child: const _CarouselSection()),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildChartCard(TransactionLoaded? loaded) {
    final transactions = loaded?.allTransactions ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução do Saldo', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildChartTypeToggle(),
            const SizedBox(height: 12),
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: transactions.isEmpty
                  ? _buildEmptyChart()
                  : SizedBox(
                      key: ValueKey('${_selectedChartType.name}_${_selectedPeriod.name}'),
                      height: 220,
                      child: _selectedChartType == _ChartType.line
                          ? _buildLineChart(transactions)
                          : _buildBarChart(transactions),
                    ),
            ),
            const SizedBox(height: 12),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<_ChartType>(
            segments: const [
              ButtonSegment(
                value: _ChartType.line,
                label: Text('Linha'),
                icon: Icon(Icons.show_chart, size: 16),
              ),
              ButtonSegment(
                value: _ChartType.bar,
                label: Text('Barras'),
                icon: Icon(Icons.bar_chart, size: 16),
              ),
            ],
            selected: {_selectedChartType},
            onSelectionChanged: (value) {
              setState(() {
                _selectedChartType = value.first;
              });
            },
            style: ButtonStyle(textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12))),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: SegmentedButton<_ChartPeriod>(
            segments: const [
              ButtonSegment(value: _ChartPeriod.last3Months, label: Text('3 meses')),
              ButtonSegment(value: _ChartPeriod.last12Months, label: Text('12 meses')),
              ButtonSegment(value: _ChartPeriod.total, label: Text('Total')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (value) {
              setState(() {
                _selectedPeriod = value.first;
              });
            },
            style: ButtonStyle(textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11))),
          ),
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
      case _ChartPeriod.last3Months:
        startDate = DateTime(now.year, now.month - 2, 1);
        break;
      case _ChartPeriod.last12Months:
        startDate = DateTime(now.year, now.month - 11, 1);
        break;
      case _ChartPeriod.total:
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
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatChartValue(value),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: data.length > 6 ? (data.length / 6).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
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
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= data.length) return null;
                final d = data[idx];
                return LineTooltipItem(
                  '${_monthLabel(d.month)}/${d.year}\n${Formatters.formatCurrency(spot.y)}',
                  const TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.w600),
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
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatChartValue(value),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
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
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final d = data[group.x];
              final label = rodIndex == 0 ? 'Receita' : 'Despesa';
              return BarTooltipItem(
                '${_monthLabel(d.month)}/${d.year}\n$label: ${Formatters.formatCurrency(rod.toY)}',
                const TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_selectedChartType == _ChartType.bar) ...[
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
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return months[month - 1];
  }

  void _showUserModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: _UserAccountModal(user: user),
      ),
    );
  }
}

class _HorizontalScrollSection extends StatefulWidget {
  final String title;
  final List<_ServiceCardData> items;

  const _HorizontalScrollSection({required this.title, required this.items});

  @override
  State<_HorizontalScrollSection> createState() => _HorizontalScrollSectionState();
}

class _HorizontalScrollSectionState extends State<_HorizontalScrollSection> {
  late final ScrollController _scrollController;
  final _progress = ValueNotifier<double>(0.0);

  static const double _cardWidth = 100.0;
  static const double _cardSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.maxScrollExtent > 0) {
      _progress.value = _scrollController.offset / _scrollController.position.maxScrollExtent;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            return AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: widget.items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;

                      final cardCenter =
                          idx * (_cardWidth + _cardSpacing) + _cardWidth / 2 - offset;
                      final distFromCenter = (cardCenter - viewportWidth / 2).abs();
                      final scale = (1.0 - (distFromCenter / viewportWidth).clamp(0.0, 1.0) * 0.10)
                          .clamp(0.90, 1.0);

                      return Padding(
                        padding: EdgeInsets.only(
                          right: idx < widget.items.length - 1 ? _cardSpacing : 0,
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: _ServiceCard(data: item),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (context, value, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  minHeight: 3,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceCardData data;

  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [data.color.withValues(alpha: 0.25), AppTheme.surface],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.color.withValues(alpha: 0.18)),
            ),
            child: Icon(data.icon, color: data.color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CarouselSection extends StatefulWidget {
  const _CarouselSection();

  @override
  State<_CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<_CarouselSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  static const _items = [
    _CarouselItemData(
      title: 'Cashback especial',
      subtitle: 'Ganhe até 5% de volta em compras online selecionadas',
      icon: Icons.card_giftcard,
      gradientColors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
    ),
    _CarouselItemData(
      title: 'Empréstimo pessoal',
      subtitle: 'Taxas a partir de 1,29% a.m. com aprovação em minutos',
      icon: Icons.attach_money,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
    ),
    _CarouselItemData(
      title: 'Conta digital grátis',
      subtitle: 'Sem tarifas de manutenção e com rendimento automático',
      icon: Icons.account_balance_wallet,
      gradientColors: [Color(0xFF064E3B), Color(0xFF059669)],
    ),
    _CarouselItemData(
      title: 'Invista agora',
      subtitle: 'Rendimento de até 120% do CDI com liquidez diária',
      icon: Icons.trending_up,
      gradientColors: [Color(0xFF78350F), Color(0xFFD97706)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Ofertas para você', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 0.96;
                  if (_pageController.position.haveDimensions) {
                    final page = _pageController.page ?? _currentPage.toDouble();
                    scale = (1.0 - (page - index).abs() * 0.04).clamp(0.96, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: item.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    color: AppTheme.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.icon, color: AppTheme.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppTheme.primaryLight : AppTheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final TransactionLoaded? loaded;

  const _BalanceCard({required this.loaded});

  @override
  Widget build(BuildContext context) {
    final balance = loaded?.balance ?? 0.0;
    final income = loaded?.totalIncome ?? 0.0;
    final expense = loaded?.totalExpense ?? 0.0;
    final isPositive = balance >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Saldo Atual', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: isPositive ? AppTheme.success : AppTheme.error,
              ),
              child: Text(Formatters.formatCurrency(balance)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BalanceItem(
                  label: 'Receitas',
                  value: income,
                  color: AppTheme.success,
                  icon: Icons.arrow_upward,
                ),
                Container(height: 40, width: 1, color: AppTheme.surface),
                _BalanceItem(
                  label: 'Despesas',
                  value: expense,
                  color: AppTheme.error,
                  icon: Icons.arrow_downward,
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

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(value),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
        ),
      ],
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

class _UserAvatar extends StatelessWidget {
  final UserModel user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppTheme.primary,
      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
      child: user.photoUrl == null
          ? Text(
              user.initials,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

class _UserAccountModal extends StatelessWidget {
  final UserModel user;

  const _UserAccountModal({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'user_avatar',
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primary,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(
                      user.initials,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName ?? user.firstName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'Agência', value: '0001'),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'Conta', value: '${user.id.substring(0, 5).toUpperCase()}-7'),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'Chave Pix', value: user.email),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'E-mail', value: user.email),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
