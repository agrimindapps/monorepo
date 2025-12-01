import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as app_auth;
import '../../features/auth/domain/usecases/login_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/logout_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/refresh_user_usecase.dart'
    as app_auth;
import '../../features/auth/domain/usecases/register_usecase.dart' as app_auth;
import '../../features/auth/presentation/providers/auth_di_providers.dart';

part 'auth_providers.g.dart';

/// State para autenticação
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage,
  });

  final UserEntity? user;
  final bool isLoading;
  final bool isLoggedIn;
  final String? errorMessage;

  bool get isAuthenticated => isLoggedIn && user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para autenticação
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final app_auth.LoginUseCase _loginUseCase;
  late final app_auth.RegisterUseCase _registerUseCase;
  late final app_auth.LogoutUseCase _logoutUseCase;
  late final app_auth.GetCurrentUserUseCase _getCurrentUserUseCase;
  late final app_auth.RefreshUserUseCase _refreshUserUseCase;

  @override
  AuthState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _registerUseCase = ref.watch(registerUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
    _refreshUserUseCase = ref.watch(refreshUserUseCaseProvider);
    _initialize();

    return const AuthState();
  }

  Future<void> _initialize() async {
    await getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getCurrentUserUseCase(
      const app_auth.GetCurrentUserParams(),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, isLoggedIn: false, user: null);
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false, isLoggedIn: true);
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginUseCase(
      app_auth.LoginParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false, isLoggedIn: true);
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _registerUseCase(
      app_auth.RegisterParams(email: email, password: password, name: name),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false, isLoggedIn: true);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _logoutUseCase(const app_auth.LogoutParams());

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(user: null, isLoading: false, isLoggedIn: false);
      },
    );
  }

  Future<void> refreshUser() async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _refreshUserUseCase(
      const app_auth.RefreshUserParams(),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider derivado para verificar se o usuário está autenticado
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).isAuthenticated;
}

/// Provider derivado para obter o usuário atual
@riverpod
UserEntity? currentUser(Ref ref) {
  return ref.watch(authProvider).user;
}
