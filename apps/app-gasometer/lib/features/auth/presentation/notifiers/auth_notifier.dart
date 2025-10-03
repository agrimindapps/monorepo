import 'dart:async';

import 'package:core/core.dart' hide AuthStatus, AuthState;
import 'package:core/core.dart' as core show UserEntity, AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../../../core/di/injection_container_modular.dart';
import '../../../../core/services/gasometer_analytics_service.dart';
import '../../../../core/services/auth_rate_limiter.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/widgets/logout_loading_dialog.dart';
import '../state/auth_state.dart';

part 'auth_notifier.g.dart';

/// AuthNotifier - Riverpod v2 com code generation
///
/// Gerencia todo o estado de autenticação do app-gasometer:
/// - Login (email/password, anonymous)
/// - Logout
/// - Register/SignUp
/// - Password recovery
/// - Token refresh
/// - Auth state persistence
/// - User data management
///
/// Migrado de StateNotifier para Notifier<AuthState> (Riverpod v2)
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  // Use cases
  late final GetCurrentUser _getCurrentUser;
  late final WatchAuthState _watchAuthState;
  late final SignInWithEmail _signInWithEmail;
  late final SignUpWithEmail _signUpWithEmail;
  late final SignInAnonymously _signInAnonymously;
  late final SignOut _signOut;
  late final UpdateProfile _updateProfile;
  late final SendPasswordReset _sendPasswordReset;

  // Services
  late final GasometerAnalyticsService _analytics;
  late final PlatformService _platformService;
  late final AuthRateLimiter _rateLimiter;
  late final AuthLocalDataSource _authLocalDataSource;
  late final EnhancedAccountDeletionService _enhancedDeletionService;

  // MonorepoAuthCache instance for cross-module security
  final MonorepoAuthCache _monorepoAuthCache = MonorepoAuthCache();

  StreamSubscription<void>? _authStateSubscription;

  // SECURITY + UX FIX: Flag to prevent automatic anonymous login during active login attempts
  bool _isInLoginAttempt = false;

  @override
  AuthState build() {
    // Inject dependencies via GetIt
    _getCurrentUser = sl<GetCurrentUser>();
    _watchAuthState = sl<WatchAuthState>();
    _signInWithEmail = sl<SignInWithEmail>();
    _signUpWithEmail = sl<SignUpWithEmail>();
    _signInAnonymously = sl<SignInAnonymously>();
    _signOut = sl<SignOut>();
    _updateProfile = sl<UpdateProfile>();
    _sendPasswordReset = sl<SendPasswordReset>();
    _analytics = sl<GasometerAnalyticsService>();
    _platformService = sl<PlatformService>();
    _rateLimiter = sl<AuthRateLimiter>();
    _authLocalDataSource = sl<AuthLocalDataSource>();
    _enhancedDeletionService = sl<EnhancedAccountDeletionService>();

    // Initialize auth state
    // Note: These are async but we don't await in build()
    // The state will be updated asynchronously
    _initializeAuthState();
    _initializeMonorepoAuthCache();

    // Cleanup on dispose
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return const AuthState.initial();
  }

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

  Future<void> _initializeAuthState() async {
    if (kDebugMode) {
      debugPrint('🔐 Iniciando inicialização do AuthState...');
    }

    try {
      // Get current user first
      if (kDebugMode) {
        debugPrint('🔐 Obtendo usuário atual...');
      }

      final result = await _getCurrentUser();
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('🔐 Falha ao obter usuário: ${failure.message}');
          }
          state = state.copyWith(
            errorMessage: _mapFailureToMessage(failure),
            isInitialized: true,
            status: AuthStatus.error,
          );
        },
        (user) async {
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
            // If no user and should use anonymous mode, initialize anonymously
            final shouldUseAnonymous = await shouldUseAnonymousMode();
            if (kDebugMode) {
              debugPrint(
                  '🔐 Usuário nulo. Deve usar anônimo? $shouldUseAnonymous (Platform: web=${_platformService.isWeb}, mobile=${_platformService.isMobile}, isInLoginAttempt=$_isInLoginAttempt)');
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
                '🔐 AuthState inicializado com sucesso. Usuário autenticado: ${state.isAuthenticated}');
          }
        },
      );

      // Watch for auth state changes
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

  Future<void> _setupUserSession(UserEntity? user) async {
    if (user == null) return;
    try {
      if (user.isAnonymous) {
        if (kDebugMode) {
          debugPrint('🔐 Usuário anônimo logado');
        }
        return;
      }

      // For registered users, set up analytics and check premium
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties({
        'user_type': user.isAnonymous ? 'anonymous' : 'authenticated',
        'is_premium': user.isPremium.toString(),
      });
    } catch (e) {
      debugPrint('Erro ao configurar sessão do usuário: $e');
    }
  }

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
      // Verifica rate limiting antes de tentar login
      final canAttempt = await _rateLimiter.canAttemptLogin();
      if (!canAttempt) {
        final rateLimitInfo = await _rateLimiter.getRateLimitInfo();
        state = state.copyWith(
          errorMessage: rateLimitInfo.lockoutMessage,
          isLoading: false,
          status: AuthStatus.error,
        );
        _isInLoginAttempt = false;

        // Log tentativa bloqueada
        await _analytics.logUserAction('login_blocked_rate_limit', parameters: {
          'lockout_minutes_remaining': rateLimitInfo.lockoutTimeRemainingMinutes,
        });
        return;
      }

      final result = await _signInWithEmail(SignInWithEmailParams(
        email: email,
        password: password,
      ));

      await result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint(
                '🔐 AuthNotifier: Login falhou - Tipo: ${failure.runtimeType}, Mensagem: ${failure.message}');
          }

          // Registra tentativa falhada no rate limiter
          await _rateLimiter.recordFailedAttempt();

          // Obter informações atualizadas do rate limiter
          final rateLimitInfo = await _rateLimiter.getRateLimitInfo();

          String errorMsg = _mapFailureToMessage(failure);

          // Adiciona aviso de rate limiting se aplicável
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

          // Log analytics para tentativa falhada
          await _analytics.logUserAction('login_failed', parameters: {
            'method': 'email',
            'failure_type': failure.runtimeType.toString(),
            'attempts_remaining': rateLimitInfo.attemptsRemaining,
            'is_locked': rateLimitInfo.isLocked,
          });
        },
        (user) async {
          // Registra tentativa bem-sucedida (limpa rate limiting)
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

          // Log analytics
          await _analytics.logLogin('email');
          await _analytics.logUserAction('login_success', parameters: {
            'method': 'email',
          });
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro interno no sistema de login. Tente novamente.',
        isLoading: false,
        status: AuthStatus.error,
      );
      _isInLoginAttempt = false; // SECURITY + UX FIX

      // Log erro inesperado
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'login_method_error',
      );
    }
  }

  /// REGISTER - migrado do AuthProvider
  Future<void> register(String email, String password, String displayName) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      status: AuthStatus.authenticating,
      clearError: true,
    );

    final result = await _signUpWithEmail(SignUpWithEmailParams(
      email: email,
      password: password,
      displayName: displayName,
    ));

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

        // Log analytics
        await _analytics.logUserAction('register_success', parameters: {
          'method': 'email',
        });
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

        // Salvar preferência de modo anônimo
        await _saveAnonymousPreference();

        // Log analytics para modo anônimo
        await _analytics.logAnonymousSignIn();
        await _analytics.setUserProperties({
          'user_type': 'anonymous',
          'is_premium': 'false',
        });

        if (kDebugMode) {
          debugPrint('🔐 Usuário logado anonimamente');
        }
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
      // Log analytics antes do logout
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
          // SECURITY FIX: Clear cross-module cache to prevent contamination
          try {
            await _monorepoAuthCache.clearModuleData('app-gasometer');
            if (kDebugMode) {
              debugPrint('🔐 MonorepoAuthCache limpo para app-gasometer');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Erro ao limpar MonorepoAuthCache: $e');
            }
            // Não falha o logout se houver erro na limpeza do cache
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
    try {
      // Mostrar o dialog de loading
      showLogoutLoading(
        context,
        message: 'Saindo...',
        duration: const Duration(seconds: 2),
      );

      // Executar logout em paralelo com o dialog
      await logout();

      if (kDebugMode) {
        debugPrint('🔐 Logout com loading dialog concluído');
      }
    } catch (e) {
      // Fechar dialog se houver erro
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
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

    final result = await _sendPasswordReset(SendPasswordResetParams(email: email));

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

  /// UPDATE PROFILE - migrado do AuthProvider
  Future<void> updateUserProfile({String? displayName, String? photoUrl}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearError: true,
    );

    final result = await _updateProfile(UpdateProfileParams(
      displayName: displayName,
      photoUrl: photoUrl,
    ));

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: _mapFailureToMessage(failure),
          isLoading: false,
          status: AuthStatus.error,
        );
      },
      (updatedUser) {
        final gasometerUser = _convertFromCoreUser(updatedUser);
        state = state.copyWith(
          currentUser: gasometerUser,
          isLoading: false,
        );
      },
    );
  }

  /// UPDATE AVATAR - migrado do AuthProvider
  Future<bool> updateAvatar(String avatarBase64) async {
    try {
      if (state.currentUser == null) return false;

      // Update user with new avatar
      final updatedUser = state.currentUser!.copyWith(avatarBase64: avatarBase64);

      // Persist the avatar locally through the auth data source
      await _saveUserLocallyWithAvatar(updatedUser);

      state = state.copyWith(currentUser: updatedUser);

      // Log avatar update
      await _analytics.logUserAction('avatar_updated', parameters: {
        'avatar_size_kb': (avatarBase64.length * 3 ~/ 4 / 1024).toString(),
        'user_type': state.currentUser!.type.toString(),
      });

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao salvar avatar: ${e.toString()}',
        status: AuthStatus.error,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_update_error',
      );

      return false;
    }
  }

  /// REMOVE AVATAR - migrado do AuthProvider
  Future<bool> removeAvatar() async {
    try {
      if (state.currentUser == null) return false;

      // Update user removing avatar
      final updatedUser = state.currentUser!.copyWith(avatarBase64: null);

      // Persist the changes locally
      await _saveUserLocallyWithAvatar(updatedUser);

      state = state.copyWith(currentUser: updatedUser);

      // Log avatar removal
      await _analytics.logUserAction('avatar_removed', parameters: {
        'user_type': state.currentUser!.type.toString(),
      });

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao remover avatar: ${e.toString()}',
        status: AuthStatus.error,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_remove_error',
      );

      return false;
    }
  }

  /// Helper method to save user data locally including avatar
  Future<void> _saveUserLocallyWithAvatar(UserEntity user) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Salvando dados do usuário localmente com avatar');
      }

      // Convert gasometer UserEntity to core UserEntity for storage
      final coreUser = _convertToCore(user);
      await _authLocalDataSource.cacheUser(coreUser);
    } catch (e) {
      throw Exception('Falha ao salvar dados do usuário localmente: $e');
    }
  }

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
      // Use Enhanced Account Deletion Service
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
            // Success - perform cleanup
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

      // Log unexpected error
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

  Future<void> _saveAnonymousPreference() async {
    // Anonymous preference is now handled by the auth data source
    if (kDebugMode) {
      debugPrint('🔐 Preferência de modo anônimo salva');
    }
  }

  Future<bool> shouldUseAnonymousMode() async {
    try {
      // SECURITY + UX FIX: Don't use anonymous mode if we're in the middle of a login attempt
      if (_isInLoginAttempt) {
        if (kDebugMode) {
          debugPrint('🔐 Não usar anônimo - tentativa de login em andamento');
        }
        return false;
      }

      // Use platform service to determine if anonymous mode should be used by default
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

  /// LOGIN WITH SYNC - migrado do AuthProvider
  Future<void> loginAndSync(String email, String password) async {
    try {
      // 1. Fazer login primeiro (reutilizar método existente)
      await login(email, password);

      // 2. Se login falhou, não continua com sync
      if (!state.isAuthenticated || state.errorMessage != null) {
        return;
      }

      // 3. Iniciar sincronização em background (não bloqueia navegação)
      if (!state.isAnonymous) {
        _performBackgroundSync();
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro interno no login com sincronização. Tente novamente.',
        isLoading: false,
        status: AuthStatus.error,
      );

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'loginAndSync_error',
      );
    }
  }

  /// Executa sincronização em background sem bloquear navegação
  void _performBackgroundSync() {
    // Executar em background sem bloquear a UI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.isAuthenticated && !state.isAnonymous) {
        _startBackgroundDataSync();
      }
    });
  }

  /// Sincronização de dados em background (padrão app-plantis)
  Future<void> _startBackgroundDataSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true);

    try {
      if (kDebugMode) {
        debugPrint('🔄 Iniciando sincronização em background...');
      }

      // Sincronizar dados do Gasometer de forma simples
      await _syncGasometerData();

      await _analytics.log('gasometer_background_sync_completed');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na sincronização em background: $e');
      }

      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'gasometer_background_sync_error',
      );
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Sincronizar dados do Gasometer usando UnifiedSync
  Future<void> _syncGasometerData() async {
    try {
      // Usar o UnifiedSyncManager para sincronizar todos os dados do app gasometer
      final syncResult = await UnifiedSyncManager.instance.forceSyncApp('gasometer');

      syncResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Erro na sincronização UnifiedSync: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Sincronização UnifiedSync concluída com sucesso');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na sincronização Gasometer: $e');
      }
    }
  }

  /// Para sincronização em andamento
  void stopSync() {
    state = state.copyWith(isSyncing: false);
  }

  /// Rate limiting methods
  Future<AuthRateLimitInfo> getRateLimitInfo() => _rateLimiter.getRateLimitInfo();

  Future<bool> canAttemptLogin() => _rateLimiter.canAttemptLogin();

  Future<void> resetRateLimit() => _rateLimiter.resetRateLimit();

  /// Convert core UserEntity to gasometer UserEntity
  UserEntity? _convertFromCoreUser(core.UserEntity? coreUser) {
    if (coreUser == null) return null;

    // Convert from core UserEntity to gasometer UserEntity
    return UserEntity(
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
  UserType _mapAuthProviderToUserType(core.AuthProvider provider) {
    switch (provider) {
      case core.AuthProvider.anonymous:
        return UserType.anonymous;
      case core.AuthProvider.email:
      case core.AuthProvider.google:
      case core.AuthProvider.apple:
      case core.AuthProvider.facebook:
        return UserType.registered;
    }
  }

  /// Convert gasometer UserEntity to core UserEntity
  core.UserEntity _convertToCore(UserEntity gasometerUser) {
    // Safely extract metadata
    final metadata = gasometerUser.metadata;
    final phone = metadata['phone'];
    final isActive = metadata['isActive'];

    return core.UserEntity(
      id: gasometerUser.id,
      email: gasometerUser.email ?? '',
      displayName: gasometerUser.displayName ?? '',
      photoUrl: gasometerUser.photoUrl,
      isEmailVerified: gasometerUser.isEmailVerified,
      lastLoginAt: gasometerUser.lastSignInAt,
      provider: _mapUserTypeToAuthProvider(gasometerUser.type),
      phone: phone is String ? phone : null,
      isActive: isActive is bool ? isActive : true,
      createdAt: gasometerUser.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Map UserType to AuthProvider for reverse conversion
  core.AuthProvider _mapUserTypeToAuthProvider(UserType userType) {
    switch (userType) {
      case UserType.anonymous:
        return core.AuthProvider.anonymous;
      case UserType.registered:
      case UserType.premium:
        return core.AuthProvider.email; // Default to email for registered users
    }
  }
}
