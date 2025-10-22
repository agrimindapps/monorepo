import 'dart:async';

import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/background_sync_provider.dart'
    show BackgroundSync, backgroundSyncProvider, shouldStartInitialSyncProvider;
import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../device_management/data/models/device_model.dart';
import '../../../device_management/domain/usecases/revoke_device_usecase.dart'
    as device_revocation;
import '../../../device_management/domain/usecases/validate_device_usecase.dart'
    as device_validation;
import '../../domain/usecases/reset_password_usecase.dart';

part 'auth_notifier.g.dart';

/// State imutável para autenticação
class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;
  final bool isPremium;
  final AuthOperation? currentOperation;
  final bool isValidatingDevice;
  final String? deviceValidationError;
  final bool deviceLimitExceeded;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.isPremium = false,
    this.currentOperation,
    this.isValidatingDevice = false,
    this.deviceValidationError,
    this.deviceLimitExceeded = false,
  });
  bool get isAuthenticated => currentUser != null;
  bool get isAnonymous => currentUser?.provider.name == 'anonymous';

  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool? isPremium,
    AuthOperation? currentOperation,
    bool? isValidatingDevice,
    String? deviceValidationError,
    bool? deviceLimitExceeded,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      isPremium: isPremium ?? this.isPremium,
      currentOperation: currentOperation,
      isValidatingDevice: isValidatingDevice ?? this.isValidatingDevice,
      deviceValidationError: deviceValidationError,
      deviceLimitExceeded: deviceLimitExceeded ?? this.deviceLimitExceeded,
    );
  }

  AuthState withoutUser() {
    return AuthState(
      currentUser: null,
      isLoading: isLoading,
      errorMessage: errorMessage,
      isInitialized: isInitialized,
      isPremium: false,
      currentOperation: currentOperation,
      isValidatingDevice: isValidatingDevice,
      deviceValidationError: deviceValidationError,
      deviceLimitExceeded: deviceLimitExceeded,
    );
  }
}

/// Notifier para gerenciamento de autenticação do Plantis
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final IAuthRepository _authRepository;
  late final ISubscriptionRepository? _subscriptionRepository;
  late final AuthStateNotifier _authStateNotifier;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final BackgroundSync? _backgroundSyncNotifier;
  late final device_validation.ValidateDeviceUseCase? _validateDeviceUseCase;
  late final device_revocation.RevokeDeviceUseCase? _revokeDeviceUseCase;
  late final EnhancedAccountDeletionService _enhancedDeletionService;
  late final AnalyticsProvider? _analytics;

  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;

  @override
  Future<AuthState> build() async {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _authRepository = ref.read(authRepositoryProvider);
    _subscriptionRepository = ref.read(subscriptionRepositoryProvider);
    _authStateNotifier = AuthStateNotifier.instance;
    _resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
    _backgroundSyncNotifier = ref.read(
      backgroundSyncNotifierProvider as ProviderListenable<BackgroundSync?>,
    );
    _validateDeviceUseCase = ref.read(validateDeviceUseCaseProvider);
    _revokeDeviceUseCase = ref.read(revokeDeviceUseCaseProvider);
    _enhancedDeletionService = ref.read(enhancedAccountDeletionServiceProvider);
    _analytics = ref.read(analyticsProviderProvider);
    _initializeAuthState();
    return const AuthState();
  }

  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        final currentState = state.valueOrNull ?? const AuthState();
        if (user == null && await shouldUseAnonymousMode()) {
          if (kDebugMode) {
            debugPrint(
              '🔄 AuthNotifier: Iniciando modo anônimo, aguardando login...',
            );
          }
          await signInAnonymously();
          return;
        }
        state = AsyncValue.data(currentState.copyWith(currentUser: user));
        await _completeAuthInitialization(user);
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint(
            'Auth error: ${DataSanitizationService.sanitizeForLogging(error.toString())}',
          );
        }

        final currentState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: error.toString(),
            isInitialized: true,
          ),
        );
        _authStateNotifier.updateInitializationStatus(true);
      },
    );
    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen((
        subscription,
      ) {
        final isPremium = subscription?.isActive ?? false;
        final currentState = state.valueOrNull ?? const AuthState();

        state = AsyncValue.data(currentState.copyWith(isPremium: isPremium));

        _authStateNotifier.updatePremiumStatus(isPremium);
      });
    }
    ref.onDispose(() {
      _userSubscription?.cancel();
      _subscriptionStream?.cancel();
    });
  }

  /// Complete auth initialization only after all operations are stable
  Future<void> _completeAuthInitialization(UserEntity? user) async {
    try {
      final currentState = state.valueOrNull ?? const AuthState();
      _authStateNotifier.updateUser(user);
      if (user != null &&
          !currentState.isAnonymous &&
          _subscriptionRepository != null) {
        await _syncUserWithRevenueCat(user.id);
        await _checkPremiumStatus();
        _triggerBackgroundSyncIfNeeded(user.id);
      } else {
        state = AsyncValue.data(currentState.copyWith(isPremium: false));
        _authStateNotifier.updatePremiumStatus(false);
      }

      if (kDebugMode) {
        debugPrint(
          '✅ AuthNotifier: Initialization complete - User: ${user?.id ?? "anonymous"}, Premium: ${currentState.isPremium}',
        );
      }

      state = AsyncValue.data(currentState.copyWith(isInitialized: true));
      _authStateNotifier.updateInitializationStatus(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthNotifier: Error during initialization: $e');
      }

      final currentState = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        currentState.copyWith(
          errorMessage: 'Erro na inicialização da autenticação: $e',
          isInitialized: true,
        ),
      );
      _authStateNotifier.updateInitializationStatus(true);
    }
  }

  Future<void> _syncUserWithRevenueCat(String userId) async {
    if (_subscriptionRepository == null) return;

    final currentState = state.valueOrNull ?? const AuthState();

    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {
        'app': 'plantis',
        'email': currentState.currentUser?.email ?? '',
      },
    );
  }

  Future<void> _checkPremiumStatus() async {
    if (_subscriptionRepository == null) return;

    final result = await _subscriptionRepository.hasPlantisSubscription();
    final currentState = state.valueOrNull ?? const AuthState();

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            'Erro verificar premium: ${DataSanitizationService.sanitizeForLogging(failure.message)}',
          );
        }
        state = AsyncValue.data(currentState.copyWith(isPremium: false));
        _authStateNotifier.updatePremiumStatus(false);
      },
      (hasPremium) {
        state = AsyncValue.data(currentState.copyWith(isPremium: hasPremium));
        _authStateNotifier.updatePremiumStatus(hasPremium);
      },
    );
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: AuthOperation.signIn,
      ),
    );

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
      (user) {
        state = AsyncValue.data(
          currentState.copyWith(
            currentUser: user,
            isLoading: false,
            currentOperation: null,
          ),
        );
        _authStateNotifier.updateUser(user);
        _analytics?.logLogin('email');
      },
    );
  }

  /// Non-blocking login that triggers background sync and device validation
  Future<void> loginAndNavigate(String email, String password) async {
    try {
      await login(email, password);

      final currentState = state.valueOrNull ?? const AuthState();
      if (currentState.isAuthenticated &&
          !currentState.isAnonymous &&
          currentState.errorMessage == null) {
        await _validateDeviceAfterLogin();
        if (!currentState.deviceLimitExceeded &&
            currentState.currentUser != null) {
          _triggerBackgroundSyncIfNeeded(currentState.currentUser!.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro durante login: $e');
      }
    }
  }

  /// Validates device after successful login
  Future<void> _validateDeviceAfterLogin() async {
    if (_validateDeviceUseCase == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Device validation não disponível');
      }
      return;
    }

    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        isValidatingDevice: true,
        deviceValidationError: null,
        deviceLimitExceeded: false,
      ),
    );

    try {
      if (kDebugMode) {
        debugPrint('🔐 Validando dispositivo após login...');
      }

      final result = await _validateDeviceUseCase();

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Device validation falhou: ${failure.message}');
          }

          final newState = state.valueOrNull ?? const AuthState();
          state = AsyncValue.data(
            newState.copyWith(
              deviceValidationError: failure.message,
              deviceLimitExceeded: failure.code == 'DEVICE_LIMIT_EXCEEDED',
            ),
          );

          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
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

            final newState = state.valueOrNull ?? const AuthState();
            state = AsyncValue.data(
              newState.copyWith(
                deviceValidationError: validationResult.message,
                deviceLimitExceeded:
                    validationResult.status == DeviceValidationStatus.exceeded,
              ),
            );

            if (validationResult.status == DeviceValidationStatus.exceeded) {
              _handleDeviceLimitExceeded();
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro inesperado na validação do dispositivo: $e');
      }

      final newState = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        newState.copyWith(
          deviceValidationError: 'Erro na validação do dispositivo',
        ),
      );
    } finally {
      final newState = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(newState.copyWith(isValidatingDevice: false));
    }
  }

  /// Handle device limit exceeded - force logout
  Future<void> _handleDeviceLimitExceeded() async {
    final currentState = state.valueOrNull ?? const AuthState();

    if (kDebugMode) {
      debugPrint(
        '🚫 Limite de dispositivos excedido - fazendo logout automático',
      );
    }
    await _analytics?.logEvent('device_limit_exceeded', {
      'user_id': currentState.currentUser?.id ?? 'unknown',
      'device_count': 3,
    });
    unawaited(
      Future.delayed(const Duration(milliseconds: 1500), () {
        final newState = state.valueOrNull ?? const AuthState();
        if (newState.deviceLimitExceeded) {
          logout();
        }
      }),
    );
  }

  /// Triggers background sync without blocking UI
  void _triggerBackgroundSyncIfNeeded(String userId) {
    if (_backgroundSyncNotifier == null) {
      if (kDebugMode) {
        debugPrint('⚠️ BackgroundSyncProvider não disponível');
      }
      return;
    }

    final currentState = state.valueOrNull ?? const AuthState();
    unawaited(
      Future.delayed(const Duration(milliseconds: 100), () {
        if (currentState.isAuthenticated && !currentState.isAnonymous) {
          _backgroundSyncNotifier.startBackgroundSync(
            userId: userId,
            isInitialSync: true,
          );
        }
      }),
    );
  }

  /// Cancel ongoing sync
  void cancelSync() {
    _backgroundSyncNotifier?.cancelSync();
  }

  /// Retry sync after login
  Future<void> retrySyncAfterLogin() async {
    final currentState = state.valueOrNull ?? const AuthState();
    if (!currentState.isAuthenticated || currentState.currentUser == null) {
      return;
    }

    await _backgroundSyncNotifier?.retrySync(currentState.currentUser!.id);
  }

  /// Logout
  Future<void> logout() async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: AuthOperation.logout,
      ),
    );
    await _performDeviceCleanupOnLogout();
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
      (_) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.withoutUser().copyWith(
            isLoading: false,
            currentOperation: null,
          ),
        );
        _backgroundSyncNotifier?.resetSyncState();
        _authStateNotifier.updateUser(null);
        _authStateNotifier.updatePremiumStatus(false);
        _analytics?.logLogout();
      },
    );
  }

  /// Register new user
  Future<void> register(String email, String password, String name) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: AuthOperation.signUp,
      ),
    );

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: name,
    );

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
      (user) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            currentOperation: null,
          ),
        );
        _authStateNotifier.updateUser(user);
      },
    );
  }

  /// Sign in anonymously
  Future<void> signInAnonymously() async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: AuthOperation.anonymous,
      ),
    );

    final result = await _authRepository.signInAnonymously();

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            currentOperation: null,
          ),
        );
      },
      (user) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            currentOperation: null,
          ),
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

  Future<bool> shouldUseAnonymousMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('use_anonymous_mode') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Initialize anonymous mode if needed
  Future<void> initializeAnonymousIfNeeded() async {
    final currentState = state.valueOrNull ?? const AuthState();
    if (!currentState.isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }

  /// Start auto sync if needed
  Future<void> startAutoSyncIfNeeded() async {
    final currentState = state.valueOrNull ?? const AuthState();

    if (!currentState.isAuthenticated ||
        currentState.isAnonymous ||
        currentState.currentUser == null) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - usuário anônimo ou não autenticado');
      }
      return;
    }

    // Check if sync is needed using the shouldStartInitialSync provider
    final shouldSync = ref.read(
      shouldStartInitialSyncProvider(currentState.currentUser!.id),
    );

    if (shouldSync) {
      if (kDebugMode) {
        debugPrint(
          '🔄 Iniciando auto-sync em background para usuário não anônimo',
        );
      }

      await _backgroundSyncNotifier?.startBackgroundSync(
        userId: currentState.currentUser!.id,
        isInitialSync: true,
      );
    } else {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync já realizado ou em progresso');
      }
    }
  }

  /// Clear error
  void clearError() {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));
  }

  /// Clear current operation
  void clearCurrentOperation() {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(currentState.copyWith(currentOperation: null));
  }

  /// Clear device validation error
  void clearDeviceValidationError() {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(
      currentState.copyWith(
        deviceValidationError: null,
        deviceLimitExceeded: false,
      ),
    );
  }

  /// Request password reset via email
  Future<bool> resetPassword(String email) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncValue.data(currentState.copyWith(errorMessage: null));

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncValue.data(
          newState.copyWith(errorMessage: failure.message),
        );
        return false;
      },
      (_) {
        _analytics?.logEvent('password_reset_requested', {'method': 'email'});
        return true;
      },
    );
  }

  /// Perform device cleanup during logout
  Future<void> _performDeviceCleanupOnLogout() async {
    final currentState = state.valueOrNull ?? const AuthState();

    if (_revokeDeviceUseCase == null ||
        currentState.currentUser == null ||
        currentState.isAnonymous) {
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
      final revokeResult = await _revokeDeviceUseCase(
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
            'user_id': currentState.currentUser!.id,
          });
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Device cleanup: Current device revoked successfully');
          }
          _analytics?.logEvent('device_cleanup_success', {
            'context': 'logout',
            'device_uuid': currentDevice.uuid,
            'user_id': currentState.currentUser!.id,
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Device cleanup: Unexpected error during logout cleanup - $e',
        );
      }
      unawaited(
        _analytics?.logEvent('device_cleanup_error', {
              'context': 'logout',
              'error': e.toString(),
              'user_id': currentState.currentUser?.id ?? 'unknown',
            }) ??
            Future.value(),
      );
    }
  }

  /// Delete user account permanently
  Future<bool> deleteAccount({
    required String password,
    bool downloadData = false,
  }) async {
    final currentState = state.valueOrNull ?? const AuthState();

    if (currentState.currentUser == null) {
      state = AsyncValue.data(
        currentState.copyWith(errorMessage: 'Nenhum usuário autenticado'),
      );
      return false;
    }

    state = AsyncValue.data(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        currentOperation: AuthOperation.deleteAccount,
      ),
    );

    try {
      final result = await _enhancedDeletionService.deleteAccount(
        password: password,
        userId: currentState.currentUser!.id,
        isAnonymous: currentState.isAnonymous,
      );

      return result.fold(
        (error) {
          final newState = state.valueOrNull ?? const AuthState();
          state = AsyncValue.data(
            newState.copyWith(
              errorMessage: error.message,
              isLoading: false,
              currentOperation: null,
            ),
          );
          return false;
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _performPostDeletionCleanup();
            return true;
          } else {
            final newState = state.valueOrNull ?? const AuthState();
            state = AsyncValue.data(
              newState.copyWith(
                errorMessage: deletionResult.userMessage,
                isLoading: false,
                currentOperation: null,
              ),
            );
            return false;
          }
        },
      );
    } catch (e) {
      final newState = state.valueOrNull ?? const AuthState();
      state = AsyncValue.data(
        newState.copyWith(
          errorMessage: 'Erro inesperado: $e',
          isLoading: false,
          currentOperation: null,
        ),
      );
      return false;
    }
  }

  /// Perform cleanup after successful account deletion
  Future<void> _performPostDeletionCleanup() async {
    final currentState = state.valueOrNull ?? const AuthState();

    state = AsyncValue.data(
      currentState.withoutUser().copyWith(
        isLoading: false,
        errorMessage: null,
        currentOperation: null,
      ),
    );
    _backgroundSyncNotifier?.resetSyncState();
    _authStateNotifier.updateUser(null);
    _authStateNotifier.updatePremiumStatus(false);
  }

  bool get isSyncInProgress {
    if (_backgroundSyncNotifier == null) return false;
    final syncState = ref.read(backgroundSyncProvider);
    return syncState.isSyncInProgress;
  }

  bool get hasPerformedInitialSync {
    if (_backgroundSyncNotifier == null) return false;
    final syncState = ref.read(backgroundSyncProvider);
    return syncState.hasPerformedInitialSync;
  }

  String get syncMessage {
    if (_backgroundSyncNotifier == null) return 'Sincronizando dados...';
    final syncState = ref.read(backgroundSyncProvider);
    return syncState.currentSyncMessage;
  }
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return GetIt.instance<LoginUseCase>();
}

@riverpod
LogoutUseCase logoutUseCase(Ref ref) {
  return GetIt.instance<LogoutUseCase>();
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  return GetIt.instance<IAuthRepository>();
}

@riverpod
ISubscriptionRepository? subscriptionRepository(Ref ref) {
  try {
    return GetIt.instance<ISubscriptionRepository>();
  } catch (e) {
    return null;
  }
}

@riverpod
ResetPasswordUseCase resetPasswordUseCase(Ref ref) {
  return GetIt.instance<ResetPasswordUseCase>();
}

@riverpod
device_validation.ValidateDeviceUseCase? validateDeviceUseCase(Ref ref) {
  try {
    return GetIt.instance<device_validation.ValidateDeviceUseCase>();
  } catch (e) {
    return null;
  }
}

@riverpod
device_revocation.RevokeDeviceUseCase? revokeDeviceUseCase(Ref ref) {
  try {
    return GetIt.instance<device_revocation.RevokeDeviceUseCase>();
  } catch (e) {
    return null;
  }
}

@riverpod
EnhancedAccountDeletionService enhancedAccountDeletionService(Ref ref) {
  return GetIt.instance<EnhancedAccountDeletionService>();
}

@riverpod
BackgroundSync? backgroundSyncNotifier(Ref ref) {
  try {
    // Return the notifier instance from Riverpod
    return ref.read(backgroundSyncProvider.notifier);
  } catch (e) {
    return null;
  }
}

@riverpod
AnalyticsProvider? analyticsProvider(Ref ref) {
  try {
    return GetIt.instance<AnalyticsProvider>();
  } catch (e) {
    return null;
  }
}
