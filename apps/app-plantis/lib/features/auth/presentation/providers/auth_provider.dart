import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/background_sync_provider.dart';
import '../../../../core/services/data_sanitization_service.dart';
import '../../../device_management/data/models/device_model.dart';
import '../../../device_management/domain/usecases/revoke_device_usecase.dart'
    as device_revocation;
import '../../../device_management/domain/usecases/validate_device_usecase.dart'
    as device_validation;
import '../../domain/usecases/reset_password_usecase.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserEntity? currentUser,
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool isInitialized,
    @Default(false) bool isPremium,
    AuthOperation? currentOperation,
    @Default(false) bool isValidatingDevice,
    String? deviceValidationError,
    @Default(false) bool deviceLimitExceeded,
    @Default(false) bool isSyncInProgress,
    @Default(false) bool hasPerformedInitialSync,
    @Default('Sincronizando dados...') String syncMessage,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => currentUser != null;
  bool get isAnonymous => currentUser?.provider.name == 'anonymous';
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  final LoginUseCase _loginUseCase = di.sl<LoginUseCase>();
  final LogoutUseCase _logoutUseCase = di.sl<LogoutUseCase>();
  final IAuthRepository _authRepository = di.sl<IAuthRepository>();
  final ISubscriptionRepository? _subscriptionRepository =
      di.sl<ISubscriptionRepository>();
  final AuthStateNotifier _authStateNotifier = AuthStateNotifier.instance;
  final ResetPasswordUseCase _resetPasswordUseCase =
      di.sl<ResetPasswordUseCase>();
  final BackgroundSyncProvider? _backgroundSyncProvider =
      di.sl<BackgroundSyncProvider>();
  final device_validation.ValidateDeviceUseCase? _validateDeviceUseCase =
      di.sl<device_validation.ValidateDeviceUseCase>();
  final device_revocation.RevokeDeviceUseCase? _revokeDeviceUseCase =
      di.sl<device_revocation.RevokeDeviceUseCase>();
  final EnhancedAccountDeletionService _enhancedDeletionService =
      di.sl<EnhancedAccountDeletionService>();

  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;

  AnalyticsProvider? get _analytics {
    try {
      return di.sl<AnalyticsProvider>();
    } catch (e) {
      return null;
    }
  }

  BackgroundSyncProvider? get _syncProvider {
    try {
      return _backgroundSyncProvider ?? di.sl<BackgroundSyncProvider>();
    } catch (e) {
      return null;
    }
  }

  @override
  AuthState build() {
    ref.onDispose(() {
      _userSubscription?.cancel();
      _subscriptionStream?.cancel();
    });

    _initializeAuthState();

    return const AuthState();
  }

  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        if (user == null && await _shouldUseAnonymousMode()) {
          if (kDebugMode) {
            debugPrint(
              '🔄 AuthNotifier: Iniciando modo anônimo, aguardando login...',
            );
          }
          await signInAnonymously();
          return;
        }
        await _completeAuthInitialization(user);
      },
      onError: (Object error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isInitialized: true,
        );
        _authStateNotifier.updateInitializationStatus(true);
        if (kDebugMode) {
          debugPrint(
            'Auth error: ${DataSanitizationService.sanitizeForLogging(error.toString())}',
          );
        }
      },
    );

    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository!.subscriptionStatus.listen(
        (subscription) {
          final isPremium = subscription?.isActive ?? false;
          state = state.copyWith(isPremium: isPremium);
          _authStateNotifier.updatePremiumStatus(isPremium);
        },
      );
    }
  }

  Future<void> _completeAuthInitialization(UserEntity? user) async {
    try {
      _authStateNotifier.updateUser(user);

      if (user != null &&
          !state.isAnonymous &&
          _subscriptionRepository != null) {
        await _syncUserWithRevenueCat(user.id);
        await _checkPremiumStatus();
        _triggerBackgroundSyncIfNeeded(user.id);
      } else {
        state = state.copyWith(isPremium: false);
        _authStateNotifier.updatePremiumStatus(false);
      }

      if (kDebugMode) {
        debugPrint(
          '✅ AuthNotifier: Initialization complete - User: ${user?.id ?? "anonymous"}, Premium: ${state.isPremium}',
        );
      }

      state = state.copyWith(currentUser: user, isInitialized: true);
      _authStateNotifier.updateInitializationStatus(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthNotifier: Error during initialization: $e');
      }
      state = state.copyWith(
        errorMessage: 'Erro na inicialização da autenticação: $e',
        isInitialized: true,
      );
      _authStateNotifier.updateInitializationStatus(true);
    }
  }

  Future<void> _syncUserWithRevenueCat(String userId) async {
    if (_subscriptionRepository == null) return;

    await _subscriptionRepository!.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'email': state.currentUser?.email ?? ''},
    );
  }

  Future<void> _checkPremiumStatus() async {
    if (_subscriptionRepository == null) return;

    final result = await _subscriptionRepository!.hasPlantisSubscription();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            'Erro verificar premium: ${DataSanitizationService.sanitizeForLogging(failure.message)}',
          );
        }
        state = state.copyWith(isPremium: false);
        _authStateNotifier.updatePremiumStatus(false);
      },
      (hasPremium) {
        state = state.copyWith(isPremium: hasPremium);
        _authStateNotifier.updatePremiumStatus(hasPremium);
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.signIn,
    );

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          currentOperation: null,
        );
      },
      (user) {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          currentOperation: null,
        );
        _authStateNotifier.updateUser(user);
        _analytics?.logLogin('email');
      },
    );
  }

  Future<void> loginAndNavigate(String email, String password) async {
    try {
      await login(email, password);
      if (state.isAuthenticated &&
          !state.isAnonymous &&
          state.errorMessage == null) {
        await _validateDeviceAfterLogin();
        if (!state.deviceLimitExceeded) {
          _triggerBackgroundSyncIfNeeded(state.currentUser!.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro durante login: $e');
      }
    }
  }

  Future<void> _validateDeviceAfterLogin() async {
    if (_validateDeviceUseCase == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Device validation não disponível');
      }
      return;
    }

    state = state.copyWith(
      isValidatingDevice: true,
      deviceValidationError: null,
      deviceLimitExceeded: false,
    );

    try {
      if (kDebugMode) {
        debugPrint('🔐 Validando dispositivo após login...');
      }

      final result = await _validateDeviceUseCase!();

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Device validation falhou: ${failure.message}');
          }
          state = state.copyWith(deviceValidationError: failure.message);

          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
            state = state.copyWith(deviceLimitExceeded: true);
            _handleDeviceLimitExceeded();
          }
        },
        (validationResult) {
          if (validationResult.isValid) {
            if (kDebugMode) {
              debugPrint('✅ Dispositivo validado com sucesso');
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ Device validation falhou: ${validationResult.message}',
              );
            }
            state = state.copyWith(
              deviceValidationError: validationResult.message,
            );

            if (validationResult.status == DeviceValidationStatus.exceeded) {
              state = state.copyWith(deviceLimitExceeded: true);
              _handleDeviceLimitExceeded();
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro inesperado na validação do dispositivo: $e');
      }
      state = state.copyWith(
        deviceValidationError: 'Erro na validação do dispositivo',
      );
    } finally {
      state = state.copyWith(isValidatingDevice: false);
    }
  }

  Future<void> _handleDeviceLimitExceeded() async {
    if (kDebugMode) {
      debugPrint(
        '🚫 Limite de dispositivos excedido - fazendo logout automático',
      );
    }
    await _analytics?.logEvent('device_limit_exceeded', {
      'user_id': state.currentUser?.id ?? 'unknown',
      'device_count': 3,
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (state.deviceLimitExceeded) {
        logout();
      }
    });
  }

  void _triggerBackgroundSyncIfNeeded(String userId) {
    if (_syncProvider == null) {
      if (kDebugMode) {
        debugPrint('⚠️ BackgroundSyncProvider não disponível');
      }
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (state.isAuthenticated && !state.isAnonymous) {
        _syncProvider!.startBackgroundSync(userId: userId, isInitialSync: true);
      }
    });
  }

  void cancelSync() {
    _syncProvider?.cancelSync();
  }

  Future<void> retrySyncAfterLogin() async {
    if (!state.isAuthenticated || state.currentUser == null) return;
    await _syncProvider?.retrySync(state.currentUser!.id);
  }

  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.logout,
    );

    await _performDeviceCleanupOnLogout();
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          currentOperation: null,
        );
      },
      (_) {
        state = state.copyWith(
          currentUser: null,
          isLoading: false,
          currentOperation: null,
        );
        _syncProvider?.resetSyncState();
        _authStateNotifier.updateUser(null);
        _authStateNotifier.updatePremiumStatus(false);
        _analytics?.logLogout();
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.signUp,
    );

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: name,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          currentOperation: null,
        );
      },
      (user) {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          currentOperation: null,
        );
        _authStateNotifier.updateUser(user);
      },
    );
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.anonymous,
    );

    final result = await _authRepository.signInAnonymously();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
          currentOperation: null,
        );
      },
      (user) {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          currentOperation: null,
        );
        _authStateNotifier.updateUser(user);
        _saveAnonymousPreference();
      },
    );
  }

  Future<void> _saveAnonymousPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_anonymous_mode', true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Erro salvar preferência anônima: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
        );
      }
    }
  }

  Future<bool> _shouldUseAnonymousMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('use_anonymous_mode') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> initializeAnonymousIfNeeded() async {
    if (!state.isAuthenticated && await _shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }

  Future<void> startAutoSyncIfNeeded() async {
    if (!state.isAuthenticated ||
        state.isAnonymous ||
        state.currentUser == null) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - usuário anônimo ou não autenticado');
      }
      return;
    }

    if (_syncProvider?.shouldStartInitialSync(state.currentUser!.id) == true) {
      if (kDebugMode) {
        debugPrint(
          '🔄 Iniciando auto-sync em background para usuário não anônimo',
        );
      }

      await _syncProvider?.startBackgroundSync(
        userId: state.currentUser!.id,
        isInitialSync: true,
      );
    } else {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync já realizado ou em progresso');
      }
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearCurrentOperation() {
    state = state.copyWith(currentOperation: null);
  }

  void clearDeviceValidationError() {
    state = state.copyWith(
      deviceValidationError: null,
      deviceLimitExceeded: false,
    );
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(errorMessage: null);

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        _analytics?.logEvent('password_reset_requested', {'method': 'email'});
        return true;
      },
    );
  }

  Future<void> _performDeviceCleanupOnLogout() async {
    if (_revokeDeviceUseCase == null ||
        state.currentUser == null ||
        state.isAnonymous) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Device cleanup: Skipped (missing dependencies or anonymous user)',
        );
      }
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('🧹 Device cleanup: Starting device revocation on logout');
      }

      final currentDevice = await DeviceModel.fromCurrentDevice();
      if (currentDevice == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Device cleanup: Skipping device revocation (unsupported platform)',
          );
        }
        return;
      }

      final revokeResult = await _revokeDeviceUseCase!(
        device_revocation.RevokeDeviceParams(
          deviceUuid: currentDevice.uuid,
          preventSelfRevoke: false,
          reason: 'User logout',
        ),
      );

      revokeResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ Device cleanup: Failed to revoke current device - ${failure.message}',
            );
          }
          _analytics?.logEvent('device_cleanup_failed', {
            'context': 'logout',
            'error': failure.message,
            'device_uuid': currentDevice.uuid,
            'user_id': state.currentUser!.id,
          });
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Device cleanup: Current device revoked successfully');
          }
          _analytics?.logEvent('device_cleanup_success', {
            'context': 'logout',
            'device_uuid': currentDevice.uuid,
            'user_id': state.currentUser!.id,
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Device cleanup: Unexpected error during logout cleanup - $e',
        );
      }
      _analytics?.logEvent('device_cleanup_error', {
        'context': 'logout',
        'error': e.toString(),
        'user_id': state.currentUser?.id ?? 'unknown',
      });
    }
  }

  Future<bool> deleteAccount({
    required String password,
    bool downloadData = false,
  }) async {
    if (state.currentUser == null) {
      state = state.copyWith(errorMessage: 'Nenhum usuário autenticado');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentOperation: AuthOperation.deleteAccount,
    );

    try {
      final result = await _enhancedDeletionService.deleteAccount(
        password: password,
        userId: state.currentUser!.id,
        isAnonymous: state.isAnonymous,
      );

      return result.fold(
        (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
            currentOperation: null,
          );
          return false;
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _performPostDeletionCleanup();
            return true;
          } else {
            state = state.copyWith(
              errorMessage: deletionResult.userMessage,
              isLoading: false,
              currentOperation: null,
            );
            return false;
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoading: false,
        currentOperation: null,
      );
      return false;
    }
  }

  void _performPostDeletionCleanup() {
    state = state.copyWith(
      currentUser: null,
      isPremium: false,
      isLoading: false,
      errorMessage: null,
      currentOperation: null,
    );
    _syncProvider?.resetSyncState();
    _authStateNotifier.updateUser(null);
    _authStateNotifier.updatePremiumStatus(false);
  }
}
