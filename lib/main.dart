import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/utils/encryption_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EncryptionService().initialize();
  setup();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            watchAuthState: getIt(),
            signIn: getIt(),
            signUp: getIt(),
            signInWithGoogle: getIt(),
            signOut: getIt(),
          )..add(const AuthStarted()),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            getTransactions: getIt(),
            getAggregates: getIt(),
            addTransaction: getIt(),
            updateTransaction: getIt(),
            deleteTransaction: getIt(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
