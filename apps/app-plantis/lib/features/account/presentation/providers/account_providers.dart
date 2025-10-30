import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/account_local_datasource.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/clear_data_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_info_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'account_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

@riverpod
AccountRemoteDataSource accountRemoteDataSource(
  AccountRemoteDataSourceRef ref,
) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AccountRemoteDataSourceImpl(firebaseService);
}

@riverpod
AccountLocalDataSource accountLocalDataSource(
  AccountLocalDataSourceRef ref,
) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AccountLocalDataSourceImpl(hiveService);
}

// ============================================================================
// Repository
// ============================================================================

@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
  final remoteDataSource = ref.watch(accountRemoteDataSourceProvider);
  final localDataSource = ref.watch(accountLocalDataSourceProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);

  return AccountRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    firebaseService: firebaseService,
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
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return LogoutUseCase(repository);
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
    
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
    
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
    
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (count) => AsyncData(count),
    );
    
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
    
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
    
    return result;
  }
}
