import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/background_sync_provider.dart';
import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../device_management/data/models/device_model.dart';
import '../../../device_management/domain/usecases/revoke_device_usecase.dart'
    as device_revocation;
import '../../../device_management/domain/usecases/validate_device_usecase.dart'
    as device_validation;
import '../../domain/usecases/reset_password_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAuthRepository _authRepository;
  final ISubscriptionRepository? _subscriptionRepository;
  final AuthStateNotifier _authStateNotifier;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final BackgroundSyncProvider? _backgroundSyncProvider;
  final device_validation.ValidateDeviceUseCase? _validateDeviceUseCase;
  final device_revocation.RevokeDeviceUseCase? _revokeDeviceUseCase;
  final EnhancedAccountDeletionService _enhancedDeletionService;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  AuthOperation? _currentOperation;
  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;

  // Device validation state
  bool _isValidatingDevice = false;
  String? _deviceValidationError;
  bool _deviceLimitExceeded = false;

  // Legacy sync properties - will be removed
  // Sync is now handled by BackgroundSyncProvider

  AnalyticsProvider? get _analytics {
    try {
      return di.sl<AnalyticsProvider>();
    } catch (e) {
      return null; // Analytics não disponível
    }
  }

  BackgroundSyncProvider? get _syncProvider {
    try {
      return _backgroundSyncProvider ?? di.sl<BackgroundSyncProvider>();
    } catch (e) {
      return null; // BackgroundSync não disponível
    }
  }

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required IAuthRepository authRepository,
    required ResetPasswordUseCase resetPasswordUseCase,
    required EnhancedAccountDeletionService enhancedAccountDeletionService,
    ISubscriptionRepository? subscriptionRepository,
    AuthStateNotifier? authStateNotifier,
    BackgroundSyncProvider? backgroundSyncProvider,
    device_validation.ValidateDeviceUseCase? validateDeviceUseCase,
    device_revocation.RevokeDeviceUseCase? revokeDeviceUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository,
       _subscriptionRepository = subscriptionRepository,
       _authStateNotifier = authStateNotifier ?? AuthStateNotifier.instance,
       _resetPasswordUseCase = resetPasswordUseCase,
       _backgroundSyncProvider = backgroundSyncProvider,
       _validateDeviceUseCase = validateDeviceUseCase,
       _revokeDeviceUseCase = revokeDeviceUseCase,
       _enhancedDeletionService = enhancedAccountDeletionService {
    _initializeAuthState();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  AuthOperation? get currentOperation => _currentOperation;

  // Device validation getters
  bool get isValidatingDevice => _isValidatingDevice;
  String? get deviceValidationError => _deviceValidationError;
  bool get deviceLimitExceeded => _deviceLimitExceeded;

  // Sync related getters - delegated to BackgroundSyncProvider
  bool get isSyncInProgress => _syncProvider?.isSyncInProgress ?? false;
  bool get hasPerformedInitialSync =>
      _syncProvider?.hasPerformedInitialSync ?? false;
  String get syncMessage =>
      _syncProvider?.currentSyncMessage ?? 'Sincronizando dados...';

  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        _currentUser = user;

        // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
        if (user == null && await shouldUseAnonymousMode()) {
          // NÃO marcar como inicializado ainda - esperar o signInAnonymously completar
          if (kDebugMode) {
            debugPrint(
              '🔄 AuthProvider: Iniciando modo anônimo, aguardando login...',
            );
          }
          await signInAnonymously();
          return; // O signInAnonymously vai disparar este listener novamente
        }

        // CRITICAL FIX: Only set initialized AFTER auth is fully stable
        await _completeAuthInitialization(user);
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        _isInitialized = true;
        _authStateNotifier.updateInitializationStatus(true);
        if (kDebugMode) {
          debugPrint(
            'Auth error: ${DataSanitizationService.sanitizeForLogging(error.toString())}',
          );
        }
        notifyListeners();
      },
    );

    // Escuta mudanças na assinatura
    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository.subscriptionStatus.listen((
        subscription,
      ) {
        _isPremium = subscription?.isActive ?? false;
        _authStateNotifier.updatePremiumStatus(_isPremium);
        notifyListeners();
      });
    }
  }

  /// CRITICAL FIX: Complete auth initialization only after all operations are stable
  Future<void> _completeAuthInitialization(UserEntity? user) async {
    try {
      // Update AuthStateNotifier with user changes
      _authStateNotifier.updateUser(user);

      // Sincroniza com RevenueCat quando o usuário faz login (não anônimo)
      if (user != null && !isAnonymous && _subscriptionRepository != null) {
        await _syncUserWithRevenueCat(user.id);
        await _checkPremiumStatus();

        // Triggar sincronização inicial em background sem bloquear
        _triggerBackgroundSyncIfNeeded(user.id);
      } else {
        _isPremium = false;
        _authStateNotifier.updatePremiumStatus(false);
      }

      // CRITICAL: Only mark as initialized AFTER everything is stable
      if (kDebugMode) {
        debugPrint(
          '✅ AuthProvider: Initialization complete - User: ${user?.id ?? "anonymous"}, Premium: $_isPremium',
        );
      }

      _isInitialized = true;
      _authStateNotifier.updateInitializationStatus(true);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthProvider: Error during initialization: $e');
      }
      _errorMessage = 'Erro na inicialização da autenticação: $e';
      _isInitialized = true; // Still set to true to avoid infinite loading
      _authStateNotifier.updateInitializationStatus(true);
      notifyListeners();
    }
  }

  Future<void> _syncUserWithRevenueCat(String userId) async {
    if (_subscriptionRepository == null) return;

    await _subscriptionRepository.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'email': _currentUser?.email ?? ''},
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
        _isPremium = false;
        _authStateNotifier.updatePremiumStatus(false);
      },
      (hasPremium) {
        _isPremium = hasPremium;
        _authStateNotifier.updatePremiumStatus(hasPremium);
      },
    );
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _subscriptionStream?.cancel();
    // Limpeza de recursos de sync
    super.dispose();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.signIn;
    notifyListeners();

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        _currentOperation = null;

        // Update AuthStateNotifier with new user
        _authStateNotifier.updateUser(user);

        // Log login event
        _analytics?.logLogin('email');

        notifyListeners();
      },
    );
  }

  /// Non-blocking login that triggers background sync and device validation
  Future<void> loginAndNavigate(String email, String password) async {
    try {
      // Primeiro fazer login normal
      await login(email, password);

      // Login bem-sucedido - validar dispositivo e triggar sync
      if (isAuthenticated && !isAnonymous && _errorMessage == null) {
        // Validar dispositivo PRIMEIRO (crítico para segurança)
        await _validateDeviceAfterLogin();

        // Se device validation passou, triggar sync em background
        if (!_deviceLimitExceeded) {
          _triggerBackgroundSyncIfNeeded(_currentUser!.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro durante login: $e');
      }
      // Error is already handled in login() method
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

    _isValidatingDevice = true;
    _deviceValidationError = null;
    _deviceLimitExceeded = false;
    notifyListeners();

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
          _deviceValidationError = failure.message;

          // Se é limite excedido, fazer logout automático
          if (failure.code == 'DEVICE_LIMIT_EXCEEDED') {
            _deviceLimitExceeded = true;
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
            _deviceValidationError = validationResult.message;

            // Se é limite excedido, fazer logout automático
            if (validationResult.status == DeviceValidationStatus.exceeded) {
              _deviceLimitExceeded = true;
              _handleDeviceLimitExceeded();
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro inesperado na validação do dispositivo: $e');
      }
      _deviceValidationError = 'Erro na validação do dispositivo';
    } finally {
      _isValidatingDevice = false;
      notifyListeners();
    }
  }

  /// Handle device limit exceeded - force logout
  Future<void> _handleDeviceLimitExceeded() async {
    if (kDebugMode) {
      debugPrint(
        '🚫 Limite de dispositivos excedido - fazendo logout automático',
      );
    }

    // Log analytics event
    await _analytics?.logEvent('device_limit_exceeded', {
      'user_id': _currentUser?.id ?? 'unknown',
      'device_count': 3, // Limite fixo
    });

    // Force logout after a brief delay to show error message
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_deviceLimitExceeded) {
        logout();
      }
    });
  }

  /// Triggers background sync without blocking UI
  void _triggerBackgroundSyncIfNeeded(String userId) {
    if (_syncProvider == null) {
      if (kDebugMode) {
        debugPrint('⚠️ BackgroundSyncProvider não disponível');
      }
      return;
    }

    // Execute in background without blocking
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isAuthenticated && !isAnonymous) {
        _syncProvider!.startBackgroundSync(userId: userId, isInitialSync: true);
      }
    });
  }

  /// Legacy method - replaced by BackgroundSyncService

  /// Cancela sincronização em andamento
  void cancelSync() {
    _syncProvider?.cancelSync();
  }

  /// Retry da sincronização
  Future<void> retrySyncAfterLogin() async {
    if (!isAuthenticated || _currentUser == null) return;

    await _syncProvider?.retrySync(_currentUser!.id);
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.logout;
    notifyListeners();

    // 1. CRÍTICO: Cleanup do dispositivo atual ANTES do logout
    await _performDeviceCleanupOnLogout();

    // 2. Continuar com logout normal
    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
      (_) {
        _currentUser = null;
        _isLoading = false;
        _currentOperation = null;

        // Resetar estado de sincronização para próxima sessão
        _syncProvider?.resetSyncState();

        // Update AuthStateNotifier with logout
        _authStateNotifier.updateUser(null);
        _authStateNotifier.updatePremiumStatus(false);

        // Log logout event
        _analytics?.logLogout();

        notifyListeners();
      },
    );
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.signUp;
    notifyListeners();

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: name,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        _currentOperation = null;

        // Update AuthStateNotifier with new user
        _authStateNotifier.updateUser(user);

        notifyListeners();
      },
    );
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.anonymous;
    notifyListeners();

    final result = await _authRepository.signInAnonymously();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        _currentOperation = null;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        _currentOperation = null;

        // Update AuthStateNotifier with anonymous user
        _authStateNotifier.updateUser(user);

        // Salvar preferência de modo anônimo
        _saveAnonymousPreference();

        notifyListeners();
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

  bool get isAnonymous => _currentUser?.provider.name == 'anonymous';

  Future<void> initializeAnonymousIfNeeded() async {
    if (!isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }

  /// Inicia sincronização automática em background (não bloqueia UI)
  Future<void> startAutoSyncIfNeeded() async {
    if (!isAuthenticated || isAnonymous || _currentUser == null) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - usuário anônimo ou não autenticado');
      }
      return;
    }

    if (_syncProvider?.shouldStartInitialSync(_currentUser!.id) == true) {
      if (kDebugMode) {
        debugPrint(
          '🔄 Iniciando auto-sync em background para usuário não anônimo',
        );
      }

      await _syncProvider?.startBackgroundSync(
        userId: _currentUser!.id,
        isInitialSync: true,
      );
    } else {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync já realizado ou em progresso');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentOperation() {
    _currentOperation = null;
    notifyListeners();
  }

  /// Clear device validation errors
  void clearDeviceValidationError() {
    _deviceValidationError = null;
    _deviceLimitExceeded = false;
    notifyListeners();
  }

  /// Solicita reset de senha via email
  ///
  /// [email] - Email do usuário para receber o link de reset
  ///
  /// Returns:
  /// - true: Email enviado com sucesso
  /// - false: Erro no envio (verificar errorMessage)
  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    notifyListeners();

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Log evento de reset de senha
        _analytics?.logEvent('password_reset_requested', {'method': 'email'});

        return true;
      },
    );
  }

  /// Realiza cleanup do dispositivo atual durante logout
  ///
  /// Este método remove o dispositivo atual da lista de dispositivos
  /// autorizados no Firestore, garantindo que ele não possa ser usado
  /// novamente sem nova validação.
  ///
  /// IMPORTANTE: Falhas neste processo NÃO devem bloquear o logout,
  /// mas devem ser logadas para auditoria de segurança.
  Future<void> _performDeviceCleanupOnLogout() async {
    if (_revokeDeviceUseCase == null || _currentUser == null || isAnonymous) {
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

      // Obter UUID do dispositivo atual
      final currentDevice = await DeviceModel.fromCurrentDevice();

      // CRITICAL: Verificar se dispositivo é válido (não-Web)
      if (currentDevice == null) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Device cleanup: Skipping device revocation (unsupported platform)',
          );
        }
        return; // Sair sem erro se plataforma não suportada
      }

      // Revogar este dispositivo (permitir self-revoke no logout)
      final revokeResult = await _revokeDeviceUseCase(
        device_revocation.RevokeDeviceParams(
          deviceUuid: currentDevice.uuid,
          preventSelfRevoke: false, // Permitir revogação própria no logout
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

          // Log erro para analytics/monitoring
          _analytics?.logEvent('device_cleanup_failed', {
            'context': 'logout',
            'error': failure.message,
            'device_uuid': currentDevice.uuid,
            'user_id': _currentUser!.id,
          });
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Device cleanup: Current device revoked successfully');
          }

          // Log sucesso para analytics
          _analytics?.logEvent('device_cleanup_success', {
            'context': 'logout',
            'device_uuid': currentDevice.uuid,
            'user_id': _currentUser!.id,
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ Device cleanup: Unexpected error during logout cleanup - $e',
        );
      }

      // Log erro crítico
      _analytics?.logEvent('device_cleanup_error', {
        'context': 'logout',
        'error': e.toString(),
        'user_id': _currentUser?.id ?? 'unknown',
      });
    }
  }

  /// Exclui permanentemente a conta do usuário
  ///
  /// Este método delega para o EnhancedAccountDeletionService que realiza:
  /// 1. Re-autenticação do usuário para confirmar identidade
  /// 2. Exclusão de todos os dados pessoais do Firestore
  /// 3. Cancelamento de assinaturas ativas (RevenueCat)
  /// 4. Limpeza de dados locais (SharedPreferences, cache)
  /// 5. Exclusão da conta do Firebase Auth
  ///
  /// [password] - Senha atual para re-autenticação (obrigatório)
  /// [downloadData] - Se deve fazer backup dos dados antes da exclusão
  ///
  /// Returns:
  /// - true: Conta excluída com sucesso
  /// - false: Erro na exclusão (verificar errorMessage)
  Future<bool> deleteAccount({
    required String password,
    bool downloadData = false,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'Nenhum usuário autenticado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.deleteAccount;
    notifyListeners();

    try {
      // Use Enhanced Account Deletion Service
      final result = await _enhancedDeletionService.deleteAccount(
        password: password,
        userId: _currentUser!.id,
        isAnonymous: isAnonymous,
      );

      return result.fold(
        (error) {
          _errorMessage = error.message;
          _isLoading = false;
          _currentOperation = null;
          notifyListeners();
          return false;
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            // Success - perform logout cleanup
            _performPostDeletionCleanup();
            return true;
          } else {
            _errorMessage = deletionResult.userMessage;
            _isLoading = false;
            _currentOperation = null;
            notifyListeners();
            return false;
          }
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _isLoading = false;
      _currentOperation = null;
      notifyListeners();
      return false;
    }
  }

  /// Realiza cleanup do estado da aplicação após exclusão bem-sucedida
  Future<void> _performPostDeletionCleanup() async {
    _currentUser = null;
    _isPremium = false;
    _isLoading = false;
    _errorMessage = null;
    _currentOperation = null;

    // Resetar estado de sincronização para próxima sessão
    _syncProvider?.resetSyncState();

    // Update AuthStateNotifier
    _authStateNotifier.updateUser(null);
    _authStateNotifier.updatePremiumStatus(false);

    notifyListeners();
  }

}
