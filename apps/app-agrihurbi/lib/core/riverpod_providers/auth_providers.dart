import 'package:core/core.dart' hide Provider, StateNotifier, Consumer, ProviderContainer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection_container.dart' as di;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/login_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/logout_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/refresh_user_usecase.dart' as app_auth;
import '../../features/auth/domain/usecases/register_usecase.dart' as app_auth;

// === AUTH STATE ===

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

// === AUTH NOTIFIER ===

/// StateNotifier para autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._refreshUserUseCase,
  ) : super(const AuthState()) {
    _initialize();
  }

  final app_auth.LoginUseCase _loginUseCase;
  final app_auth.RegisterUseCase _registerUseCase;
  final app_auth.LogoutUseCase _logoutUseCase;
  final app_auth.GetCurrentUserUseCase _getCurrentUserUseCase;
  final app_auth.RefreshUserUseCase _refreshUserUseCase;

  Future<void> _initialize() async {
    await getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getCurrentUserUseCase(const app_auth.GetCurrentUserParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          user: null,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginUseCase(app_auth.LoginParams(
      email: email,
      password: password,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
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

    final result = await _registerUseCase(app_auth.RegisterParams(
      email: email,
      password: password,
      name: name,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isLoggedIn: true,
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _logoutUseCase(const app_auth.LogoutParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          user: null,
          isLoading: false,
          isLoggedIn: false,
        );
      },
    );
  }

  Future<void> refreshUser() async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _refreshUserUseCase(const app_auth.RefreshUserParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// === PROVIDERS ===

/// Provider para autenticação
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    di.getIt<app_auth.LoginUseCase>(),
    di.getIt<app_auth.RegisterUseCase>(),
    di.getIt<app_auth.LogoutUseCase>(),
    di.getIt<app_auth.GetCurrentUserUseCase>(),
    di.getIt<app_auth.RefreshUserUseCase>(),
  );
});

/// Provider derivado para verificar se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider derivado para obter o usuário atual
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});