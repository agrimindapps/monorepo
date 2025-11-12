import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:core/core.dart' hide Column, DeleteAccountUseCase;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/data_cleaner_service.dart';
import '../../../../database/repositories/plant_tasks_drift_repository.dart';
import '../../../../database/repositories/plants_drift_repository.dart';
import '../../../../database/repositories/spaces_drift_repository.dart';
import '../../../../database/repositories/tasks_drift_repository.dart';
import '../../data/datasources/account_local_datasource.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/clear_data_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart' as account_logout;

part 'account_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

@riverpod
AccountRemoteDataSource accountRemoteDataSource(
  AccountRemoteDataSourceRef ref,
) {
  final firebaseAuth = fb.FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  return AccountRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firebaseFirestore: firebaseFirestore,
  );
}

@riverpod
AccountLocalDataSource accountLocalDataSource(AccountLocalDataSourceRef ref) {
  // Injeta Drift repositories via GetIt
  final plantsRepo = di.sl<PlantsDriftRepository>();
  final spacesRepo = di.sl<SpacesDriftRepository>();
  final tasksRepo = di.sl<TasksDriftRepository>();
  final plantTasksRepo = di.sl<PlantTasksDriftRepository>();

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
  // Obtém dependências via GetIt (injetadas no DI principal)
  final authRepository = di.sl<IAuthRepository>();
  final appDataCleaner = di.sl<DataCleanerService>();

  return EnhancedAccountDeletionService(
    authRepository: authRepository,
    appDataCleaner: appDataCleaner,
  );
}

// ============================================================================
// Repository
// ============================================================================

@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
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
GetAccountInfoUseCase getAccountInfoUseCase(GetAccountInfoUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return GetAccountInfoUseCase(repository);
}

@riverpod
account_logout.LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return account_logout.LogoutUseCase(repository);
}

@riverpod
ClearDataUseCase clearDataUseCase(ClearDataUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return ClearDataUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(DeleteAccountUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

// ============================================================================
// State Providers
// ============================================================================

/// Provider para obter informações da conta do usuário
@riverpod
Future<AccountInfo> accountInfo(AccountInfoRef ref) async {
  final useCase = ref.watch(getAccountInfoUseCaseProvider);
  final result = await useCase(const NoParams());

  return result.fold(
    (failure) => throw Exception(failure.message),
    (accountInfo) => accountInfo,
  );
}

/// Provider para stream de mudanças na conta
@riverpod
Stream<AccountInfo?> accountInfoStream(AccountInfoStreamRef ref) {
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

    final useCase = ref.read(logoutUseCaseProvider);
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
