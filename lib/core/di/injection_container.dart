import 'package:get_it/get_it.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/watch_auth_state_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/get_transactions_usecase.dart';
import '../../features/transactions/domain/usecases/get_transaction_aggregates_usecase.dart';
import '../../features/transactions/domain/usecases/add_transaction_usecase.dart';
import '../../features/transactions/domain/usecases/update_transaction_usecase.dart';
import '../../features/transactions/domain/usecases/delete_transaction_usecase.dart';

final getIt = GetIt.instance;

void setup() {
  // Repositories — lazy singletons (instantiated once on first use)
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl());

  // Auth use cases
  getIt.registerFactory(() => WatchAuthStateUseCase(getIt()));
  getIt.registerFactory(() => SignInUseCase(getIt()));
  getIt.registerFactory(() => SignUpUseCase(getIt()));
  getIt.registerFactory(() => SignInWithGoogleUseCase(getIt()));
  getIt.registerFactory(() => SignOutUseCase(getIt()));

  // Transaction use cases
  getIt.registerFactory(() => GetTransactionsUseCase(getIt()));
  getIt.registerFactory(() => GetTransactionAggregatesUseCase(getIt()));
  getIt.registerFactory(() => AddTransactionUseCase(getIt()));
  getIt.registerFactory(() => UpdateTransactionUseCase(getIt()));
  getIt.registerFactory(() => DeleteTransactionUseCase(getIt()));
}
