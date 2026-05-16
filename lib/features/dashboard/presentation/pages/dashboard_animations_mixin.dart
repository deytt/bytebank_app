import 'package:flutter/material.dart';

mixin DashboardAnimationsMixin<T extends StatefulWidget> on State<T> {
  late AnimationController pageController;

  late Animation<double> headerFade;
  late Animation<Offset> headerSlide;
  late Animation<double> balanceFade;
  late Animation<Offset> balanceSlide;
  late Animation<double> chartFade;
  late Animation<Offset> chartSlide;
  late Animation<double> actionsFade;
  late Animation<double> storiesFade;
  late Animation<Offset> storiesSlide;
  late Animation<double> services1Fade;
  late Animation<Offset> services1Slide;
  late Animation<double> services2Fade;
  late Animation<Offset> services2Slide;
  late Animation<double> carouselFade;
  late Animation<Offset> carouselSlide;

  void setupAnimations(TickerProvider vsync) {
    pageController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
      ),
    );
    headerSlide = Tween<Offset>(begin: const Offset(0.0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    storiesFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.30, 0.55, curve: Curves.easeOut),
      ),
    );
    storiesSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.30, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    balanceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.375, 0.625, curve: Curves.easeOut),
      ),
    );
    balanceSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.375, 0.625, curve: Curves.easeOutCubic),
      ),
    );

    chartFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.425, 0.725, curve: Curves.easeOut),
      ),
    );
    chartSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.425, 0.725, curve: Curves.easeOutCubic),
      ),
    );

    actionsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.525, 0.725, curve: Curves.easeOut),
      ),
    );

    services1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeOut),
      ),
    );
    services1Slide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    services2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.675, 0.925, curve: Curves.easeOut),
      ),
    );
    services2Slide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.675, 0.925, curve: Curves.easeOutCubic),
      ),
    );

    carouselFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.75, 1.00, curve: Curves.easeOut),
      ),
    );
    carouselSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: pageController,
        curve: const Interval(0.75, 1.00, curve: Curves.easeOutCubic),
      ),
    );
  }
}
