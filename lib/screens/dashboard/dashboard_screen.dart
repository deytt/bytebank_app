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

enum _ChartType { line, bar, pie }

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

class _StoryItemData {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final String offerTitle;
  final String offerSubtitle;
  final String offerCta;

  const _StoryItemData({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.offerTitle,
    required this.offerSubtitle,
    required this.offerCta,
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

  late AnimationController _storiesController;
  late AnimationController _services1Controller;
  late AnimationController _services2Controller;
  late AnimationController _carouselController;

  late PageController _chartPageController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _balanceFade;
  late Animation<Offset> _balanceSlide;
  late Animation<double> _chartFade;
  late Animation<Offset> _chartSlide;
  late Animation<double> _actionsFade;

  late Animation<double> _storiesFade;
  late Animation<Offset> _storiesSlide;
  late Animation<double> _services1Fade;
  late Animation<Offset> _services1Slide;
  late Animation<double> _services2Fade;
  late Animation<Offset> _services2Slide;
  late Animation<double> _carouselFade;
  late Animation<Offset> _carouselSlide;

  static const _dailyServices = [
    _ServiceCardData(icon: Icons.account_balance, label: 'Meus bancos', color: AppTheme.primary),
    _ServiceCardData(icon: Icons.smartphone, label: 'Token', color: AppTheme.primaryLight),
    _ServiceCardData(icon: Icons.credit_card, label: 'Limite de crédito', color: AppTheme.success),
    _ServiceCardData(icon: Icons.calendar_today, label: 'Agendamentos', color: AppTheme.primary),
    _ServiceCardData(
      icon: Icons.receipt_long,
      label: 'Boletos - DDA',
      color: AppTheme.primaryLight,
    ),
    _ServiceCardData(
      icon: Icons.arrow_forward_ios,
      label: 'Ver Mais',
      color: AppTheme.textSecondary,
    ),
  ];

  static const _financialServices = [
    _ServiceCardData(icon: Icons.handshake, label: 'Renegociação', color: AppTheme.error),
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

  static const _storyItems = [
    _StoryItemData(
      label: 'Cashback',
      icon: Icons.card_giftcard,
      gradientColors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
      offerTitle: 'Cashback especial',
      offerSubtitle:
          'Ganhe até 5% de volta em compras online selecionadas. Ative agora e aproveite nas suas lojas favoritas.',
      offerCta: 'Ativar cashback',
    ),
    _StoryItemData(
      label: 'Empréstimo',
      icon: Icons.attach_money,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
      offerTitle: 'Empréstimo pessoal',
      offerSubtitle:
          'Taxas a partir de 1,29% a.m. com aprovação em minutos. Simule agora sem comprometer seu score.',
      offerCta: 'Simular agora',
    ),
    _StoryItemData(
      label: 'Conta',
      icon: Icons.account_balance_wallet,
      gradientColors: [Color(0xFF064E3B), Color(0xFF059669)],
      offerTitle: 'Conta digital grátis',
      offerSubtitle:
          'Sem tarifas de manutenção e com rendimento automático. Indique amigos e ganhe bônus exclusivos.',
      offerCta: 'Abrir conta',
    ),
    _StoryItemData(
      label: 'Investir',
      icon: Icons.trending_up,
      gradientColors: [Color(0xFF78350F), Color(0xFFD97706)],
      offerTitle: 'Invista agora',
      offerSubtitle:
          'Rendimento de até 120% do CDI com liquidez diária. Comece com qualquer valor e veja seu dinheiro crescer.',
      offerCta: 'Começar a investir',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runAnimationSequence();
  }

  void _setupAnimations() {
    _storiesController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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

    _storiesFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _storiesController, curve: Curves.easeOut));
    _storiesSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _storiesController, curve: Curves.easeOutCubic));

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

    _chartPageController = PageController();
  }

  Future<void> _runAnimationSequence() async {
    await _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _storiesController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
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
    _storiesController.dispose();
    _headerController.dispose();
    _balanceController.dispose();
    _chartController.dispose();
    _actionsController.dispose();
    _services1Controller.dispose();
    _services2Controller.dispose();
    _carouselController.dispose();
    _chartPageController.dispose();
    super.dispose();
  }

  static const _pieColors = [
    AppTheme.primaryLight,
    AppTheme.success,
    AppTheme.error,
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    AppTheme.textSecondary,
  ];

  String get _chartTitle {
    switch (_selectedChartType) {
      case _ChartType.line:
        return 'Saldo Acumulado';
      case _ChartType.bar:
        return 'Receitas e Despesas';
      case _ChartType.pie:
        return 'Despesas por Categoria';
    }
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
            position: _storiesSlide,
            child: FadeTransition(
              opacity: _storiesFade,
              child: _StoriesSection(items: _storyItems),
            ),
          ),
          const SizedBox(height: 20),
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
                      controller: _chartPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedChartType = const [
                            _ChartType.line,
                            _ChartType.bar,
                            _ChartType.pie,
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
                    const [_ChartType.line, _ChartType.bar, _ChartType.pie][i] ==
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
          selected: _selectedPeriod == _ChartPeriod.last3Months,
          onTap: () => setState(() => _selectedPeriod = _ChartPeriod.last3Months),
        ),
        const SizedBox(width: 6),
        _PeriodTag(
          label: '12m',
          selected: _selectedPeriod == _ChartPeriod.last12Months,
          onTap: () => setState(() => _selectedPeriod = _ChartPeriod.last12Months),
        ),
        const SizedBox(width: 6),
        _PeriodTag(
          label: 'Total',
          selected: _selectedPeriod == _ChartPeriod.total,
          onTap: () => setState(() => _selectedPeriod = _ChartPeriod.total),
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

  List<TransactionModel> _filterByPeriod(List<TransactionModel> transactions) {
    if (_selectedPeriod == _ChartPeriod.total) return List.from(transactions);
    final now = DateTime.now();
    final startDate = _selectedPeriod == _ChartPeriod.last3Months
        ? DateTime(now.year, now.month - 2, 1)
        : DateTime(now.year, now.month - 11, 1);
    return transactions.where((t) => !t.date.isBefore(startDate)).toList();
  }

  Map<String, double> _getPieChartData(List<TransactionModel> transactions) {
    final expenses = _filterByPeriod(
      transactions,
    ).where((t) => t.type == TransactionType.expense).toList();

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
            fitInsideHorizontally: true,
            fitInsideVertically: true,
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
            fitInsideHorizontally: true,
            fitInsideVertically: true,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartLegend(List<TransactionModel> transactions) {
    if (_selectedChartType == _ChartType.pie) {
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
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
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
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                  maxLines: 2,
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
            color: selected ? AppTheme.primaryLight : AppTheme.textSecondary.withValues(alpha: 0.3),
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

class _BalanceCard extends StatefulWidget {
  final TransactionLoaded? loaded;

  const _BalanceCard({required this.loaded});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _obscured = false;

  @override
  Widget build(BuildContext context) {
    final balance = widget.loaded?.balance ?? 0.0;
    final income = widget.loaded?.totalIncome ?? 0.0;
    final expense = widget.loaded?.totalExpense ?? 0.0;
    final isPositive = balance >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0D3B5E).withValues(alpha: 0.55), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.20)),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _obscured = !_obscured),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      key: ValueKey(_obscured),
                      color: AppTheme.textSecondary,
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
                      color: AppTheme.textSecondary,
                      letterSpacing: 4,
                    ),
                  )
                : AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppTheme.success : AppTheme.error,
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
                  color: AppTheme.success,
                  icon: Icons.arrow_upward_rounded,
                  obscured: _obscured,
                ),
                _BalanceItem(
                  label: 'Despesas',
                  value: expense,
                  color: AppTheme.error,
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

// ─────────────────────────────────────────────
// Stories
// ─────────────────────────────────────────────

class _StoriesSection extends StatelessWidget {
  final List<_StoryItemData> items;

  const _StoriesSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Novidades para você', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _openStoryViewer(context, index),
                  child: SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        _StoryAvatar(item: item),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openStoryViewer(BuildContext context, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, a1, a2) => _StoryViewer(items: items, initialIndex: initialIndex),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final _StoryItemData item;

  const _StoryAvatar({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradientColors,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.background),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.gradientColors[0].withValues(alpha: 0.25),
                item.gradientColors[1].withValues(alpha: 0.25),
              ],
            ),
          ),
          child: Icon(item.icon, color: item.gradientColors[1], size: 26),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Story Viewer
// ─────────────────────────────────────────────

class _StoryViewer extends StatefulWidget {
  final List<_StoryItemData> items;
  final int initialIndex;

  const _StoryViewer({required this.items, required this.initialIndex});

  @override
  State<_StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<_StoryViewer> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this, duration: _storyDuration);
    _progressController.addStatusListener(_onProgressStatus);
    _progressController.forward();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNext();
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() => _currentIndex++);
      _progressController.forward(from: 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.forward(from: 0);
    } else {
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.removeStatusListener(_onProgressStatus);
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_currentIndex];
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              item.gradientColors[0],
              item.gradientColors[1],
              Colors.black.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Área de toque: esquerda/direita
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _goToPrevious,
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _goToNext,
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barras de progresso
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: List.generate(widget.items.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  double value;
                                  if (i < _currentIndex) {
                                    value = 1.0;
                                  } else if (i == _currentIndex) {
                                    value = _progressController.value;
                                  } else {
                                    value = 0.0;
                                  }
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 3,
                                    backgroundColor: AppTheme.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.white),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Botão fechar
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppTheme.white, size: 28),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Conteúdo da oferta
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(item.icon, color: AppTheme.white, size: 48),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.offerTitle,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.offerSubtitle,
                          style: TextStyle(
                            color: AppTheme.white.withValues(alpha: 0.88),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.white,
                              foregroundColor: item.gradientColors[0],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              item.offerCta,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Agora não',
                              style: TextStyle(
                                color: AppTheme.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
