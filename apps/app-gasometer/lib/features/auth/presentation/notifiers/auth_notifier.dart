import 'dart:async';

import 'package:core/core.dart' as core show UserEntity, AuthProvider;
import 'package:core/core.dart' hide AuthStatus, AuthState;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/services/auth_rate_limiter.dart';
import '../../../../core/services/gasometer_analytics_service.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/widgets/logout_loading_dialog.dart';
import '../../domain/entities/user_entity.dart' as gasometer_auth;
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../state/auth_state.dart';

part 'auth_notifier.g.dart';

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
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  // Remove late final - use lazy getters instead to prevent re-initialization
  GetCurrentUser? _getCurrentUserInstance;
  WatchAuthState? _watchAuthStateInstance;
  SignInWithEmail? _signInWithEmailInstance;
  SignUpWithEmail? _signUpWithEmailInstance;
  SignInAnonymously? _signInAnonymouslyInstance;
  SignOut? _signOutInstance;
  SendPasswordReset? _sendPasswordResetInstance;
  GasometerAnalyticsService? _analyticsInstance;
  PlatformService? _platformServiceInstance;
  AuthRateLimiter? _rateLimiterInstance;
  EnhancedAccountDeletionService? _enhancedDeletionServiceInstance;

  // Lazy getters to prevent re-initialization
  GetCurrentUser get _getCurrentUser =>
      _getCurrentUserInstance ??= sl<GetCurrentUser>();
  WatchAuthState get _watchAuthState =>
      _watchAuthStateInstance ??= sl<WatchAuthState>();
  SignInWithEmail get _signInWithEmail =>
      _signInWithEmailInstance ??= sl<SignInWithEmail>();
  SignUpWithEmail get _signUpWithEmail =>
      _signUpWithEmailInstance ??= sl<SignUpWithEmail>();
  SignInAnonymously get _signInAnonymously =>
      _signInAnonymouslyInstance ??= sl<SignInAnonymously>();
  SignOut get _signOut =>
      _signOutInstance ??= sl<SignOut>();
  SendPasswordReset get _sendPasswordReset =>
      _sendPasswordResetInstance ??= sl<SendPasswordReset>();
  GasometerAnalyticsService get _analytics =>
      _analyticsInstance ??= sl<GasometerAnalyticsService>();
  PlatformService get _platformService =>
      _platformServiceInstance ??= sl<PlatformService>();
  AuthRateLimiter get _rateLimiter =>
      _rateLimiterInstance ??= sl<AuthRateLimiter>();
  EnhancedAccountDeletionService get _enhancedDeletionService =>
      _enhancedDeletionServiceInstance ??= sl<EnhancedAccountDeletionService>();

  final MonorepoAuthCache _monorepoAuthCache = MonorepoAuthCache();

  StreamSubscription<void>? _authStateSubscription;
  bool _isInLoginAttempt = false;
  bool _isInitialized = false;

  @override
  AuthState build() {
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
        await signInAnonymously();
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
  // AUTHENTICATION METHODS
  // ============================================================================

  /// LOGIN - migrado do AuthProvider
  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );
    _isInLoginAttempt = true; // SECURITY + UX FIX

    try {
      final canAttempt = await _rateLimiter.canAttemptLogin();
      if (!canAttempt) {
        final rateLimitInfo = await _rateLimiter.getRateLimitInfo();
        state = state.copyWith(
          errorMessage: rateLimitInfo.lockoutMessage,
          isLoading: false,
          status: AuthStatus.error,
        );
        _isInLoginAttempt = false;
        await _analytics.logUserAction(
          'login_blocked_rate_limit',
          parameters: {
            'lockout_minutes_remaining':
                rateLimitInfo.lockoutTimeRemainingMinutes,
          },
        );
        return;
      }

      final result = await _signInWithEmail(
        SignInWithEmailParams(email: email, password: password),
      );

      await result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint(
              '🔐 AuthNotifier: Login falhou - Tipo: ${failure.runtimeType}, Mensagem: ${failure.message}',
            );
          }
          await _rateLimiter.recordFailedAttempt();
          final rateLimitInfo = await _rateLimiter.getRateLimitInfo();

          String errorMsg = _mapFailureToMessage(failure);
          if (!rateLimitInfo.canAttemptLogin) {
            errorMsg = rateLimitInfo.lockoutMessage;
          } else if (rateLimitInfo.warningMessage.isNotEmpty) {
            errorMsg += '\n\n${rateLimitInfo.warningMessage}';
          }

          state = state.copyWith(
            errorMessage: errorMsg,
            isLoading: false,
            status: AuthStatus.error,
          );
          _isInLoginAttempt = false; // SECURITY + UX FIX
          await _analytics.logUserAction(
            'login_failed',
            parameters: {
              'method': 'email',
              'failure_type': failure.runtimeType.toString(),
              'attempts_remaining': rateLimitInfo.attemptsRemaining,
              'is_locked': rateLimitInfo.isLocked,
            },
          );
        },
        (user) async {
          await _rateLimiter.recordSuccessfulAttempt();

          final gasometerUser = _convertFromCoreUser(user);

          state = state.copyWith(
            currentUser: gasometerUser,
            isAuthenticated: true,
            isPremium: gasometerUser?.isPremium ?? false,
            isAnonymous: gasometerUser?.isAnonymous ?? false,
            isLoading: false,
            status: AuthStatus.authenticated,
          );
          _isInLoginAttempt = false; // SECURITY + UX FIX
          await _analytics.logLogin('email');
          await _analytics.logUserAction(
            'login_success',
            parameters: {'method': 'email'},
          );

          // 🔄 Trigger sync after successful login
          _triggerPostLoginSync();
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro interno no sistema de login. Tente novamente.',
        isLoading: false,
        status: AuthStatus.error,
      );
      _isInLoginAttempt = false; // SECURITY + UX FIX
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'login_method_error',
      );
    }
  }

  /// REGISTER - migrado do AuthProvider
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );

    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (user) async {
        final gasometerUser = _convertFromCoreUser(user);

        state = state.copyWith(
          currentUser: gasometerUser,
          isAuthenticated: true,
          isPremium: gasometerUser?.isPremium ?? false,
          isAnonymous: gasometerUser?.isAnonymous ?? false,
          isLoading: false,
          status: AuthStatus.authenticated,
        );
        await _analytics.logUserAction(
          'register_success',
          parameters: {'method': 'email'},
        );

        // 🔄 Trigger sync after successful registration
        _triggerPostLoginSync();
      },
    );
  }

  /// SIGN IN ANONYMOUSLY - migrado do AuthProvider
  Future<void> signInAnonymously() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );

    if (kDebugMode) {
      debugPrint('🔐 Iniciando login anônimo...');
    }

    final result = await _signInAnonymously();

    await result.fold(
      (failure) async {
        if (kDebugMode) {
          debugPrint('🔐 Erro no login anônimo: ${failure.message}');
        }
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (user) async {
        final gasometerUser = _convertFromCoreUser(user);

        state = state.copyWith(
          currentUser: gasometerUser,
          isAuthenticated: true,
          isPremium: false,
          isAnonymous: true,
          isLoading: false,
          status: AuthStatus.authenticated,
        );
        await _saveAnonymousPreference();
        await _analytics.logAnonymousSignIn();
        await _analytics.setUserProperties({
          'user_type': 'anonymous',
          'is_premium': 'false',
        });

        if (kDebugMode) {
          debugPrint('🔐 Usuário logado anonimamente');
        }

        // 🔄 Trigger sync after anonymous login (if needed in future)
        // Anonymous users typically don't have cloud data to sync
        // but we trigger anyway for consistency
        _triggerPostLoginSync();
      },
    );
  }

  /// LOGOUT - migrado do AuthProvider
  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    try {
      await _analytics.logLogout();

      final result = await _signOut();

      await result.fold(
        (failure) async {
          state = state.copyWith(
            errorMessage: _mapFailureToMessage(failure),
            isLoading: false,
            status: AuthStatus.error,
          );
        },
        (_) async {
          try {
            await _monorepoAuthCache.clearModuleData('app-gasometer');
            if (kDebugMode) {
              debugPrint('🔐 MonorepoAuthCache limpo para app-gasometer');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Erro ao limpar MonorepoAuthCache: $e');
            }
          }

          // Limpar TODOS os dados locais do app no logout
          try {
            if (kDebugMode) {
              debugPrint('🗑️ Limpando dados locais no logout...');
            }

            final clearResult = await UnifiedSyncManager.instance.clearAppData(
              'gasometer',
            );

            clearResult.fold(
              (failure) {
                if (kDebugMode) {
                  debugPrint(
                    '⚠️ Falha ao limpar dados locais: ${failure.message}',
                  );
                }
              },
              (_) {
                if (kDebugMode) {
                  debugPrint(
                    '✅ Dados locais limpos com sucesso (veículos, abastecimentos, manutenções)',
                  );
                }
              },
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Erro ao limpar dados locais: $e');
            }
          }

          state = state.copyWith(
            currentUser: null,
            isAuthenticated: false,
            isPremium: false,
            isAnonymous: false,
            isLoading: false,
            status: AuthStatus.unauthenticated,
            clearUser: true,
          );

          if (kDebugMode) {
            debugPrint('🔐 Logout realizado com sucesso');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao fazer logout: ${e.toString()}',
        isLoading: false,
        status: AuthStatus.error,
      );
    }
  }

  /// LOGOUT WITH LOADING DIALOG - migrado do AuthProvider
  Future<void> logoutWithLoadingDialog(BuildContext context) async {
    // Store context reference before any async operations
    final navigator = Navigator.of(context);

    try {
      await showLogoutLoading(
        context,
        message: 'Saindo...',
        duration: const Duration(seconds: 2),
      );

      await logout();

      if (kDebugMode) {
        debugPrint('🔐 Logout com loading dialog concluído');
      }
    } catch (e) {
      if (navigator.canPop()) {
        navigator.pop();
      }

      state = state.copyWith(
        errorMessage: 'Erro ao fazer logout: ${e.toString()}',
        status: AuthStatus.error,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'logout_with_dialog_error',
      );
    }
  }

  /// SEND PASSWORD RESET - migrado do AuthProvider
  Future<void> sendPasswordReset(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    final result = await _sendPasswordReset(
      SendPasswordResetParams(email: email),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (_) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  // ============================================================================
  // ACCOUNT DELETION
  // ============================================================================

  /// DELETE ACCOUNT - Enhanced with EnhancedAccountDeletionService
  Future<void> deleteAccount({String? currentPassword}) async {
    if (state.currentUser == null) {
      state = state.copyWith(
        errorMessage: 'Nenhum usuário autenticado',
        isLoading: false,
        status: AuthStatus.error,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    try {
      final result = await _enhancedDeletionService.deleteAccount(
        password: currentPassword ?? '',
        userId: state.currentUser!.id,
        isAnonymous: state.isAnonymous,
      );

      result.fold(
        (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
            status: AuthStatus.error,
          );
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _performPostDeletionCleanup();
          } else {
            state = state.copyWith(
              errorMessage: deletionResult.userMessage,
              isLoading: false,
              status: AuthStatus.error,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoading: false,
        status: AuthStatus.error,
      );
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'delete_account_error',
      );
    }
  }

  void _performPostDeletionCleanup() {
    state = state.copyWith(
      currentUser: null,
      isAuthenticated: false,
      isPremium: false,
      isAnonymous: false,
      isLoading: false,
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );

    if (kDebugMode) {
      debugPrint('🔐 Conta deletada com sucesso');
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
    BackgroundSyncManager.instance.triggerSync(
      'gasometer',
      force: true, // Force immediate sync
    ).then((_) {
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
      await signInAnonymously();
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
