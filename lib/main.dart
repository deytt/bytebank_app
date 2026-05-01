import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/utils/encryption_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EncryptionService().initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc()..add(const AuthStarted()),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(),
        ),
      ],
      child: const App(),
    ),
  );
}
