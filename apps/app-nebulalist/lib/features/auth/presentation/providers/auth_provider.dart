import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

/// Auth state model using Freezed for immutability
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    UserEntity? currentUser,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool isInitialized,
    AuthOperation? currentOperation,
  }) = _AuthState;

  factory AuthState.initial() => const AuthState();
}

/// Current authentication operation being performed
enum AuthOperation {
  signIn,
  signUp,
  logout,
  resetPassword,
}

// Provider for FirebaseAuthService (from core package)
@riverpod
IAuthRepository authRepository(Ref ref) {
  return FirebaseAuthService();
}

// Provider for FirebaseAnalyticsService (from core package)
@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return FirebaseAnalyticsService();
}

// Provider for use cases
@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
SignUpUseCase signUpUseCase(Ref ref) {
  return SignUpUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(analyticsRepositoryProvider),
  );
}

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
}

/// Main auth provider using Riverpod NotifierProvider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthStateNotifier _authStateNotifier;

  @override
  AuthState build() {
    _authStateNotifier = AuthStateNotifier.instance;

    // Listen to auth state changes from Firebase
    ref.listen(authRepositoryProvider, (previous, next) {
      next.currentUser.listen((user) {
        _authStateNotifier.updateUser(user);
        state = state.copyWith(
          currentUser: user,
          isInitialized: true,
        );
      });
    });

    // Initialize auth state
    _initializeAuth();

    return AuthState.initial();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final isLoggedIn = await repository.isLoggedIn;

      if (isLoggedIn) {
        // User stream will update the state automatically
        debugPrint('AuthNotifier: User is logged in, listening to stream');
      }

      state = state.copyWith(isInitialized: true);
      _authStateNotifier.updateInitializationStatus(true);
    } catch (e) {
      debugPrint('AuthNotifier: Error initializing auth: $e');
      state = state.copyWith(
        isInitialized: true,
        errorMessage: 'Erro ao inicializar autenticação',
      );
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.signIn,
    );

    final result = await ref.read(loginUseCaseProvider).call(
          LoginParams(email: email, password: password),
        );

    result.fold(
      (failure) {
        debugPrint('AuthNotifier: Login failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          currentOperation: null,
        );
      },
      (user) {
        debugPrint('AuthNotifier: Login successful - ${user.email}');
        _authStateNotifier.updateUser(user);
        state = state.copyWith(
          isLoading: false,
          currentUser: user,
          errorMessage: null,
          currentOperation: null,
        );
      },
    );
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.signUp,
    );

    final result = await ref.read(signUpUseCaseProvider).call(
          SignUpParams(
            email: email,
            password: password,
            displayName: displayName,
          ),
        );

    result.fold(
      (failure) {
        debugPrint('AuthNotifier: Signup failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          currentOperation: null,
        );
      },
      (user) {
        debugPrint('AuthNotifier: Signup successful - ${user.email}');
        _authStateNotifier.updateUser(user);
        state = state.copyWith(
          isLoading: false,
          currentUser: user,
          errorMessage: null,
          currentOperation: null,
        );
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.logout,
    );

    final result = await ref.read(logoutUseCaseProvider).call();

    result.fold(
      (failure) {
        debugPrint('AuthNotifier: Logout failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          currentOperation: null,
        );
      },
      (_) {
        debugPrint('AuthNotifier: Logout successful');
        _authStateNotifier.reset();
        state = AuthState.initial().copyWith(isInitialized: true);
      },
    );
  }

  /// Send password reset email
  Future<void> resetPassword({
    required String email,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.resetPassword,
    );

    final result = await ref.read(resetPasswordUseCaseProvider).call(
          ResetPasswordParams(email: email),
        );

    result.fold(
      (failure) {
        debugPrint('AuthNotifier: Reset password failed - ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          currentOperation: null,
        );
      },
      (_) {
        debugPrint('AuthNotifier: Password reset email sent');
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          currentOperation: null,
        );
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
