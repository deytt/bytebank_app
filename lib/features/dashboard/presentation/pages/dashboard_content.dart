import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/carousel_section.dart';
import '../widgets/services_section.dart';
import '../widgets/stories_section.dart';

abstract final class DashboardContent {
  static List<ServiceCardData> dailyServices(AppThemeTokens t) {
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

  static List<ServiceCardData> financialServices(AppThemeTokens t) {
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

  static List<StoryItemData> storyItems(AppThemeTokens t) {
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
        gradientColors: [t.gradientSkyDark, t.gradientSky],
        offerTitle: 'Tag de pedágio',
        offerSubtitle:
            'Passe sem parar em pedágios e estacionamentos em todo o Brasil. Peça a sua Tag gratuita agora.',
        offerCta: 'Pedir minha Tag',
      ),
      StoryItemData(
        label: 'Livelo',
        icon: Icons.star_rounded,
        gradientColors: [t.gradientOrangeDark, t.gradientOrange],
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

  static List<CarouselItemData> carouselItems(AppThemeTokens t) {
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
}
