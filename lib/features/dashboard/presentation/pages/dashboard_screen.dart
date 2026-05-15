import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/pages/transaction_list_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/carousel_section.dart';
import '../widgets/chart_card.dart';
import '../widgets/services_section.dart';
import '../widgets/stories_section.dart';
import '../widgets/user_account_modal.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleThemeMode;

  const DashboardScreen({super.key, required this.onToggleThemeMode});

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

  List<ServiceCardData> _dailyServices(AppThemeTokens t) {
    return [
      ServiceCardData(icon: Icons.account_balance, label: 'Meus bancos', color: t.primary),
      ServiceCardData(icon: Icons.smartphone, label: 'Token', color: t.primaryLight),
      ServiceCardData(icon: Icons.credit_card, label: 'Limite de crédito', color: t.success),
      ServiceCardData(icon: Icons.calendar_today, label: 'Agendamentos', color: t.primary),
      ServiceCardData(icon: Icons.receipt_long, label: 'Boletos - DDA', color: t.primaryLight),
      ServiceCardData(
        icon: Icons.arrow_forward_ios,
        label: 'Ver Mais',
        color: t.textSecondary,
      ),
    ];
  }

  List<ServiceCardData> _financialServices(AppThemeTokens t) {
    return [
      ServiceCardData(icon: Icons.handshake, label: 'Renegociação', color: t.error),
      ServiceCardData(icon: Icons.group, label: 'Consórcio', color: t.primaryLight),
      ServiceCardData(icon: Icons.trending_up, label: 'Capitalização', color: t.success),
      ServiceCardData(icon: Icons.currency_exchange, label: 'Câmbio', color: t.primary),
      ServiceCardData(icon: Icons.security, label: 'Seguros', color: t.primaryLight),
      ServiceCardData(
        icon: Icons.arrow_forward_ios,
        label: 'Ver Mais',
        color: t.textSecondary,
      ),
    ];
  }

  List<StoryItemData> _storyItems(AppThemeTokens t) {
    return [
      StoryItemData(
        label: 'Cashback',
        icon: Icons.card_giftcard,
        gradientColors: [t.primary, t.primaryLight],
        offerTitle: 'Cashback especial',
        offerSubtitle:
            'Ganhe até 5% de volta em compras online selecionadas. Ative agora e aproveite nas suas lojas favoritas.',
        offerCta: 'Ativar cashback',
      ),
      StoryItemData(
        label: 'Empréstimo',
        icon: Icons.attach_money,
        gradientColors: [t.gradientBlueDark, t.gradientBlue],
        offerTitle: 'Empréstimo pessoal',
        offerSubtitle:
            'Taxas a partir de 1,29% a.m. com aprovação em minutos. Simule agora sem comprometer seu score.',
        offerCta: 'Simular agora',
      ),
      StoryItemData(
        label: 'Conta',
        icon: Icons.account_balance_wallet,
        gradientColors: [t.gradientGreenDark, t.gradientGreen],
        offerTitle: 'Conta digital grátis',
        offerSubtitle:
            'Sem tarifas de manutenção e com rendimento automático. Indique amigos e ganhe bônus exclusivos.',
        offerCta: 'Abrir conta',
      ),
      StoryItemData(
        label: 'Investir',
        icon: Icons.trending_up,
        gradientColors: [t.gradientAmberDark, t.gradientAmber],
        offerTitle: 'Invista agora',
        offerSubtitle:
            'Rendimento de até 120% do CDI com liquidez diária. Comece com qualquer valor e veja seu dinheiro crescer.',
        offerCta: 'Começar a investir',
      ),
      StoryItemData(
        label: 'Tag',
        icon: Icons.directions_car,
        gradientColors: const [Color(0xFF0C4A6E), Color(0xFF0284C7)],
        offerTitle: 'Tag de pedágio',
        offerSubtitle:
            'Passe sem parar em pedágios e estacionamentos em todo o Brasil. Peça a sua Tag gratuita agora.',
        offerCta: 'Pedir minha Tag',
      ),
      StoryItemData(
        label: 'Livelo',
        icon: Icons.star_rounded,
        gradientColors: const [Color(0xFF7C2D12), Color(0xFFEA580C)],
        offerTitle: 'Pontos Livelo',
        offerSubtitle:
            'Acumule pontos em cada compra e troque por passagens, produtos e experiências incríveis.',
        offerCta: 'Ver meus pontos',
      ),
      StoryItemData(
        label: 'Empresa',
        icon: Icons.business_center,
        gradientColors: [t.gradientBlueDark, t.gradientBlue],
        offerTitle: 'Conta PJ gratuita',
        offerSubtitle:
            'Conta para sua empresa sem tarifas de manutenção, com Pix ilimitado e gestão financeira integrada.',
        offerCta: 'Abrir conta PJ',
      ),
    ];
  }

  List<CarouselItemData> _carouselItems(AppThemeTokens t) {
    return [
      CarouselItemData(
        title: 'Cashback especial',
        subtitle: 'Ganhe até 5% de volta em compras online selecionadas',
        icon: Icons.card_giftcard,
        gradientColors: [t.primary, t.primaryLight],
      ),
      CarouselItemData(
        title: 'Empréstimo pessoal',
        subtitle: 'Taxas a partir de 1,29% a.m. com aprovação em minutos',
        icon: Icons.attach_money,
        gradientColors: [t.gradientBlueDark, t.gradientBlue],
      ),
      CarouselItemData(
        title: 'Conta digital grátis',
        subtitle: 'Sem tarifas de manutenção e com rendimento automático',
        icon: Icons.account_balance_wallet,
        gradientColors: [t.gradientGreenDark, t.gradientGreen],
      ),
      CarouselItemData(
        title: 'Invista agora',
        subtitle: 'Rendimento de até 120% do CDI com liquidez diária',
        icon: Icons.trending_up,
        gradientColors: [t.gradientAmberDark, t.gradientAmber],
      ),
    ];
  }

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
      builder: (dialogContext) {
        final t = AppTheme.of(dialogContext);
        return AlertDialog(
          title: const Text('Confirmar logout'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: t.error),
              child: const Text('Sair'),
            ),
          ],
        );
      },
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
            final t = AppTheme.of(context);

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) _confirmLogout(context);
              },
              child: Scaffold(
                backgroundColor: t.background,
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
                      : _buildBody(context, loaded, t),
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
                    backgroundColor: t.primary,
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
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: widget.onToggleThemeMode,
        ),
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

  Widget _buildBody(BuildContext context, TransactionLoaded? loaded, AppThemeTokens t) {
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
              child: DashboardStoriesSection(items: _storyItems(t)),
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
              child: ServiceScrollSection(title: 'Para seu dia a dia', items: _dailyServices(t)),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _services2Slide,
            child: FadeTransition(
              opacity: _services2Fade,
              child: ServiceScrollSection(
                title: 'Mais serviços financeiros',
                items: _financialServices(t),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _carouselSlide,
            child: FadeTransition(
              opacity: _carouselFade,
              child: DashboardCarouselSection(items: _carouselItems(t)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
