import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CarouselItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const CarouselItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });
}

class DashboardCarouselSection extends StatefulWidget {
  const DashboardCarouselSection({super.key});

  @override
  State<DashboardCarouselSection> createState() => _DashboardCarouselSectionState();
}

class _DashboardCarouselSectionState extends State<DashboardCarouselSection> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  static const _items = [
    CarouselItemData(
      title: 'Cashback especial',
      subtitle: 'Ganhe até 5% de volta em compras online selecionadas',
      icon: Icons.card_giftcard,
      gradientColors: [AppTheme.primary, AppTheme.primaryLight],
    ),
    CarouselItemData(
      title: 'Empréstimo pessoal',
      subtitle: 'Taxas a partir de 1,29% a.m. com aprovação em minutos',
      icon: Icons.attach_money,
      gradientColors: [AppTheme.gradientBlueDark, AppTheme.gradientBlue],
    ),
    CarouselItemData(
      title: 'Conta digital grátis',
      subtitle: 'Sem tarifas de manutenção e com rendimento automático',
      icon: Icons.account_balance_wallet,
      gradientColors: [AppTheme.gradientGreenDark, AppTheme.gradientGreen],
    ),
    CarouselItemData(
      title: 'Invista agora',
      subtitle: 'Rendimento de até 120% do CDI com liquidez diária',
      icon: Icons.trending_up,
      gradientColors: [AppTheme.gradientAmberDark, AppTheme.gradientAmber],
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
