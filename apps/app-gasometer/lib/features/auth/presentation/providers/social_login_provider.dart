import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';

/// Estado do social login
class SocialLoginState {
  const SocialLoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  SocialLoginState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SocialLoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para gerenciar social login
class SocialLoginNotifier extends StateNotifier<SocialLoginState> {
  SocialLoginNotifier(this._authRepository) : super(const SocialLoginState());

  final AuthRepository _authRepository;

  /// Sign in com Google
  Future<bool> signInWithGoogle() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Google Sign In...');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authRepository.signInWithGoogle();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ SocialLogin: Google Sign In failed - ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint('✅ SocialLogin: Google Sign In successful - User: ${user.id}');
          }
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Google Sign In: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado no login com Google',
      );
      return false;
    }
  }

  /// Sign in com Apple
  Future<bool> signInWithApple() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Apple Sign In...');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authRepository.signInWithApple();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ SocialLogin: Apple Sign In failed - ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint('✅ SocialLogin: Apple Sign In successful - User: ${user.id}');
          }
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Apple Sign In: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado no login com Apple',
      );
      return false;
    }
  }

  /// Sign in com Facebook
  Future<bool> signInWithFacebook() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Facebook Sign In...');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authRepository.signInWithFacebook();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ SocialLogin: Facebook Sign In failed - ${failure.message}');
          }
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint('✅ SocialLogin: Facebook Sign In successful - User: ${user.id}');
          }
          state = state.copyWith(isLoading: false);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Facebook Sign In: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado no login com Facebook',
      );
      return false;
    }
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider para social login
final socialLoginProvider =
    StateNotifierProvider<SocialLoginNotifier, SocialLoginState>((ref) {
  // TODO: Replace with proper dependency injection when migrating to Riverpod fully
  // For now, we need to get AuthRepository instance
  throw UnimplementedError(
    'socialLoginProvider needs AuthRepository dependency injection setup',
  );
});
