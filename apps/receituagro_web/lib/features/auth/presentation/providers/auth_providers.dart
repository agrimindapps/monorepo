import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_providers.g.dart';

// ========== Use Cases Providers ==========

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return getIt<LoginUseCase>();
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return getIt<LogoutUseCase>();
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) {
  return getIt<GetCurrentUserUseCase>();
}

// ========== Auth State Provider ==========

/// Main authentication state provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    return _fetchCurrentUser();
  }

  /// Fetch current authenticated user
  Future<User?> _fetchCurrentUser() async {
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    final result = await useCase(const NoParams());

    return result.fold(
      (failure) => null,
      (user) => user,
    );
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(
      LoginParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (user) {
        state = AsyncData(user);
        return true;
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    final useCase = ref.read(logoutUseCaseProvider);
    await useCase(const NoParams());

    state = const AsyncData(null);
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return state.valueOrNull != null;
  }

  /// Get current user
  User? get currentUser {
    return state.valueOrNull;
  }
}

// ========== Derived States ==========

/// Is user authenticated
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull != null;
}

/// Current user
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull;
}

/// Can user write (edit/create)
@riverpod
bool canWrite(CanWriteRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canWrite ?? false;
}

/// Can user delete
@riverpod
bool canDelete(CanDeleteRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canDelete ?? false;
}

/// Is user admin
@riverpod
bool isAdmin(IsAdminRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
}
