import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../transactions/transaction_list_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/carousel_section.dart';
import 'widgets/chart_card.dart';
import 'widgets/services_section.dart';
import 'widgets/stories_section.dart';
import 'widgets/user_account_modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pageController;

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
    ServiceCardData(icon: Icons.account_balance, label: 'Meus bancos', color: AppTheme.primary),
    ServiceCardData(icon: Icons.smartphone, label: 'Token', color: AppTheme.primaryLight),
    ServiceCardData(icon: Icons.credit_card, label: 'Limite de crédito', color: AppTheme.success),
    ServiceCardData(icon: Icons.calendar_today, label: 'Agendamentos', color: AppTheme.primary),
    ServiceCardData(icon: Icons.receipt_long, label: 'Boletos - DDA', color: AppTheme.primaryLight),
    ServiceCardData(
      icon: Icons.arrow_forward_ios,
      label: 'Ver Mais',
      color: AppTheme.textSecondary,
    ),
  ];

  static const _financialServices = [
    ServiceCardData(icon: Icons.handshake, label: 'Renegociação', color: AppTheme.error),
    ServiceCardData(icon: Icons.group, label: 'Consórcio', color: AppTheme.primaryLight),
    ServiceCardData(icon: Icons.trending_up, label: 'Capitalização', color: AppTheme.success),
    ServiceCardData(icon: Icons.currency_exchange, label: 'Câmbio', color: AppTheme.primary),
    ServiceCardData(icon: Icons.security, label: 'Seguros', color: AppTheme.primaryLight),
    ServiceCardData(
      icon: Icons.arrow_forward_ios,
      label: 'Ver Mais',
      color: AppTheme.textSecondary,
    ),
  ];

  static const _storyItems = [
    StoryItemData(
      label: 'Cashback',
      icon: Icons.card_giftcard,
      gradientColors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
      offerTitle: 'Cashback especial',
      offerSubtitle:
          'Ganhe até 5% de volta em compras online selecionadas. Ative agora e aproveite nas suas lojas favoritas.',
      offerCta: 'Ativar cashback',
    ),
    StoryItemData(
      label: 'Empréstimo',
      icon: Icons.attach_money,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
      offerTitle: 'Empréstimo pessoal',
      offerSubtitle:
          'Taxas a partir de 1,29% a.m. com aprovação em minutos. Simule agora sem comprometer seu score.',
      offerCta: 'Simular agora',
    ),
    StoryItemData(
      label: 'Conta',
      icon: Icons.account_balance_wallet,
      gradientColors: [Color(0xFF064E3B), Color(0xFF059669)],
      offerTitle: 'Conta digital grátis',
      offerSubtitle:
          'Sem tarifas de manutenção e com rendimento automático. Indique amigos e ganhe bônus exclusivos.',
      offerCta: 'Abrir conta',
    ),
    StoryItemData(
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
    _pageController.forward();
  }

  void _setupAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0.0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _storiesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.30, 0.55, curve: Curves.easeOut),
      ),
    );
    _storiesSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.30, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _balanceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.375, 0.625, curve: Curves.easeOut),
      ),
    );
    _balanceSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.375, 0.625, curve: Curves.easeOutCubic),
      ),
    );

    _chartFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.425, 0.725, curve: Curves.easeOut),
      ),
    );
    _chartSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.425, 0.725, curve: Curves.easeOutCubic),
      ),
    );

    _actionsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.525, 0.725, curve: Curves.easeOut),
      ),
    );

    _services1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeOut),
      ),
    );
    _services1Slide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _services2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.675, 0.925, curve: Curves.easeOut),
      ),
    );
    _services2Slide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.675, 0.925, curve: Curves.easeOutCubic),
      ),
    );

    _carouselFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.75, 1.00, curve: Curves.easeOut),
      ),
    );
    _carouselSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _pageController,
        curve: const Interval(0.75, 1.00, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _showUserModal(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: UserAccountModal(user: user),
      ),
    );
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
                if (!didPop) _confirmLogout(context);
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
                child: DashboardUserAvatar(user: user),
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
              child: DashboardStoriesSection(items: _storyItems),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _balanceSlide,
            child: FadeTransition(
              opacity: _balanceFade,
              child: DashboardBalanceCard(loaded: loaded),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _chartSlide,
            child: FadeTransition(
              opacity: _chartFade,
              child: DashboardChartCard(transactions: loaded?.allTransactions ?? []),
            ),
          ),
          const SizedBox(height: 24),
          SlideTransition(
            position: _services1Slide,
            child: FadeTransition(
              opacity: _services1Fade,
              child: const ServiceScrollSection(title: 'Para seu dia a dia', items: _dailyServices),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _services2Slide,
            child: FadeTransition(
              opacity: _services2Fade,
              child: const ServiceScrollSection(
                title: 'Mais serviços financeiros',
                items: _financialServices,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _carouselSlide,
            child: FadeTransition(opacity: _carouselFade, child: const DashboardCarouselSection()),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
