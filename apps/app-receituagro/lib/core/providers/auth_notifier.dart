import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide AuthState;
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../data/models/user_session_data.dart';
import '../extensions/user_entity_receituagro_extension.dart';
import '../services/device_identity_service.dart';
import '../services/receituagro_data_cleaner.dart';
import 'auth_state.dart' as local;

/// AuthNotifier Riverpod version - replaces ChangeNotifier
/// Manages authentication state using StateNotifier pattern
class AuthNotifier extends StateNotifier<local.AuthState> {
  final IAuthRepository _authRepository;
  final DeviceIdentityService _deviceService;
  final ReceitaAgroAnalyticsService _analytics;
  final EnhancedAccountDeletionService _enhancedDeletionService;

  StreamSubscription<UserEntity?>? _userSubscription;

  AuthNotifier({
    required IAuthRepository authRepository,
    required DeviceIdentityService deviceService,
    required ReceitaAgroAnalyticsService analytics,
    required EnhancedAccountDeletionService enhancedAccountDeletionService,
  })  : _authRepository = authRepository,
        _deviceService = deviceService,
        _analytics = analytics,
        _enhancedDeletionService = enhancedAccountDeletionService,
        super(const local.AuthState.initial()) {
    _initializeAuthNotifier();
  }

  // ===== INITIALIZATION =====

  Future<void> _initializeAuthNotifier() async {
    try {
      // Listen to auth state changes
      _userSubscription = _authRepository.currentUser.listen(
        _handleUserStateChange,
        onError: (Object error) {
          if (kDebugMode) print('❌ Auth Notifier: Error in user stream - $error');
          state = state.copyWith(errorMessage: 'Erro na autenticação: $error');
        },
      );

      // Check if user is already logged in
      final isLoggedIn = await _authRepository.isLoggedIn;
      if (isLoggedIn && state.currentUser != null) {
        await _initializeUserSession(state.currentUser!);
      }

      if (kDebugMode) print('✅ Auth Notifier: Initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Auth Notifier: Initialization error - $e');
      state = state.copyWith(errorMessage: 'Erro na inicialização: $e');
    }
  }

  Future<void> _handleUserStateChange(UserEntity? user) async {
    final previousUser = state.currentUser;

    if (user != null) {
      // User logged in or state changed
      await _initializeUserSession(user);

      // Track login analytics
      if (previousUser?.id != user.id) {
        _analytics.trackLogin(user.provider.toString());

        // Check if this is a new device for the user
        if (!user.isAnonymous) {
          await _handleDeviceLogin(user);

          // Trigger automatic sync after successful authentication
          await _triggerPostAuthSync(user, previousUser);
        }
      }
    } else {
      // User logged out
      await _clearUserSession();
      if (previousUser != null) {
        _analytics.trackLogout('user_action');
      }
    }
  }

  Future<void> _initializeUserSession(UserEntity user) async {
    try {
      state = state.copyWith(isLoading: true);

      // Generate session data
      final deviceId = await _deviceService.getDeviceUuid();
      final sessionData = UserSessionData(
        userId: user.id,
        deviceId: deviceId,
        loginTime: DateTime.now(),
        isAnonymous: user.isAnonymous,
      );

      // Set analytics user properties
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties(
        userType: _mapToAnalyticsUserType(state.userType),
        isPremium: false, // TODO: Check premium status
        deviceCount: 1, // TODO: Get actual device count
      );

      state = state.copyWith(
        currentUser: user,
        sessionData: sessionData,
        isLoading: false,
        clearError: true,
      );

      if (kDebugMode) print('✅ Auth Notifier: User session initialized for ${user.displayName}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na inicialização da sessão: $e',
      );
      if (kDebugMode) print('❌ Auth Notifier: Session initialization error - $e');
    }
  }

  Future<void> _clearUserSession() async {
    // Clear analytics
    await _analytics.clearUser();

    state = state.clearUser();

    if (kDebugMode) print('✅ Auth Notifier: Session cleared');
  }

  Future<void> _handleDeviceLogin(UserEntity user) async {
    try {
      if (kDebugMode) print('🔄 Auth Notifier: Handling device login for user ${user.id}');

      // Get current device info
      final deviceInfo = await _deviceService.getDeviceInfo();

      // Device registration is now handled by DeviceManagementService
      // which is integrated with SettingsNotifier (Riverpod)
      // Track device login for analytics
      _analytics.trackDeviceAdded(deviceInfo.platform);

      if (kDebugMode) {
        print('✅ Auth Notifier: Device login detected for ${deviceInfo.name}');
        print('   Device management handled by SettingsNotifier');
      }

      // Sync user profile with Firestore
      await _syncUserProfile(user, deviceInfo);
    } catch (e) {
      if (kDebugMode) print('❌ Auth Notifier: Device login handling error - $e');
      _analytics.trackError('device_login_error', e.toString());
    }
  }

  Future<void> _triggerPostAuthSync(UserEntity user, UserEntity? previousUser) async {
    try {
      _analytics.trackEvent('post_auth_sync_triggered', parameters: {
        'user_id': user.id,
        'was_anonymous': (previousUser?.isAnonymous ?? false).toString(),
        'new_login': (previousUser?.id != user.id).toString(),
      });

      if (kDebugMode) print('🔄 Auth Notifier: Triggering post-authentication sync for user ${user.displayName}');

      unawaited(UnifiedSyncManager.instance.forceSyncApp('receituagro').then((result) {
        result.fold(
          (failure) {
            _analytics.trackEvent('post_auth_sync_failed', parameters: {
              'error': failure.message,
            });
            if (kDebugMode) print('❌ Auth Notifier: Post-auth sync failed: ${failure.message}');
          },
          (_) {
            _analytics.trackEvent('post_auth_sync_success', parameters: {
              'sync_completed': 'true',
            });

            if (kDebugMode) print('✅ Auth Notifier: Post-auth sync completed successfully');

            if (previousUser?.isAnonymous == true && !user.isAnonymous) {
              _analytics.trackEvent('anonymous_to_authenticated_migration', parameters: {
                'previous_user_id': previousUser?.id ?? 'unknown',
                'new_user_id': user.id,
                'migration_result': 'success',
              });

              if (kDebugMode) print('✅ Auth Notifier: Anonymous to authenticated migration completed');
            }
          },
        );
      }).catchError((Object error) {
        _analytics.trackError('post_auth_sync_exception', error.toString());
        if (kDebugMode) print('❌ Auth Notifier: Post-auth sync exception: $error');
      }));
    } catch (e) {
      _analytics.trackError('post_auth_sync_trigger_error', e.toString());
      if (kDebugMode) print('❌ Auth Notifier: Error triggering post-auth sync: $e');
    }
  }

  // ===== PUBLIC METHODS =====

  Future<bool> forceSyncUserData() async {
    if (state.currentUser == null || state.currentUser!.isAnonymous) {
      if (kDebugMode) print('⚠️ Auth Notifier: Cannot sync - user not authenticated');
      return false;
    }

    try {
      _analytics.trackEvent('manual_sync_triggered', parameters: {
        'user_id': state.currentUser!.id,
        'trigger_source': 'manual_button',
      });

      if (kDebugMode) print('🔄 Auth Notifier: Starting manual sync for user ${state.currentUser!.displayName}');

      final result = await UnifiedSyncManager.instance.forceSyncApp('receituagro');

      return result.fold(
        (failure) {
          _analytics.trackEvent('manual_sync_failure', parameters: {
            'error': failure.message,
          });
          if (kDebugMode) print('❌ Auth Notifier: Manual sync failed: ${failure.message}');
          return false;
        },
        (_) {
          _analytics.trackEvent('manual_sync_success', parameters: {
            'sync_completed': 'true',
          });

          if (kDebugMode) print('✅ Auth Notifier: Manual sync completed successfully');
          return true;
        },
      );
    } catch (e) {
      _analytics.trackError('manual_sync_exception', e.toString());
      if (kDebugMode) print('❌ Auth Notifier: Manual sync exception: $e');
      return false;
    }
  }

  // ===== AUTHENTICATION METHODS =====

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      _analytics.trackAuthFunnelStep('login_attempt');

      final result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          _analytics.trackError('auth_login', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          state = state.copyWith(isLoading: false);
          _analytics.trackAuthFunnelStep('login_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: $e');
      _analytics.trackError('auth_login', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      _analytics.trackAuthFunnelStep('signup_attempt');

      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          _analytics.trackError('auth_signup', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          state = state.copyWith(isLoading: false);
          _analytics.trackAuthFunnelStep('signup_success');
          _analytics.trackSignup('email', success: true);
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: $e');
      _analytics.trackError('auth_signup', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signInAnonymously() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _authRepository.signInAnonymously();

      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          state = state.copyWith(isLoading: false);
          _analytics.trackLogin('anonymous');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      if (!state.isAnonymous) {
        return AuthResult.failure('Usuário não é anônimo');
      }

      _analytics.trackAuthFunnelStep('anonymous_upgrade_attempt');

      final result = await _authRepository.linkWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
          _analytics.trackError('auth_upgrade', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          state = state.copyWith(isLoading: false);
          _analytics.trackAuthFunnelStep('anonymous_upgrade_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado: $e');
      _analytics.trackError('auth_upgrade', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _authRepository.signOut();

      result.fold(
        (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
        (_) {
          _analytics.trackLogout('user_action');
          state = state.copyWith(isLoading: false);
          // Sign in anonymously after logout to maintain app functionality
          signInAnonymously();
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao fazer logout: $e');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _authRepository.sendPasswordResetEmail(email: email);

      result.fold(
        (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
          _analytics.trackEvent('password_reset_sent');
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao enviar email: $e');
    }
  }

  Future<AuthResult> deleteAccount({String? password}) async {
    try {
      if (state.currentUser == null) {
        state = state.copyWith(errorMessage: 'Nenhum usuário autenticado');
        return AuthResult.failure('Nenhum usuário autenticado');
      }

      state = state.copyWith(isLoading: true, clearError: true);

      if (kDebugMode) {
        debugPrint('🗑️ AuthNotifier: Iniciando exclusão de conta');
      }

      _analytics.trackEvent('account_deletion_attempt', parameters: {
        'user_id': state.currentUser!.id,
        'user_type': state.userType.toString(),
      });

      final result = await _enhancedDeletionService.deleteAccount(
        password: password ?? '',
        userId: state.currentUser!.id,
        isAnonymous: state.isAnonymous,
      );

      return result.fold(
        (error) {
          state = state.copyWith(isLoading: false, errorMessage: error.message);
          _analytics.trackEvent('account_deletion_failed', parameters: {
            'error': error.message,
            'user_id': state.currentUser!.id,
          });

          if (kDebugMode) {
            debugPrint('❌ AuthNotifier: Exclusão de conta falhou - ${error.message}');
          }

          return AuthResult.failure(error.message);
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _analytics.trackEvent('account_deletion_success', parameters: {
              'user_id': state.currentUser!.id,
            });

            if (kDebugMode) {
              debugPrint('✅ AuthNotifier: Exclusão de conta concluída com sucesso');
            }

            _performPostDeletionCleanup();

            return AuthResult.success(const UserEntity(
              id: 'deleted',
              email: 'deleted@account.com',
              displayName: 'Conta excluída',
              provider: core.AuthProvider.anonymous,
            ));
          } else {
            state = state.copyWith(isLoading: false, errorMessage: deletionResult.userMessage);
            _analytics.trackEvent('account_deletion_failed', parameters: {
              'error': deletionResult.userMessage,
              'user_id': state.currentUser!.id,
            });

            return AuthResult.failure(deletionResult.userMessage);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado durante exclusão: $e');
      _analytics.trackError('account_deletion_exception', e.toString());

      if (kDebugMode) {
        debugPrint('❌ AuthNotifier: Erro inesperado durante exclusão - $e');
      }

      return AuthResult.failure(e.toString());
    }
  }

  void _performPostDeletionCleanup() {
    state = state.clearUser();
  }

  Future<Map<String, dynamic>?> getAccountDeletionPreview() async {
    try {
      if (kDebugMode) {
        debugPrint('📊 AuthNotifier: Obtendo preview de exclusão');
      }

      final dataCleaner = ReceitaAgroDataCleaner();
      final accountDeletionService = AccountDeletionService(
        authRepository: _authRepository,
        appDataCleaner: dataCleaner,
      );

      final result = await accountDeletionService.getAccountDeletionPreview();

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          if (kDebugMode) {
            debugPrint('❌ AuthNotifier: Erro ao obter preview - ${failure.message}');
          }
          return null;
        },
        (preview) {
          if (kDebugMode) {
            debugPrint('✅ AuthNotifier: Preview obtido com sucesso');
            debugPrint('   App: ${preview['appName']}');
            debugPrint('   Dados para limpar: ${preview['hasDataToClear']}');
            debugPrint('   Registros totais: ${preview['dataStats']?['totalRecords'] ?? 0}');
          }
          return preview;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao obter preview: $e');
      if (kDebugMode) {
        debugPrint('❌ AuthNotifier: Erro inesperado no preview - $e');
      }
      return null;
    }
  }

  // ===== UTILITY METHODS =====

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool canAccessFeature(String feature) {
    if (!state.isAuthenticated) return false;

    // TODO: Integrate with Premium service
    return true;
  }

  AnalyticsUserType _mapToAnalyticsUserType(local.UserType userType) {
    switch (userType) {
      case local.UserType.guest:
        return AnalyticsUserType.guest;
      case local.UserType.registered:
        return AnalyticsUserType.registered;
      case local.UserType.premium:
        return AnalyticsUserType.premium;
    }
  }

  Future<void> _syncUserProfile(UserEntity user, DeviceInfo deviceInfo) async {
    try {
      if (user.id.isEmpty) {
        if (kDebugMode) print('🔄 Auth Notifier: User ID inválido - pulando sincronização de perfil');
        return;
      }

      final profileEntity = user.withReceitaAgroData(
        deviceId: deviceInfo.uuid,
        platform: deviceInfo.platform,
        appVersion: deviceInfo.appVersion,
      ).copyWith(
        updatedAt: DateTime.now(),
        userId: user.id,
      );

      final updateResult = await UnifiedSyncManager.instance.update<UserEntity>('receituagro', profileEntity.id, profileEntity);

      await updateResult.fold(
        (core.Failure failure) async {
          if (kDebugMode) print('Auth Notifier: Update falhou, tentando criar: ${failure.message}');
          final createResult = await UnifiedSyncManager.instance.create<UserEntity>('receituagro', profileEntity);
          createResult.fold(
            (core.Failure createFailure) {
              if (kDebugMode) print('❌ Auth Notifier: Erro na sincronização de perfil (create): ${createFailure.message}');
              _analytics.trackError('user_profile_sync_error', createFailure.message);
            },
            (String entityId) {
              if (kDebugMode) print('✅ Auth Notifier: Perfil do usuário criado com sucesso: $entityId');
            },
          );
        },
        (_) {
          if (kDebugMode) print('✅ Auth Notifier: Perfil do usuário atualizado com sucesso');
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Auth Notifier: Erro ao sincronizar perfil do usuário: $e');
      _analytics.trackError('user_profile_sync_error', e.toString());
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

// ===== SUPPORTING CLASSES =====

class AuthResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserEntity user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}

// Extension to check if UserEntity is anonymous
extension UserEntityExtensions on UserEntity {
  bool get isAnonymous => provider.toString() == 'anonymous';
}
