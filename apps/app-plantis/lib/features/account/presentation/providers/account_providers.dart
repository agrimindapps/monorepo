import 'package:core/core.dart' hide Column, DeleteAccountUseCase, LogoutUseCase;
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../data/datasources/account_local_datasource.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/clear_data_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/core_di_providers.dart';
import '../../../../database/providers/database_providers.dart';

part 'account_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

@riverpod
AccountRemoteDataSource accountRemoteDataSource(
  Ref ref,
) {
  final firebaseAuth = fb.FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  return AccountRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firebaseFirestore: firebaseFirestore,
  );
}

@riverpod
AccountLocalDataSource accountLocalDataSource(Ref ref) {
  final plantsRepo = ref.watch(plantsDriftRepositoryProvider);
  final spacesRepo = ref.watch(spacesDriftRepositoryProvider);
  final tasksRepo = ref.watch(tasksDriftRepositoryProvider);
  final plantTasksRepo = ref.watch(plantTasksDriftRepositoryProvider);

  return AccountLocalDataSourceImpl(
    plantsRepo: plantsRepo,
    spacesRepo: spacesRepo,
    tasksRepo: tasksRepo,
    plantTasksRepo: plantTasksRepo,
  );
}

// ============================================================================
// Services
// ============================================================================

@riverpod
EnhancedAccountDeletionService enhancedAccountDeletionService(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final appDataCleaner = ref.watch(dataCleanerServiceProvider);

  return EnhancedAccountDeletionService(
    authRepository: authRepository,
    appDataCleaner: appDataCleaner,
  );
}

// ============================================================================
// Repository
// ============================================================================

@riverpod
AccountRepository accountRepository(Ref ref) {
  final remoteDataSource = ref.watch(accountRemoteDataSourceProvider);
  final localDataSource = ref.watch(accountLocalDataSourceProvider);
  final firebaseAuth = fb.FirebaseAuth.instance;
  final enhancedDeletionService = ref.watch(
    enhancedAccountDeletionServiceProvider,
  );

  return AccountRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    firebaseAuth: firebaseAuth,
    enhancedDeletionService: enhancedDeletionService,
  );
}

// ============================================================================
// Use Cases
// ============================================================================

@riverpod
GetAccountInfoUseCase getAccountInfoUseCase(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return GetAccountInfoUseCase(repository);
}

@riverpod
LogoutUseCase accountLogoutUseCase(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return LogoutUseCase(repository);
}

@riverpod
ClearDataUseCase clearDataUseCase(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return ClearDataUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

// ============================================================================
// State Providers
// ============================================================================

/// Provider para obter informações da conta do usuário
@riverpod
Future<AccountInfo> accountInfo(Ref ref) async {
  final useCase = ref.watch(getAccountInfoUseCaseProvider);
  final result = await useCase(const NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (accountInfo) => accountInfo,
  );
}

/// Provider para stream de mudanças na conta
@riverpod
Stream<AccountInfo?> accountInfoStream(Ref ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAccountInfo();
}

// ============================================================================
// Action Providers
// ============================================================================

/// Provider para ação de logout
@riverpod
class LogoutNotifier extends _$LogoutNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<Either<Failure, void>> logout() async {
    state = const AsyncLoading();

    final useCase = ref.read(accountLogoutUseCaseProvider);
    final result = await useCase(const NoParams());

    if (result.isRight()) {
      state = const AsyncData<void>(null);
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AsyncError<void>(failure ?? Exception(), StackTrace.current);
    }

    return result;
  }
}

/// Provider para ação de limpar dados
@riverpod
class ClearDataNotifier extends _$ClearDataNotifier {
  @override
  FutureOr<int?> build() {
    return null;
  }

  Future<Either<Failure, int>> clearData() async {
    state = const AsyncLoading();

    final useCase = ref.read(clearDataUseCaseProvider);
    final result = await useCase(const NoParams());

    if (result.isRight()) {
      final count = result.fold((f) => 0, (c) => c);
      state = AsyncData<int?>(count);
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AsyncError<int?>(failure ?? Exception(), StackTrace.current);
    }

    return result;
  }
}

/// Provider para ação de excluir conta
@riverpod
class DeleteAccountNotifier extends _$DeleteAccountNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<Either<Failure, void>> deleteAccount() async {
    state = const AsyncLoading();

    final useCase = ref.read(deleteAccountUseCaseProvider);
    final result = await useCase(const NoParams());

    if (result.isRight()) {
      state = const AsyncData<void>(null);
    } else {
      final failure = result.fold((f) => f, (r) => null);
      state = AsyncError<void>(failure ?? Exception(), StackTrace.current);
    }

    return result;
  }
}
