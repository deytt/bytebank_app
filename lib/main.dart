import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/utils/encryption_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'features/transactions/domain/usecases/delete_transaction_usecase.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EncryptionService().initialize();

  final authRepo = AuthRepositoryImpl();
  final txRepo = TransactionRepositoryImpl();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            watchAuthState: WatchAuthStateUseCase(authRepo),
            signIn: SignInUseCase(authRepo),
            signUp: SignUpUseCase(authRepo),
            signInWithGoogle: SignInWithGoogleUseCase(authRepo),
            signOut: SignOutUseCase(authRepo),
          )..add(const AuthStarted()),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            getTransactions: GetTransactionsUseCase(txRepo),
            addTransaction: AddTransactionUseCase(txRepo),
            updateTransaction: UpdateTransactionUseCase(txRepo),
            deleteTransaction: DeleteTransactionUseCase(txRepo),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
