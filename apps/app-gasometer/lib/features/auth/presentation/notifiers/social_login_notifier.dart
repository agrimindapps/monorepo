import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_usecase_providers.dart';
import 'social_login_state.dart';

part 'social_login_notifier.g.dart';

/// Notifier Riverpod para gerenciar social login
///
/// Suporta autenticação via:
/// - Google Sign-In
/// - Apple Sign-In
/// - Facebook Sign-In
///
/// Utiliza Riverpod para injeção de dependências do AuthRepository
@riverpod
class SocialLoginNotifier extends _$SocialLoginNotifier {
  late final AuthRepository _authRepository;

  @override
  SocialLoginState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return const SocialLoginState.initial();
  }

  /// Sign in com Google
  ///
  /// Retorna `true` se o login foi bem-sucedido, `false` caso contrário
  Future<bool> signInWithGoogle() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Google Sign In...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.google);

    try {
      final result = await _authRepository.signInWithGoogle();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Google Sign In failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.google,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Google Sign In successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.google);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Google Sign In: $e');
      }
      state = const SocialLoginState.error(
        'Erro inesperado no login com Google',
        SocialLoginMethod.google,
      );
      return false;
    }
  }

  /// Sign in com Apple
  ///
  /// Retorna `true` se o login foi bem-sucedido, `false` caso contrário
  Future<bool> signInWithApple() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Apple Sign In...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.apple);

    try {
      final result = await _authRepository.signInWithApple();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Apple Sign In failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.apple,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Apple Sign In successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.apple);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Apple Sign In: $e');
      }
      state = const SocialLoginState.error(
        'Erro inesperado no login com Apple',
        SocialLoginMethod.apple,
      );
      return false;
    }
  }

  /// Sign in com Facebook
  ///
  /// Retorna `true` se o login foi bem-sucedido, `false` caso contrário
  Future<bool> signInWithFacebook() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Attempting Facebook Sign In...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.facebook);

    try {
      final result = await _authRepository.signInWithFacebook();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Facebook Sign In failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.facebook,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Facebook Sign In successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.facebook);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SocialLogin: Unexpected error in Facebook Sign In: $e');
      }
      state = const SocialLoginState.error(
        'Erro inesperado no login com Facebook',
        SocialLoginMethod.facebook,
      );
      return false;
    }
  }

  /// Link conta anônima com Google
  ///
  /// Converte uma conta anônima em conta permanente usando Google
  /// Retorna `true` se a conversão foi bem-sucedida, `false` caso contrário
  Future<bool> linkAnonymousWithGoogle() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Linking anonymous account with Google...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.google);

    try {
      final result = await _authRepository.linkAnonymousWithGoogle();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Link with Google failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.google,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Link with Google successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.google);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ SocialLogin: Unexpected error linking with Google: $e',
        );
      }
      state = const SocialLoginState.error(
        'Erro ao vincular conta com Google',
        SocialLoginMethod.google,
      );
      return false;
    }
  }

  /// Link conta anônima com Apple
  ///
  /// Converte uma conta anônima em conta permanente usando Apple
  /// Retorna `true` se a conversão foi bem-sucedida, `false` caso contrário
  Future<bool> linkAnonymousWithApple() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Linking anonymous account with Apple...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.apple);

    try {
      final result = await _authRepository.linkAnonymousWithApple();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Link with Apple failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.apple,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Link with Apple successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.apple);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ SocialLogin: Unexpected error linking with Apple: $e',
        );
      }
      state = const SocialLoginState.error(
        'Erro ao vincular conta com Apple',
        SocialLoginMethod.apple,
      );
      return false;
    }
  }

  /// Link conta anônima com Facebook
  ///
  /// Converte uma conta anônima em conta permanente usando Facebook
  /// Retorna `true` se a conversão foi bem-sucedida, `false` caso contrário
  Future<bool> linkAnonymousWithFacebook() async {
    if (kDebugMode) {
      debugPrint('🔄 SocialLogin: Linking anonymous account with Facebook...');
    }

    state = const SocialLoginState.loading(SocialLoginMethod.facebook);

    try {
      final result = await _authRepository.linkAnonymousWithFacebook();

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ SocialLogin: Link with Facebook failed - ${failure.message}',
            );
          }
          state = SocialLoginState.error(
            failure.message,
            SocialLoginMethod.facebook,
          );
          return false;
        },
        (user) {
          if (kDebugMode) {
            debugPrint(
              '✅ SocialLogin: Link with Facebook successful - User: ${user.id}',
            );
          }
          state = const SocialLoginState.success(SocialLoginMethod.facebook);
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ SocialLogin: Unexpected error linking with Facebook: $e',
        );
      }
      state = const SocialLoginState.error(
        'Erro ao vincular conta com Facebook',
        SocialLoginMethod.facebook,
      );
      return false;
    }
  }

  /// Limpa erro mantendo estado atual
  void clearError() {
    state = state.clearError();
  }

  /// Reseta para estado inicial
  void reset() {
    state = const SocialLoginState.initial();
  }
}
