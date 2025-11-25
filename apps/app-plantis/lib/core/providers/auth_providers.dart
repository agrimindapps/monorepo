import 'dart:async';

import 'package:core/core.dart' hide Column, User;
import 'package:flutter/foundation.dart';

import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/device_management/data/models/device_model.dart';
import '../../features/device_management/domain/usecases/revoke_device_usecase.dart'
    as device_revocation;
import '../../features/device_management/domain/usecases/validate_device_usecase.dart'
    as device_validation;
import '../../features/device_management/presentation/providers/device_management_providers.dart'
    as device_management_providers;
import '../auth/auth_state_notifier.dart';
import 'auth_state_provider.dart';
export 'auth_state_provider.dart';
import '../services/data_sanitization_service.dart';
import 'repository_providers.dart';

part 'auth_providers.g.dart';

enum AuthOperation {
  signIn,
  signUp,
  logout,
  anonymous,
}

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
      currentOperation: clearOperation
          ? null
          : (currentOperation ?? this.currentOperation),
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
///
/// Manages authentication state using @riverpod code generation
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late final AuthStateNotifier _authStateNotifier;
  late final device_validation.ValidateDeviceUseCase? _validateDeviceUseCase;
  late final device_revocation.RevokeDeviceUseCase? _revokeDeviceUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final IAuthRepository _authRepository;
  late final ISubscriptionRepository? _subscriptionRepository;
  late final LoginUseCase _loginUseCase;
  late final LogoutUseCase _logoutUseCase;
  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;

  // AnalyticsProvider removed - using Riverpod providers instead

  @override
  Future<AuthState> build() async {
    _authStateNotifier = AuthStateNotifier.instance;
    _authRepository = ref.watch(authRepositoryProvider);
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);
    _subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
    _validateDeviceUseCase = await ref.watch(device_management_providers.validateDeviceUseCaseProvider.future);
    _revokeDeviceUseCase = await ref.watch(device_management_providers.revokeDeviceUseCaseProvider.future);

    ref.onDispose(() {
      _userSubscription?.cancel();
      _subscriptionStream?.cancel();
    });

    await _initializeAuthState();

    return const AuthState();
  }

  Future<void> _initializeAuthState() async {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        final currentState = state.value ?? const AuthState();
        state = AsyncData(currentState.copyWith(currentUser: user));

        if (user == null && await shouldUseAnonymousMode()) {
          if (kDebugMode) {
            debugPrint(
              '🔄 AuthProvider: Iniciando modo anônimo, aguardando login...',
            );
          }
          await signInAnonymously();
          return;
        }

        await _completeAuthInitialization(user);
      },
      onError: (Object error) {
        final currentState = state.value ?? const AuthState();
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

    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen((
        subscription,
      ) {
        final currentState = state.value ?? const AuthState();
        final isPremium = subscription?.isActive ?? false;
        state = AsyncData(currentState.copyWith(isPremium: isPremium));
        _authStateNotifier.updatePremiumStatus(isPremium);
      });
    }
  }

  Future<void> _completeAuthInitialization(UserEntity? user) async {
    try {
      final currentState = state.value ?? const AuthState();
      _authStateNotifier.updateUser(user);

      bool isPremium = false;
      if (user != null && !isAnonymous && _subscriptionRepository != null) {
        await _syncUserWithRevenueCat(user.id);
        await _checkPremiumStatus();
        isPremium = currentState.isPremium;
        _triggerBackgroundSyncIfNeeded(user.id);
      } else {
        isPremium = false;
        _authStateNotifier.updatePremiumStatus(false);
      }

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

      final currentState = state.value ?? const AuthState();
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
        final currentState = state.value ?? const AuthState();
        state = AsyncData(currentState.copyWith(isPremium: false));
        _authStateNotifier.updatePremiumStatus(false);
      },
      (hasPremium) {
        final currentState = state.value ?? const AuthState();
        state = AsyncData(currentState.copyWith(isPremium: hasPremium));
        _authStateNotifier.updatePremiumStatus(hasPremium);
      },
    );
  }

  void _triggerBackgroundSyncIfNeeded(String userId) {
    if (kDebugMode) {
      debugPrint('ℹ️ Background sync trigger - use backgroundSyncProvider');
    }
  }

  bool get isAnonymous =>
      state.value?.currentUser?.provider.name == 'anonymous';

  Future<void> login(String email, String password) async {
    final currentState = state.value ?? const AuthState();
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
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
          ),
        );
        _authStateNotifier.updateUser(user);
        
      },
    );
  }

  Future<void> loginAndNavigate(String email, String password) async {
    try {
      await login(email, password);

      final currentState = state.value;
      if (currentState?.isAuthenticated == true &&
          !isAnonymous &&
          currentState?.errorMessage == null) {
        await _validateDeviceAfterLogin();

        if (currentState?.deviceLimitExceeded != true) {
          _triggerBackgroundSyncIfNeeded(currentState!.currentUser!.id);
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

    final currentState = state.value ?? const AuthState();
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

          final newState = state.value ?? const AuthState();
          state = AsyncData(
            newState.copyWith(
              deviceValidationError: failure.message,
              isValidatingDevice: false,
            ),
          );

          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
            final updatedState = state.value ?? const AuthState();
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

            final newState = state.value ?? const AuthState();
            state = AsyncData(
              newState.copyWith(
                deviceValidationError: validationResult.message,
              ),
            );

            if (validationResult.status == DeviceValidationStatus.exceeded) {
              final updatedState = state.value ?? const AuthState();
              state = AsyncData(
                updatedState.copyWith(deviceLimitExceeded: true),
              );
              _handleDeviceLimitExceeded();
            }
          }

          final finalState = state.value ?? const AuthState();
          state = AsyncData(finalState.copyWith(isValidatingDevice: false));
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro inesperado na validação do dispositivo: $e');
      }

      final newState = state.value ?? const AuthState();
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      final currentState = state.value;
      if (currentState?.deviceLimitExceeded == true) {
        logout();
      }
    });
  }

  Future<void> logout() async {
    final currentState = state.value ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        isLoading: true,
        currentOperation: AuthOperation.logout,
        clearError: true,
      ),
    );

    await _performDeviceCleanupOnLogout();

    // Clear sync data before logout
    await _clearSyncDataOnLogout();

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        final newState = state.value ?? const AuthState();
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
        _authStateNotifier.updateUser(null);
        _authStateNotifier.updatePremiumStatus(false);
        
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    final currentState = state.value ?? const AuthState();
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
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
          ),
        );
        _authStateNotifier.updateUser(user);
      },
    );
  }

  Future<void> signInAnonymously() async {
    final currentState = state.value ?? const AuthState();
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
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            errorMessage: failure.message,
            isLoading: false,
            clearOperation: true,
          ),
        );
      },
      (user) {
        final newState = state.value ?? const AuthState();
        state = AsyncData(
          newState.copyWith(
            currentUser: user,
            isLoading: false,
            clearOperation: true,
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

  Future<bool> resetPassword(String email) async {
    final currentState = state.value ?? const AuthState();
    state = AsyncData(currentState.copyWith(clearError: true));

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        final newState = state.value ?? const AuthState();
        state = AsyncData(newState.copyWith(errorMessage: failure.message));
        return false;
      },
      (_) {
        
        return true;
      },
    );
  }

  void clearError() {
    final currentState = state.value ?? const AuthState();
    state = AsyncData(currentState.copyWith(clearError: true));
  }

  void clearDeviceValidationError() {
    final currentState = state.value ?? const AuthState();
    state = AsyncData(
      currentState.copyWith(
        deviceValidationError: null,
        deviceLimitExceeded: false,
      ),
    );
  }

  Future<void> _performDeviceCleanupOnLogout() async {
    if (_revokeDeviceUseCase == null ||
        state.value?.currentUser == null ||
        isAnonymous) {
      return;
    }

    try {
      final currentDevice = await DeviceModel.fromCurrentDevice();
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
          if (kDebugMode) {
            debugPrint('Failed to revoke device on logout: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('Device revoked successfully on logout');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during device cleanup: $e');
      }
    }
  }

  /// Clear sync data on logout
  /// Similar ao padrão do Gasometer e ReceitaAgro
  Future<void> _clearSyncDataOnLogout() async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Clearing sync data on logout...');
      }

      // Usar UnifiedSyncManager para limpar dados locais do app
      final result = await UnifiedSyncManager.instance.clearAppData('plantis');

      result.fold(
        (Failure failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to clear sync data: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Sync data cleared successfully');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing sync data: $e');
      }
    }
  }
}

/// Legacy compatibility providers
@riverpod
UserEntity? currentUser(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.currentUser,
    orElse: () => null,
  );
}

@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.isAuthenticated,
    orElse: () => false,
  );
}

@riverpod
bool isLoading(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.isLoading,
    orElse: () => false,
  );
}

@riverpod
bool isPremium(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.isPremium,
    orElse: () => false,
  );
}

@riverpod
bool isInitialized(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.isInitialized,
    orElse: () => false,
  );
}

/// Alias for backwards compatibility with existing code
/// Use authProvider instead in new code
const authNotifierProvider = authProvider;
