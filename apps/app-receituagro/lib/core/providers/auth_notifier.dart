import 'dart:async';

import 'package:core/core.dart' hide AuthState, Column, analyticsServiceProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/analytics/analytics_service.dart';
import '../data/models/user_session_data.dart';
import '../extensions/user_entity_receituagro_extension.dart';
import '../services/device_identity_service.dart';
import 'auth_state.dart' as local;
import 'core_providers.dart';

/// AuthNotifier using StateNotifier pattern
/// Manages authentication state
class AuthNotifier extends StateNotifier<local.AuthState> {
  final Ref ref;
  late final IAuthRepository _authRepository;
  late final DeviceIdentityService _deviceService;
  late final ReceitaAgroAnalyticsService _analytics;
  late final EnhancedAccountDeletionService _enhancedDeletionService;

  StreamSubscription<UserEntity?>? _userSubscription;

  AuthNotifier(this.ref) : super(const local.AuthState.initial()) {
    _initializeAuthNotifier();
  }

  Future<void> _initializeAuthNotifier() async {
    // Initialize dependencies from Riverpod providers
    _authRepository = ref.read(authRepositoryProvider);
    _deviceService = ref.read(deviceIdentityServiceProvider);
    _analytics = ref.read(analyticsServiceProvider);
    _enhancedDeletionService = ref.read(
      enhancedAccountDeletionServiceProvider,
    );

    try {
      _userSubscription = _authRepository.currentUser.listen(
        _handleUserStateChange,
        onError: (Object error) {
          if (kDebugMode) {
            print('❌ Auth Notifier: Error in user stream - $error');
          }
          state = state.copyWith(errorMessage: 'Erro na autenticação: $error');
        },
      );
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
      await _initializeUserSession(user);
      if (previousUser?.id != user.id) {
        _analytics.trackLogin(user.provider.toString());
        if (!user.isAnonymous) {
          await _handleDeviceLogin(user);
          await _triggerPostAuthSync(user, previousUser);
        }
      }
    } else {
      await _clearUserSession();
      if (previousUser != null) {
        _analytics.trackLogout('user_action');
      }
    }
  }

  Future<void> _initializeUserSession(UserEntity user) async {
    try {
      state = state.copyWith(isLoading: true);
      final deviceId = await _deviceService.getDeviceUuid();
      final sessionData = UserSessionData(
        userId: user.id,
        deviceId: deviceId,
        loginTime: DateTime.now(),
        isAnonymous: user.isAnonymous,
      );
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties(
        userType: _mapToAnalyticsUserType(state.userType),
        isPremium: false,
        deviceCount: 1,
      );

      state = state.copyWith(
        currentUser: user,
        sessionData: sessionData,
        isLoading: false,
        clearError: true,
      );

      if (kDebugMode) {
        print(
          '✅ Auth Notifier: User session initialized for ${user.displayName}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na inicialização da sessão: $e',
      );
      if (kDebugMode) {
        print('❌ Auth Notifier: Session initialization error - $e');
      }
    }
  }

  Future<void> _clearUserSession() async {
    await _analytics.clearUser();

    state = state.clearUser();

    if (kDebugMode) print('✅ Auth Notifier: Session cleared');
  }

  Future<void> _handleDeviceLogin(UserEntity user) async {
    try {
      if (kDebugMode) {
        print('🔄 Auth Notifier: Handling device login for user ${user.id}');
      }
      final deviceInfo = await _deviceService.getDeviceInfo();
      _analytics.trackDeviceAdded(deviceInfo.platform);

      if (kDebugMode) {
        print('✅ Auth Notifier: Device login detected for ${deviceInfo.name}');
        print('   Device management handled by SettingsNotifier');
      }
      await _syncUserProfile(user, deviceInfo);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth Notifier: Device login handling error - $e');
      }
      _analytics.trackError('device_login_error', e.toString());
    }
  }

  Future<void> _triggerPostAuthSync(
    UserEntity user,
    UserEntity? previousUser,
  ) async {
    try {
      _analytics.trackEvent(
        'post_auth_sync_triggered',
        parameters: {
          'user_id': user.id,
          'was_anonymous': (previousUser?.isAnonymous ?? false).toString(),
          'new_login': (previousUser?.id != user.id).toString(),
        },
      );

      if (kDebugMode) {
        print(
          '🔄 Auth Notifier: Triggering post-authentication sync for user ${user.displayName}',
        );
      }

      unawaited(
        UnifiedSyncManager.instance
            .forceSyncApp('receituagro')
            .then((result) {
              result.fold(
                (failure) {
                  _analytics.trackEvent(
                    'post_auth_sync_failed',
                    parameters: {'error': failure.message},
                  );
                  if (kDebugMode) {
                    print(
                      '❌ Auth Notifier: Post-auth sync failed: ${failure.message}',
                    );
                  }
                },
                (_) {
                  _analytics.trackEvent(
                    'post_auth_sync_success',
                    parameters: {'sync_completed': 'true'},
                  );

                  if (kDebugMode) {
                    print(
                      '✅ Auth Notifier: Post-auth sync completed successfully',
                    );
                  }

                  if (previousUser?.isAnonymous == true && !user.isAnonymous) {
                    _analytics.trackEvent(
                      'anonymous_to_authenticated_migration',
                      parameters: {
                        'previous_user_id': previousUser?.id ?? 'unknown',
                        'new_user_id': user.id,
                        'migration_result': 'success',
                      },
                    );

                    if (kDebugMode) {
                      print(
                        '✅ Auth Notifier: Anonymous to authenticated migration completed',
                      );
                    }
                  }
                },
              );
            })
            .catchError((Object error) {
              _analytics.trackError(
                'post_auth_sync_exception',
                error.toString(),
              );
              if (kDebugMode) {
                print('❌ Auth Notifier: Post-auth sync exception: $error');
              }
            }),
      );
    } catch (e) {
      _analytics.trackError('post_auth_sync_trigger_error', e.toString());
      if (kDebugMode) {
        print('❌ Auth Notifier: Error triggering post-auth sync: $e');
      }
    }
  }

  Future<bool> forceSyncUserData() async {
    if (state.currentUser == null || state.currentUser!.isAnonymous) {
      if (kDebugMode) {
        print('⚠️ Auth Notifier: Cannot sync - user not authenticated');
      }
      return false;
    }

    try {
      _analytics.trackEvent(
        'manual_sync_triggered',
        parameters: {
          'user_id': state.currentUser!.id,
          'trigger_source': 'manual_button',
        },
      );

      if (kDebugMode) {
        print(
          '🔄 Auth Notifier: Starting manual sync for user ${state.currentUser!.displayName}',
        );
      }

      final result = await UnifiedSyncManager.instance.forceSyncApp(
        'receituagro',
      );

      return result.fold(
        (failure) {
          _analytics.trackEvent(
            'manual_sync_failure',
            parameters: {'error': failure.message},
          );
          if (kDebugMode) {
            print('❌ Auth Notifier: Manual sync failed: ${failure.message}');
          }
          return false;
        },
        (_) {
          _analytics.trackEvent(
            'manual_sync_success',
            parameters: {'sync_completed': 'true'},
          );

          if (kDebugMode) {
            print('✅ Auth Notifier: Manual sync completed successfully');
          }
          return true;
        },
      );
    } catch (e) {
      _analytics.trackError('manual_sync_exception', e.toString());
      if (kDebugMode) print('❌ Auth Notifier: Manual sync exception: $e');
      return false;
    }
  }

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
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
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
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
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
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return AuthResult.failure(failure.message);
        },
        (user) {
          state = state.copyWith(isLoading: false);
          _analytics.trackLogin('anonymous');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
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
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      _analytics.trackError('auth_upgrade', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _authRepository.signOut();

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (_) async {
          // 🔐 SEGURANÇA: Limpar dados premium e sensíveis antes de criar novo usuário anônimo
          await _clearPremiumDataOnLogout();

          _analytics.trackLogout('user_action');
          state = state.copyWith(isLoading: false);
          await signInAnonymously();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao fazer logout: $e',
      );
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await _authRepository.sendPasswordResetEmail(email: email);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (_) {
          state = state.copyWith(isLoading: false, clearError: true);
          _analytics.trackEvent('password_reset_sent');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao enviar email: $e',
      );
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

      _analytics.trackEvent(
        'account_deletion_attempt',
        parameters: {
          'user_id': state.currentUser!.id,
          'user_type': state.userType.toString(),
        },
      );

      final result = await _enhancedDeletionService.deleteAccount(
        password: password ?? '',
        userId: state.currentUser!.id,
        isAnonymous: state.isAnonymous,
      );

      return result.fold(
        (error) {
          state = state.copyWith(isLoading: false, errorMessage: error.message);
          _analytics.trackEvent(
            'account_deletion_failed',
            parameters: {
              'error': error.message,
              'user_id': state.currentUser!.id,
            },
          );

          if (kDebugMode) {
            debugPrint(
              '❌ AuthNotifier: Exclusão de conta falhou - ${error.message}',
            );
          }

          return AuthResult.failure(error.message);
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _analytics.trackEvent(
              'account_deletion_success',
              parameters: {'user_id': state.currentUser!.id},
            );

            if (kDebugMode) {
              debugPrint(
                '✅ AuthNotifier: Exclusão de conta concluída com sucesso',
              );
            }

            _performPostDeletionCleanup();

            return AuthResult.success(
              const UserEntity(
                id: 'deleted',
                email: 'deleted@account.com',
                displayName: 'Conta excluída',
                provider: AuthProvider.anonymous,
              ),
            );
          } else {
            state = state.copyWith(
              isLoading: false,
              errorMessage: deletionResult.userMessage,
            );
            _analytics.trackEvent(
              'account_deletion_failed',
              parameters: {
                'error': deletionResult.userMessage,
                'user_id': state.currentUser!.id,
              },
            );

            return AuthResult.failure(deletionResult.userMessage);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado durante exclusão: $e',
      );
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

      final dataCleaner = ref.read(dataCleanerServiceProvider);
      final accountDeletionService = AccountDeletionService(
        authRepository: _authRepository,
        appDataCleaner: dataCleaner,
      );

      final result = await accountDeletionService.getAccountDeletionPreview();

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.message);
          if (kDebugMode) {
            debugPrint(
              '❌ AuthNotifier: Erro ao obter preview - ${failure.message}',
            );
          }
          return null;
        },
        (preview) {
          if (kDebugMode) {
            debugPrint('✅ AuthNotifier: Preview obtido com sucesso');
            debugPrint('   App: ${preview['appName']}');
            debugPrint('   Dados para limpar: ${preview['hasDataToClear']}');
            debugPrint(
              '   Registros totais: ${preview['dataStats']?['totalRecords'] ?? 0}',
            );
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

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool canAccessFeature(String feature) {
    if (!state.isAuthenticated) return false;
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
        if (kDebugMode) {
          print(
            '🔄 Auth Notifier: User ID inválido - pulando sincronização de perfil',
          );
        }
        return;
      }

      final profileEntity = user
          .withReceitaAgroData(
            deviceId: deviceInfo.uuid,
            platform: deviceInfo.platform,
            appVersion: deviceInfo.appVersion,
          )
          .copyWith(updatedAt: DateTime.now(), userId: user.id);

      final updateResult = await UnifiedSyncManager.instance.update<UserEntity>(
        'receituagro',
        profileEntity.id,
        profileEntity,
      );

      await updateResult.fold(
        (Failure failure) async {
          if (kDebugMode) {
            print(
              'Auth Notifier: Update falhou, tentando criar: ${failure.message}',
            );
          }
          final createResult = await UnifiedSyncManager.instance
              .create<UserEntity>('receituagro', profileEntity);
          createResult.fold(
            (Failure createFailure) {
              if (kDebugMode) {
                print(
                  '❌ Auth Notifier: Erro na sincronização de perfil (create): ${createFailure.message}',
                );
              }
              _analytics.trackError(
                'user_profile_sync_error',
                createFailure.message,
              );
            },
            (String entityId) {
              if (kDebugMode) {
                print(
                  '✅ Auth Notifier: Perfil do usuário criado com sucesso: $entityId',
                );
              }
            },
          );
        },
        (_) {
          if (kDebugMode) {
            print('✅ Auth Notifier: Perfil do usuário atualizado com sucesso');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Auth Notifier: Erro ao sincronizar perfil do usuário: $e');
      }
      _analytics.trackError('user_profile_sync_error', e.toString());
    }
  }

  /// 🔐 SEGURANÇA: Limpa dados premium e sensíveis no logout
  ///
  /// Previne vazamento de informações de assinatura para novos usuários
  /// que usarem o mesmo dispositivo após logout.
  ///
  /// Dados limpos:
  /// - Status premium local
  /// - Favoritos salvos
  /// - Comentários privados
  /// - SharedPreferences relacionadas a premium
  Future<void> _clearPremiumDataOnLogout() async {
    try {
      if (kDebugMode) {
        debugPrint('🧹 Auth Notifier: Limpando dados premium no logout...');
      }

      final dataCleaner = ref.read(dataCleanerServiceProvider);

      // Limpar categorias sensíveis que contêm dados do usuário
      final categoriesToClear = ['premium', 'favoritos', 'comentarios'];

      for (final category in categoriesToClear) {
        try {
          final result = await dataCleaner.clearCategoryData(category);

          if (kDebugMode) {
            if (result['success'] == true) {
              debugPrint(
                '   ✅ Categoria "$category" limpa: ${result['totalRecordsCleared']} registros',
              );
            } else {
              debugPrint(
                '   ⚠️ Falha ao limpar categoria "$category": ${result['errors']}',
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('   ❌ Erro ao limpar categoria "$category": $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Auth Notifier: Limpeza de dados premium concluída');
      }
    } catch (e) {
      // Não falha o logout se a limpeza de dados falhar
      if (kDebugMode) {
        debugPrint('❌ Auth Notifier: Erro na limpeza de dados premium: $e');
      }
      _analytics.trackError('premium_data_cleanup_error', e.toString());
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

class AuthResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;

  const AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(UserEntity user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}

extension UserEntityExtensions on UserEntity {
  bool get isAnonymous => provider.toString() == 'anonymous';
}
