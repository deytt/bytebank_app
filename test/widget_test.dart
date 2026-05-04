import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebankapp/core/theme/app_theme.dart';

void main() {
  testWidgets('MaterialApp com temas e AppThemeTokens', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
    final ctx = tester.element(find.byType(Scaffold));
    expect(Theme.of(ctx).extension<AppThemeTokens>(), isNotNull);
  });
}
