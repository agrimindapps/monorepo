import 'dart:async';

import 'package:core/core.dart' as core show UserEntity, AuthProvider;
import 'package:core/core.dart' hide AuthStatus, AuthState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../../../core/services/platform/platform_service.dart';
import '../../../../core/widgets/logout_loading_dialog.dart';
import '../../../../features/auth/domain/services/auth_rate_limiter.dart';
import '../../domain/entities/user_entity.dart' as gasometer_auth;
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../providers/auth_usecase_providers.dart';
import '../state/auth_state.dart';

part 'auth_notifier.g.dart';
part 'auth_notifier_login.dart';
part 'auth_notifier_register.dart';
part 'auth_notifier_logout.dart';
part 'auth_notifier_account.dart';

/// AuthNotifier - Riverpod v2 com code generation
///
/// REFATORADO para aplicar SRP (Single Responsibility Principle)
///
/// Responsabilidades (CORE AUTH APENAS):
/// - Login (email/password, anonymous)
/// - Logout
/// - Register/SignUp
/// - Password recovery
/// - Auth state persistence
/// - Session management
/// - Rate limiting
///
/// RESPONSABILIDADES MOVIDAS:
/// - Profile management → profile_notifier.dart (updateProfile, avatar)
/// - Data sync → sync_notifier.dart (background sync, UnifiedSync)
///
/// Reduzido de 953 linhas para ~500 linhas (core auth apenas)
@riverpod
class Auth extends _$Auth {
  late final GetCurrentUser _getCurrentUser;
  late final WatchAuthState _watchAuthState;
  late final SignInWithEmail _signInWithEmail;
  late final SignUpWithEmail _signUpWithEmail;
  late final SignInAnonymously _signInAnonymously;
  late final SignOut _signOut;
  late final SendPasswordReset _sendPasswordReset;
  late final GasometerAnalyticsService _analytics;
  late final PlatformService _platformService;
  late final AuthRateLimiter _rateLimiter;
  late final EnhancedAccountDeletionService _enhancedDeletionService;

  final MonorepoAuthCache _monorepoAuthCache = MonorepoAuthCache();

  StreamSubscription<void>? _authStateSubscription;
  bool _isInLoginAttempt = false;
  bool _isInitialized = false;

  @override
  AuthState build() {
    // Initialize dependencies
    _getCurrentUser = ref.watch(getCurrentUserProvider);
    _watchAuthState = ref.watch(watchAuthStateProvider);
    _signInWithEmail = ref.watch(signInWithEmailProvider);
    _signUpWithEmail = ref.watch(signUpWithEmailProvider);
    _signInAnonymously = ref.watch(signInAnonymouslyProvider);
    _signOut = ref.watch(signOutProvider);
    _sendPasswordReset = ref.watch(sendPasswordResetProvider);
    _analytics = ref.watch(gasometerAnalyticsServiceProvider);
    _platformService = ref.watch(platformServiceProvider);
    _rateLimiter = ref.watch(authRateLimiterProvider);
    _enhancedDeletionService =
        ref.watch(enhancedAccountDeletionServiceProvider);

    // Prevent double initialization
    if (_isInitialized) {
      return state;
    }

    _isInitialized = true;
    _initializeAuthState();
    _initializeMonorepoAuthCache();
    ref.onDispose(() {
      _authStateSubscription?.cancel();
      _isInitialized = false;
    });

    return const AuthState.initial();
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize MonorepoAuthCache for cross-module security
  Future<void> _initializeMonorepoAuthCache() async {
    try {
      await _monorepoAuthCache.initialize();
      if (kDebugMode) {
        debugPrint('🔐 MonorepoAuthCache inicializado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erro ao inicializar MonorepoAuthCache: $e');
      }
    }
  }

  Future<void> _handleUserAuthenticated(core.UserEntity? user) async {
    if (kDebugMode) {
      debugPrint('🔐 Usuário obtido: ${user?.id ?? 'null'}');
    }

    final gasometerUser = _convertFromCoreUser(user);

    if (user != null) {
      if (kDebugMode) {
        debugPrint('🔐 Configurando sessão para usuário existente');
      }
      await _setupUserSession(gasometerUser);

      state = state.copyWith(
        currentUser: gasometerUser,
        isAuthenticated: true,
        isPremium: gasometerUser?.isPremium ?? false,
        isAnonymous: gasometerUser?.isAnonymous ?? false,
        isInitialized: true,
        status: AuthStatus.authenticated,
      );
    } else {
      final shouldUseAnonymous = await shouldUseAnonymousMode();
      if (kDebugMode) {
        debugPrint(
          '🔐 Usuário nulo. Deve usar anônimo? $shouldUseAnonymous (Platform: web=${_platformService.isWeb}, mobile=${_platformService.isMobile}, isInLoginAttempt=$_isInLoginAttempt)',
        );
      }

      state = state.copyWith(isInitialized: true);

      if (shouldUseAnonymous) {
        if (kDebugMode) {
          debugPrint('🔐 Iniciando modo anônimo automaticamente');
        }
        await loginAnonymously();
        return;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '🔐 AuthState inicializado com sucesso. Usuário autenticado: ${state.isAuthenticated}',
      );
    }
  }

  Future<void> _initializeAuthState() async {
    if (kDebugMode) {
      debugPrint('🔐 Iniciando inicialização do AuthState...');
    }

    try {
      if (kDebugMode) {
        debugPrint('🔐 Obtendo usuário atual...');
      }

      final result = await _getCurrentUser();
      await result.fold((failure) {
        if (kDebugMode) {
          debugPrint('🔐 Falha ao obter usuário: ${failure.message}');
        }
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isInitialized: true,
          status: AuthStatus.error,
        );
      }, (user) => _handleUserAuthenticated(user));
      _authStateSubscription = _watchAuthState().listen((result) {
        result.fold(
          (failure) {
            state = state.copyWith(
              errorMessage: _mapFailureToMessage(failure),
              status: AuthStatus.error,
            );
          },
          (user) async {
            final gasometerUser = _convertFromCoreUser(user);

            if (user != null) {
              await _setupUserSession(gasometerUser);
              state = state.copyWith(
                currentUser: gasometerUser,
                isAuthenticated: true,
                isPremium: gasometerUser?.isPremium ?? false,
                isAnonymous: gasometerUser?.isAnonymous ?? false,
                status: AuthStatus.authenticated,
              );
            } else {
              state = state.copyWith(
                currentUser: null,
                isAuthenticated: false,
                isPremium: false,
                isAnonymous: false,
                status: AuthStatus.unauthenticated,
                clearUser: true,
              );
            }
          },
        );
      });
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar autenticação: $e',
        isInitialized: true,
        status: AuthStatus.error,
      );
    }
  }

  Future<void> _setupUserSession(gasometer_auth.UserEntity? user) async {
    if (user == null) return;
    try {
      final isAnonymous = user.isAnonymous;
      if (isAnonymous) {
        if (kDebugMode) {
          debugPrint('🔐 Usuário anônimo logado');
        }
        return;
      }
      await _analytics.setUserId(user.id);
      final isPremium = user.isPremium;
      await _analytics.setUserProperties({
        'user_type': isAnonymous ? 'anonymous' : 'authenticated',
        'is_premium': isPremium.toString(),
      });
    } catch (e) {
      debugPrint('Erro ao configurar sessão do usuário: $e');
    }
  }

  // ============================================================================
  // SYNC INTEGRATION
  // ============================================================================

  /// Trigger sync after successful login
  /// Ensures user data is fetched from Firestore immediately after authentication
  void _triggerPostLoginSync() {
    // Fire-and-forget: não bloqueia o login
    // BackgroundSyncManager executará sync em background
    BackgroundSyncManager.instance
        .triggerSync(
      'gasometer',
      force: true, // Force immediate sync
    )
        .then((_) {
      if (kDebugMode) {
        debugPrint('🔄 Post-login sync triggered successfully');
      }
    }).catchError((Object e) {
      if (kDebugMode) {
        debugPrint('⚠️ Post-login sync failed (non-blocking): $e');
      }
      // Não propagar erro - sync failure não deve impedir login
    });
  }

  // ============================================================================
  // HELPERS & UTILITIES
  // ============================================================================

  Future<void> _saveAnonymousPreference() async {
    if (kDebugMode) {
      debugPrint('🔐 Preferência de modo anônimo salva');
    }
  }

  Future<bool> shouldUseAnonymousMode() async {
    try {
      if (_isInLoginAttempt) {
        if (kDebugMode) {
          debugPrint('🔐 Não usar anônimo - tentativa de login em andamento');
        }
        return false;
      }
      return _platformService.shouldUseAnonymousByDefault;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar modo anônimo: $e');
      }
      return _platformService.shouldUseAnonymousByDefault;
    }
  }

  Future<void> initializeAnonymousIfNeeded() async {
    if (!state.isAuthenticated && await shouldUseAnonymousMode()) {
      await loginAnonymously();
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Rate limiting methods
  Future<AuthRateLimitInfo> getRateLimitInfo() =>
      _rateLimiter.getRateLimitInfo();

  Future<bool> canAttemptLogin() => _rateLimiter.canAttemptLogin();

  Future<void> resetRateLimit() => _rateLimiter.resetRateLimit();

  /// Refresh user from external notifier (e.g., ProfileNotifier)
  void refreshUser(gasometer_auth.UserEntity? user) {
    if (user != null) {
      state = state.copyWith(currentUser: user);
    }
  }

  // ============================================================================
  // CONVERSION UTILITIES
  // ============================================================================

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Convert core UserEntity to gasometer UserEntity
  gasometer_auth.UserEntity? _convertFromCoreUser(core.UserEntity? coreUser) {
    if (coreUser == null) return null;
    return gasometer_auth.UserEntity(
      id: coreUser.id,
      email: coreUser.email.isEmpty ? null : coreUser.email,
      displayName: coreUser.displayName.isEmpty ? null : coreUser.displayName,
      photoUrl: coreUser.photoUrl,
      avatarBase64: null, // Core doesn't have local avatar support
      type: _mapAuthProviderToUserType(coreUser.provider),
      isEmailVerified: coreUser.isEmailVerified,
      createdAt: coreUser.createdAt ?? DateTime.now(),
      lastSignInAt: coreUser.lastLoginAt,
      metadata: {
        'provider': coreUser.provider.name,
        'phone': coreUser.phone ?? '',
        'isActive': coreUser.isActive,
      },
    );
  }

  /// Map AuthProvider to UserType
  gasometer_auth.UserType _mapAuthProviderToUserType(
    core.AuthProvider provider,
  ) {
    switch (provider) {
      case core.AuthProvider.anonymous:
        return gasometer_auth.UserType.anonymous;
      case core.AuthProvider.email:
      case core.AuthProvider.google:
      case core.AuthProvider.apple:
      case core.AuthProvider.facebook:
        return gasometer_auth.UserType.registered;
    }
  }
}
