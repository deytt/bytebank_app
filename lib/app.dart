import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplashScreen();
  }

  Future<void> _hideSplashScreen() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bytebank App',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: _showSplash
          ? const SplashScreen()
          : BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<TransactionBloc>().add(
                        LoadTransactions(userId: state.user.id, refresh: true),
                      );
                }
              },
              builder: (context, state) {
                if (state is AuthInitial || state is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is AuthAuthenticated) {
                  return const DashboardScreen();
                }

                return const LoginScreen();
              },
            ),
    );
  }
}
