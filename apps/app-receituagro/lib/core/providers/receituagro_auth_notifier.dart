import 'dart:async';

import 'package:core/core.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../data/models/user_session_data.dart';
import '../di/injection_container.dart' as di;
import '../extensions/user_entity_receituagro_extension.dart';
import '../services/device_identity_service.dart';
import '../services/receituagro_data_cleaner.dart';

part 'receituagro_auth_notifier.g.dart';

/// Estado de autenticação do ReceitaAgro
class ReceitaAgroAuthState {
  final UserEntity? currentUser;
  final UserSessionData? sessionData;
  final bool isLoading;
  final String? errorMessage;

  const ReceitaAgroAuthState({
    this.currentUser,
    this.sessionData,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => currentUser != null && !currentUser!.isAnonymous;
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  UserType get userType {
    if (!isAuthenticated) return UserType.guest;
    return UserType.registered;
  }

  ReceitaAgroAuthState copyWith({
    UserEntity? currentUser,
    UserSessionData? sessionData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReceitaAgroAuthState(
      currentUser: currentUser ?? this.currentUser,
      sessionData: sessionData ?? this.sessionData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  ReceitaAgroAuthState clearError() {
    return copyWith(errorMessage: null);
  }

  factory ReceitaAgroAuthState.initial() {
    return const ReceitaAgroAuthState();
  }
}

/// AuthNotifier para ReceitaAgro com Riverpod
@riverpod
class ReceitaAgroAuthNotifier extends _$ReceitaAgroAuthNotifier {
  late final IAuthRepository _authRepository;
  late final DeviceIdentityService _deviceService;
  late final ReceitaAgroAnalyticsService _analytics;
  late final EnhancedAccountDeletionService _enhancedDeletionService;
  late final ISubscriptionRepository _subscriptionRepository;

  @override
  Stream<ReceitaAgroAuthState> build() async* {
    _authRepository = di.sl<IAuthRepository>();
    _deviceService = di.sl<DeviceIdentityService>();
    _analytics = di.sl<ReceitaAgroAnalyticsService>();
    _enhancedDeletionService = di.sl<EnhancedAccountDeletionService>();
    _subscriptionRepository = di.sl<ISubscriptionRepository>();
    yield ReceitaAgroAuthState.initial();
    await for (final user in _authRepository.currentUser) {
      final previousState = state.value ?? ReceitaAgroAuthState.initial();
      final previousUser = previousState.currentUser;

      if (user != null) {
        final sessionData = await _initializeUserSession(user);
        if (previousUser?.id != user.id) {
          _analytics.trackLogin(user.provider.toString());
          if (!user.isAnonymous) {
            await _syncSubscriptionUser(user);
            await _handleDeviceLogin(user);
            await _triggerPostAuthSync(user, previousUser);
          }
        }

        yield ReceitaAgroAuthState(
          currentUser: user,
          sessionData: sessionData,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        await _clearUserSession();
        if (previousUser != null) {
          _analytics.trackLogout('user_action');
        }

        yield ReceitaAgroAuthState.initial();
      }
    }
  }

  Future<UserSessionData?> _initializeUserSession(UserEntity user) async {
    try {
      final deviceId = await _deviceService.getDeviceUuid();
      final sessionData = UserSessionData(
        userId: user.id,
        deviceId: deviceId,
        loginTime: DateTime.now(),
        isAnonymous: user.isAnonymous,
      );

      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties(
        userType: _mapToAnalyticsUserType(state.value?.userType ?? UserType.guest),
        isPremium: false,
        deviceCount: 1,
      );

      if (kDebugMode) print('✅ Auth Notifier: User session initialized for ${user.displayName}');
      return sessionData;
    } catch (e) {
      if (kDebugMode) print('❌ Auth Notifier: Session initialization error - $e');
      return null;
    }
  }

  Future<void> _clearUserSession() async {
    await _analytics.clearUser();
    if (kDebugMode) print('✅ Auth Notifier: Session cleared');
  }

  Future<void> _handleDeviceLogin(UserEntity user) async {
    try {
      if (kDebugMode) print('🔄 Auth Notifier: Handling device login for user ${user.id}');

      final deviceInfo = await _deviceService.getDeviceInfo();
      _analytics.trackDeviceAdded(deviceInfo.platform);

      if (kDebugMode) {
        print('✅ Auth Notifier: Device login detected for ${deviceInfo.name}');
        print('   Device management handled by SettingsNotifier');
      }

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
            _analytics.trackEvent('post_auth_sync_failed', parameters: {'error': failure.message});
            if (kDebugMode) print('❌ Auth Notifier: Post-auth sync failed: ${failure.message}');
          },
          (_) {
            _analytics.trackEvent('post_auth_sync_success', parameters: {'sync_completed': 'true'});
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

  Future<bool> forceSyncUserData() async {
    final currentState = state.value;
    if (currentState == null || currentState.currentUser == null || currentState.currentUser!.isAnonymous) {
      if (kDebugMode) print('⚠️ Auth Notifier: Cannot sync - user not authenticated');
      return false;
    }

    try {
      _analytics.trackEvent('manual_sync_triggered', parameters: {
        'user_id': currentState.currentUser!.id,
        'trigger_source': 'manual_button',
      });

      if (kDebugMode) print('🔄 Auth Notifier: Starting manual sync for user ${currentState.currentUser!.displayName}');

      final result = await UnifiedSyncManager.instance.forceSyncApp('receituagro');

      return result.fold(
        (failure) {
          _analytics.trackEvent('manual_sync_failure', parameters: {'error': failure.message});
          if (kDebugMode) print('❌ Auth Notifier: Manual sync failed: ${failure.message}');
          return false;
        },
        (_) {
          _analytics.trackEvent('manual_sync_success', parameters: {'sync_completed': 'true'});
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

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(isLoading: true).clearError());

    try {
      _analytics.trackAuthFunnelStep('login_attempt');

      final result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
          _analytics.trackError('auth_login', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackAuthFunnelStep('login_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      ));
      _analytics.trackError('auth_login', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(isLoading: true).clearError());

    try {
      _analytics.trackAuthFunnelStep('signup_attempt');

      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
          _analytics.trackError('auth_signup', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackAuthFunnelStep('signup_success');
          _analytics.trackSignup('email', success: true);
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      ));
      _analytics.trackError('auth_signup', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> signInAnonymously() async {
    state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(isLoading: true).clearError());

    try {
      final result = await _authRepository.signInAnonymously();

      return result.fold(
        (failure) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackLogin('anonymous');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      ));
      return AuthResult.failure(e.toString());
    }
  }

  Future<AuthResult> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final currentState = state.value ?? ReceitaAgroAuthState.initial();

    if (!currentState.isAnonymous) {
      return AuthResult.failure('Usuário não é anônimo');
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      _analytics.trackAuthFunnelStep('anonymous_upgrade_attempt');

      final result = await _authRepository.linkWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) {
          state = AsyncValue.data(currentState.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
          _analytics.trackError('auth_upgrade', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackAuthFunnelStep('anonymous_upgrade_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      ));
      _analytics.trackError('auth_upgrade', e.toString());
      return AuthResult.failure(e.toString());
    }
  }

  Future<void> signOut() async {
    state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(isLoading: true));

    try {
      final result = await _authRepository.signOut();

      result.fold(
        (failure) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
        (_) {
          _analytics.trackLogout('user_action');
          signInAnonymously();
        },
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
        isLoading: false,
        errorMessage: 'Erro ao fazer logout: $e',
      ));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(isLoading: true));

    try {
      final result = await _authRepository.sendPasswordResetEmail(email: email);

      result.fold(
        (failure) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
        (_) {
          state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
            isLoading: false,
            errorMessage: null,
          ));
          _analytics.trackEvent('password_reset_sent');
        },
      );
    } catch (e) {
      state = AsyncValue.data((state.value ?? ReceitaAgroAuthState.initial()).copyWith(
        isLoading: false,
        errorMessage: 'Erro ao enviar email: $e',
      ));
    }
  }

  Future<AuthResult> deleteAccount({String? password}) async {
    final currentState = state.value ?? ReceitaAgroAuthState.initial();

    if (currentState.currentUser == null) {
      return AuthResult.failure('Nenhum usuário autenticado');
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true).clearError());

    try {
      if (kDebugMode) debugPrint('🗑️ Auth Notifier: Iniciando exclusão de conta');

      _analytics.trackEvent('account_deletion_attempt', parameters: {
        'user_id': currentState.currentUser!.id,
        'user_type': currentState.userType.toString(),
      });

      final result = await _enhancedDeletionService.deleteAccount(
        password: password ?? '',
        userId: currentState.currentUser!.id,
        isAnonymous: currentState.isAnonymous,
      );

      return result.fold(
        (error) {
          state = AsyncValue.data(currentState.copyWith(
            isLoading: false,
            errorMessage: error.message,
          ));
          _analytics.trackEvent('account_deletion_failed', parameters: {
            'error': error.message,
            'user_id': currentState.currentUser!.id,
          });
          if (kDebugMode) debugPrint('❌ Auth Notifier: Exclusão de conta falhou - ${error.message}');
          return AuthResult.failure(error.message);
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _analytics.trackEvent('account_deletion_success', parameters: {
              'user_id': currentState.currentUser!.id,
            });
            if (kDebugMode) debugPrint('✅ Auth Notifier: Exclusão de conta concluída com sucesso');

            state = AsyncValue.data(ReceitaAgroAuthState.initial());

            return AuthResult.success(const UserEntity(
              id: 'deleted',
              email: 'deleted@account.com',
              displayName: 'Conta excluída',
              provider: core.AuthProvider.anonymous,
            ));
          } else {
            state = AsyncValue.data(currentState.copyWith(
              isLoading: false,
              errorMessage: deletionResult.userMessage,
            ));
            _analytics.trackEvent('account_deletion_failed', parameters: {
              'error': deletionResult.userMessage,
              'user_id': currentState.currentUser!.id,
            });
            return AuthResult.failure(deletionResult.userMessage);
          }
        },
      );
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado durante exclusão: $e',
      ));
      _analytics.trackError('account_deletion_exception', e.toString());
      if (kDebugMode) debugPrint('❌ Auth Notifier: Erro inesperado durante exclusão - $e');
      return AuthResult.failure(e.toString());
    }
  }

  Future<Map<String, dynamic>?> getAccountDeletionPreview() async {
    try {
      if (kDebugMode) debugPrint('📊 Auth Notifier: Obtendo preview de exclusão');

      final dataCleaner = ReceitaAgroDataCleaner();
      final accountDeletionService = AccountDeletionService(
        authRepository: _authRepository,
        appDataCleaner: dataCleaner,
      );

      final result = await accountDeletionService.getAccountDeletionPreview();

      return result.fold(
        (failure) {
          if (kDebugMode) debugPrint('❌ Auth Notifier: Erro ao obter preview - ${failure.message}');
          return null;
        },
        (preview) {
          if (kDebugMode) {
            debugPrint('✅ Auth Notifier: Preview obtido com sucesso');
            debugPrint('   App: ${preview['appName']}');
            debugPrint('   Dados para limpar: ${preview['hasDataToClear']}');
            debugPrint('   Registros totais: ${preview['dataStats']?['totalRecords'] ?? 0}');
          }
          return preview;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Auth Notifier: Erro inesperado no preview - $e');
      return null;
    }
  }

  void clearError() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.clearError());
    }
  }

  bool canAccessFeature(String feature) {
    final currentState = state.value;
    if (currentState == null || !currentState.isAuthenticated) return false;
    return true;
  }

  AnalyticsUserType _mapToAnalyticsUserType(UserType userType) {
    switch (userType) {
      case UserType.guest:
        return AnalyticsUserType.guest;
      case UserType.registered:
        return AnalyticsUserType.registered;
      case UserType.premium:
        return AnalyticsUserType.premium;
    }
  }

  /// Sincroniza usuário com RevenueCat para vincular assinatura ao Firebase UID
  /// Isso permite recuperar assinatura em qualquer dispositivo ao fazer login
  Future<void> _syncSubscriptionUser(UserEntity user) async {
    try {
      if (kDebugMode) print('🔄 Auth Notifier: Vinculando assinatura ao usuário ${user.id}');

      final result = await _subscriptionRepository.setUser(
        userId: user.id,
        attributes: {
          'email': user.email,
          'displayName': user.displayName,
        },
      );

      result.fold(
        (failure) {
          if (kDebugMode) print('⚠️ Auth Notifier: Falha ao vincular assinatura - ${failure.message}');
          _analytics.trackError('subscription_user_sync_error', failure.message);
        },
        (_) {
          if (kDebugMode) print('✅ Auth Notifier: Assinatura vinculada ao usuário Firebase');
          _analytics.trackEvent('subscription_user_synced', parameters: {
            'user_id': user.id,
          });
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Auth Notifier: Erro ao vincular assinatura: $e');
      _analytics.trackError('subscription_user_sync_exception', e.toString());
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
}

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

enum UserType { guest, registered, premium }

extension UserEntityExtensions on UserEntity {
  bool get isAnonymous => provider.toString() == 'anonymous';
}
