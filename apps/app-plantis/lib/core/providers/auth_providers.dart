import 'dart:async';

import 'package:core/core.dart' hide User;
import 'package:flutter/foundation.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/device_management/data/models/device_model.dart';
import '../../features/device_management/domain/usecases/revoke_device_usecase.dart'
    as device_revocation;
import '../../features/device_management/domain/usecases/validate_device_usecase.dart'
    as device_validation;
import '../auth/auth_state_notifier.dart';
import '../di/injection_container.dart' as di;
import '../providers/analytics_provider.dart';
import '../providers/background_sync_provider.dart';
import '../services/data_sanitization_service.dart';
import '../widgets/loading_overlay.dart';

// part 'auth_providers.g.dart';

/// Auth State model for Riverpod state management
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
  bool get hasError => errorMessage != null;

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
    bool clearError = false,
    bool clearUser = false,
    bool clearOperation = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
      isPremium: isPremium ?? this.isPremium,
      currentOperation:
          clearOperation ? null : (currentOperation ?? this.currentOperation),
      isValidatingDevice: isValidatingDevice ?? this.isValidatingDevice,
      deviceValidationError:
          deviceValidationError ?? this.deviceValidationError,
      deviceLimitExceeded: deviceLimitExceeded ?? this.deviceLimitExceeded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          currentUser == other.currentUser &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          isInitialized == other.isInitialized &&
          isPremium == other.isPremium &&
          currentOperation == other.currentOperation &&
          isValidatingDevice == other.isValidatingDevice &&
          deviceValidationError == other.deviceValidationError &&
          deviceLimitExceeded == other.deviceLimitExceeded;

  @override
  int get hashCode =>
      currentUser.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      isInitialized.hashCode ^
      isPremium.hashCode ^
      currentOperation.hashCode ^
      isValidatingDevice.hashCode ^
      deviceValidationError.hashCode ^
      deviceLimitExceeded.hashCode;
}

/// AuthNotifier that wraps AuthStateNotifier to integrate with Riverpod
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthStateNotifier _authStateNotifier;
  late final BackgroundSyncProvider? _backgroundSyncProvider;
  late final device_validation.ValidateDeviceUseCase? _validateDeviceUseCase;
  late final device_revocation.RevokeDeviceUseCase? _revokeDeviceUseCase;
  late final device_revocation.RevokeAllOtherDevicesUseCase?
  _revokeAllOtherDevicesUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final IAuthRepository _authRepository;
  late final ISubscriptionRepository? _subscriptionRepository;
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;

  // Stream subscriptions
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
  Future<AuthState> build() async {
    // Initialize dependencies
    _authStateNotifier = AuthStateNotifier.instance;
    _authRepository = di.sl<IAuthRepository>();
    _loginUseCase = di.sl<LoginUseCase>();
    _logoutUseCase = di.sl<LogoutUseCase>();
    _resetPasswordUseCase = di.sl<ResetPasswordUseCase>();

    try {
      _subscriptionRepository = di.sl<ISubscriptionRepository>();
    } catch (e) {
      _subscriptionRepository = null;
    }

    try {
      _backgroundSyncProvider = di.sl<BackgroundSyncProvider>();
    } catch (e) {
      _backgroundSyncProvider = null;
    }

    try {
      _validateDeviceUseCase = di.sl<device_validation.ValidateDeviceUseCase>();
    } catch (e) {
      _validateDeviceUseCase = null;
    }

    try {
      _revokeDeviceUseCase = di.sl<device_revocation.RevokeDeviceUseCase>();
    } catch (e) {
      _revokeDeviceUseCase = null;
    }

    try {
      _revokeAllOtherDevicesUseCase =
          di.sl<device_revocation.RevokeAllOtherDevicesUseCase>();
    } catch (e) {
      _revokeAllOtherDevicesUseCase = null;
    }

    // Setup cleanup on dispose
    ref.onDispose(() {
      _userSubscription?.cancel();
      _subscriptionStream?.cancel();
    });

    // Initialize auth state
    await _initializeAuthState();

    return const AuthState();
  }

  Future<void> _initializeAuthState() async {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        final currentState = state.valueOrNull ?? const AuthState();

        // Update state with new user
        state = AsyncData(currentState.copyWith(currentUser: user));

        // Handle anonymous mode if needed
        if (user == null && await shouldUseAnonymousMode()) {
          if (kDebugMode) {
            debugPrint(
              '🔄 AuthProvider: Iniciando modo anônimo, aguardando login...',
            );
          }
          await signInAnonymously();
          return;
        }

        // Complete auth initialization
        await _completeAuthInitialization(user);
      },
      onError: (Object error) {
        final currentState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          currentState.copyWith(
            errorMessage: error.toString(),
            isInitialized: true,
          ),
        );
        _authStateNotifier.updateInitializationStatus(true);
        if (kDebugMode) {
          debugPrint(
            'Auth error: ${DataSanitizationService.sanitizeForLogging(error.toString())}',
          );
        }
      },
    );

    // Listen to subscription changes
    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen((
        subscription,
      ) {
        final currentState = state.valueOrNull ?? const AuthState();
        final isPremium = subscription?.isActive ?? false;
        state = AsyncData(currentState.copyWith(isPremium: isPremium));
        _authStateNotifier.updatePremiumStatus(isPremium);
      });
    }
  }

  Future<void> _completeAuthInitialization(UserEntity? user) async {
    try {
      final currentState = state.valueOrNull ?? const AuthState();

      // Update AuthStateNotifier with user changes
      _authStateNotifier.updateUser(user);

      // Sync with RevenueCat when user logs in (not anonymous)
      bool isPremium = false;
      if (user != null && !isAnonymous && _subscriptionRepository != null) {
        await _syncUserWithRevenueCat(user.id);
        await _checkPremiumStatus();
        isPremium = currentState.isPremium;

        // Trigger background sync
        _triggerBackgroundSyncIfNeeded(user.id);
      } else {
        isPremium = false;
        _authStateNotifier.updatePremiumStatus(false);
      }

      // Mark as initialized
      if (kDebugMode) {
        debugPrint(
          '✅ AuthProvider: Initialization complete - User: ${user?.id ?? "anonymous"}, Premium: $isPremium',
        );
      }

      state = AsyncData(
        currentState.copyWith(
          currentUser: user,
          isPremium: isPremium,
          isInitialized: true,
          clearError: true,
        ),
      );
      _authStateNotifier.updateInitializationStatus(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthProvider: Error during initialization: $e');
      }
      final currentState = state.valueOrNull ?? const AuthState();
      state = AsyncData(
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

    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {
        'app': 'plantis',
        'email': state.value?.currentUser?.email ?? '',
      },
    );
  }

  Future<void> _checkPremiumStatus() async {
    if (_subscriptionRepository == null) return;

    final result = await _subscriptionRepository.hasPlantisSubscription();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            'Erro verificar premium: ${DataSanitizationService.sanitizeForLogging(failure.message)}',
          );
        }
        final currentState = state.valueOrNull ?? const AuthState();
        state = AsyncData(currentState.copyWith(isPremium: false));
        _authStateNotifier.updatePremiumStatus(false);
      },
      (hasPremium) {
        final currentState = state.valueOrNull ?? const AuthState();
        state = AsyncData(currentState.copyWith(isPremium: hasPremium));
        _authStateNotifier.updatePremiumStatus(hasPremium);
      },
    );
  }

  void _triggerBackgroundSyncIfNeeded(String userId) {
    if (_syncProvider == null) {
      if (kDebugMode) {
        debugPrint('⚠️ BackgroundSyncProvider não disponível');
      }
      return;
    }

    // Execute in background without blocking
    Future.delayed(const Duration(milliseconds: 100), () {
      final currentState = state.valueOrNull;
      if (currentState?.isAuthenticated == true && !isAnonymous) {
        _syncProvider!.startBackgroundSync(userId: userId, isInitialSync: true);
      }
    });
  }

  bool get isAnonymous =>
      state.value?.currentUser?.provider.name == 'anonymous';

  // Public methods
  Future<void> login(String email, String password) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentOperation: AuthOperation.signIn,
        clearError: true,
      ),
    );

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
          ),
        );

        // Update AuthStateNotifier with new user
        _authStateNotifier.updateUser(user);

        // Log login event
        _analytics?.logLogin('email');
      },
    );
  }

  Future<void> loginAndNavigate(String email, String password) async {
    try {
      // First do normal login
      await login(email, password);

      final currentState = state.valueOrNull;
      // Login successful - validate device and trigger sync
      if (currentState?.isAuthenticated == true &&
          !isAnonymous &&
          currentState?.errorMessage == null) {
        // Validate device FIRST (critical for security)
        await _validateDeviceAfterLogin();

        // If device validation passed, trigger sync in background
        if (currentState?.deviceLimitExceeded != true) {
          _triggerBackgroundSyncIfNeeded(currentState!.currentUser!.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro durante login: $e');
      }
      // Error is already handled in login() method
    }
  }

  Future<void> _validateDeviceAfterLogin() async {
    if (_validateDeviceUseCase == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Device validation não disponível');
      }
      return;
    }

    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
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

      final result = await _validateDeviceUseCase.call();

      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Device validation falhou: ${failure.message}');
          }
          final newState = state.valueOrNull ?? const AuthState();
          state = AsyncData(
            newState.copyWith(
              deviceValidationError: failure.message,
              isValidatingDevice: false,
            ),
          );

          // If device limit exceeded, force logout
          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
            final updatedState = state.valueOrNull ?? const AuthState();
            state = AsyncData(updatedState.copyWith(deviceLimitExceeded: true));
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
            state = AsyncData(
              newState.copyWith(
                deviceValidationError: validationResult.message,
              ),
            );

            // If device limit exceeded, force logout
            if (validationResult.status == DeviceValidationStatus.exceeded) {
              final updatedState = state.valueOrNull ?? const AuthState();
              state = AsyncData(
                updatedState.copyWith(deviceLimitExceeded: true),
              );
              _handleDeviceLimitExceeded();
            }
          }

          final finalState = state.valueOrNull ?? const AuthState();
          state = AsyncData(finalState.copyWith(isValidatingDevice: false));
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro inesperado na validação do dispositivo: $e');
      }
      final newState = state.valueOrNull ?? const AuthState();
      state = AsyncData(
        newState.copyWith(
          deviceValidationError: 'Erro na validação do dispositivo',
          isValidatingDevice: false,
        ),
      );
    }
  }

  Future<void> _handleDeviceLimitExceeded() async {
    if (kDebugMode) {
      debugPrint(
        '🚫 Limite de dispositivos excedido - fazendo logout automático',
      );
    }

    // Log analytics event
    await _analytics?.logEvent('device_limit_exceeded', {
      'user_id': state.value?.currentUser?.id ?? 'unknown',
      'device_count': 3,
    });

    // Force logout after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      final currentState = state.valueOrNull;
      if (currentState?.deviceLimitExceeded == true) {
        logout();
      }
    });
  }

  Future<void> logout() async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentOperation: AuthOperation.logout,
        clearError: true,
      ),
    );

    // Device cleanup before logout
    await _performDeviceCleanupOnLogout();

    // Continue with logout
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (_) {
        state = const AsyncData(AuthState());

        // Reset sync state
        _syncProvider?.resetSyncState();

        // Update AuthStateNotifier
        _authStateNotifier.updateUser(null);
        _authStateNotifier.updatePremiumStatus(false);

        // Log logout event
        _analytics?.logLogout();
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentOperation: AuthOperation.signUp,
        clearError: true,
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
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
          ),
        );

        // Update AuthStateNotifier
        _authStateNotifier.updateUser(user);
      },
    );
  }

  Future<void> signInAnonymously() async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentOperation: AuthOperation.anonymous,
        clearError: true,
      ),
    );

    final result = await _authRepository.signInAnonymously();

    result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
          ),
        );

        // Update AuthStateNotifier
        _authStateNotifier.updateUser(user);

        // Save anonymous preference
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

  Future<bool> resetPassword(String email) async {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(currentState.copyWith(clearError: true));

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        final newState = state.valueOrNull ?? const AuthState();
        state = AsyncData(newState.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) {
        // Log event
        _analytics?.logEvent('password_reset_requested', {'method': 'email'});

        return true;
      },
    );
  }

  void clearError() {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(currentState.copyWith(clearError: true));
  }

  void clearDeviceValidationError() {
    final currentState = state.valueOrNull ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        deviceValidationError: null,
        deviceLimitExceeded: false,
      ),
    );
  }

  // Device cleanup methods (simplified versions)
  Future<void> _performDeviceCleanupOnLogout() async {
    if (_revokeDeviceUseCase == null ||
        state.value?.currentUser == null ||
        isAnonymous) {
      return;
    }

    try {
      final currentDevice = await DeviceModel.fromCurrentDevice();

      // CRITICAL: Skip if platform not supported (Web, etc)
      if (currentDevice == null) {
        return;
      }

      final revokeResult = await _revokeDeviceUseCase.call(
        device_revocation.RevokeDeviceParams(
          deviceUuid: currentDevice.uuid,
          preventSelfRevoke: false,
          reason: 'User logout',
        ),
      );

      revokeResult.fold(
        (failure) {
          _analytics?.logEvent('device_cleanup_failed', {
            'context': 'logout',
            'error': failure.message,
            'device_uuid': currentDevice.uuid,
            'user_id': state.value!.currentUser!.id,
          });
        },
        (_) {
          _analytics?.logEvent('device_cleanup_success', {
            'context': 'logout',
            'device_uuid': currentDevice.uuid,
            'user_id': state.value!.currentUser!.id,
          });
        },
      );
    } catch (e) {
      _analytics?.logEvent('device_cleanup_error', {
        'context': 'logout',
        'error': e.toString(),
        'user_id': state.value?.currentUser?.id ?? 'unknown',
      });
    }
  }
}

/// Main Auth provider using standard Riverpod
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Legacy compatibility providers
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (AuthState state) => state.currentUser,
    orElse: () => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (AuthState state) => state.isAuthenticated,
    orElse: () => false,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (AuthState state) => state.isLoading,
    orElse: () => false,
  );
});

final isPremiumProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (AuthState state) => state.isPremium,
    orElse: () => false,
  );
});

final isInitializedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (AuthState state) => state.isInitialized,
    orElse: () => false,
  );
});
