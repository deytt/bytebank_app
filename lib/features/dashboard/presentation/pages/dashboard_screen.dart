import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/pages/transaction_list_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/carousel_section.dart';
import '../widgets/chart_card.dart';
import '../widgets/services_section.dart';
import '../widgets/stories_section.dart';
import '../widgets/user_account_modal.dart';
import 'dashboard_animations_mixin.dart';
import 'dashboard_content.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleThemeMode;

  const DashboardScreen({super.key, required this.onToggleThemeMode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin<DashboardScreen>, DashboardAnimationsMixin<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    setupAnimations(this);
    pageController.forward();
  }

  @override
  void dispose() {
    pageController.dispose();
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

  void _showUserModal(BuildContext context, User user) {
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
                  opacity: actionsFade,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                      );
                    },
                    backgroundColor: t.primary,
                    foregroundColor: t.white,
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

  AppBar _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      title: SlideTransition(
        position: headerSlide,
        child: FadeTransition(
          opacity: headerFade,
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
            position: storiesSlide,
            child: FadeTransition(
              opacity: storiesFade,
              child: DashboardStoriesSection(items: DashboardContent.storyItems(t)),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: balanceSlide,
            child: FadeTransition(
              opacity: balanceFade,
              child: DashboardBalanceCard(loaded: loaded),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: chartSlide,
            child: FadeTransition(
              opacity: chartFade,
              child: DashboardChartCard(transactions: loaded?.allTransactions ?? []),
            ),
          ),
          const SizedBox(height: 24),
          SlideTransition(
            position: services1Slide,
            child: FadeTransition(
              opacity: services1Fade,
              child: ServiceScrollSection(
                title: 'Para seu dia a dia',
                items: DashboardContent.dailyServices(t),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: services2Slide,
            child: FadeTransition(
              opacity: services2Fade,
              child: ServiceScrollSection(
                title: 'Mais serviços financeiros',
                items: DashboardContent.financialServices(t),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: carouselSlide,
            child: FadeTransition(
              opacity: carouselFade,
              child: DashboardCarouselSection(items: DashboardContent.carouselItems(t)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
