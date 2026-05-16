import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';

import 'package:bytebankapp/features/auth/domain/entities/user.dart';
import 'package:bytebankapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:bytebankapp/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:bytebankapp/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:bytebankapp/features/transactions/domain/entities/transaction.dart';
import 'package:bytebankapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/get_transaction_aggregates_usecase.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/add_transaction_usecase.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/update_transaction_usecase.dart';
import 'package:bytebankapp/features/transactions/domain/usecases/delete_transaction_usecase.dart';

// Repositórios
class MockAuthRepository extends Mock implements AuthRepository {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

// Use cases de auth
class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}
class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignUpUseCase extends Mock implements SignUpUseCase {}
class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

// Use cases de transactions
class MockGetTransactionsUseCase extends Mock implements GetTransactionsUseCase {}
class MockGetTransactionAggregatesUseCase extends Mock implements GetTransactionAggregatesUseCase {}
class MockAddTransactionUseCase extends Mock implements AddTransactionUseCase {}
class MockUpdateTransactionUseCase extends Mock implements UpdateTransactionUseCase {}
class MockDeleteTransactionUseCase extends Mock implements DeleteTransactionUseCase {}

// Fallbacks para tipos customizados usados como argumentos de mock
class FakeUser extends Fake implements User {}
class FakeTransaction extends Fake implements Transaction {}

void registerFallbacks() {
  registerFallbackValue(FakeUser());
  registerFallbackValue(FakeTransaction());
  registerFallbackValue(Uint8List(0));
}
