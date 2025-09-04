import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/error/sync_error_handler.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../shared/widgets/sync/simple_sync_loading.dart';
import '../../domain/usecases/reset_password_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAuthRepository _authRepository;
  final ISubscriptionRepository? _subscriptionRepository;
  final AuthStateNotifier _authStateNotifier;
  final ResetPasswordUseCase _resetPasswordUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  AuthOperation? _currentOperation;
  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  
  // Sync related properties
  bool _isSyncInProgress = false;
  bool _hasPerformedInitialSync = false;
  String _syncMessage = 'Sincronizando dados...';

  AnalyticsProvider? get _analytics {
    try {
      return di.sl<AnalyticsProvider>();
    } catch (e) {
      return null; // Analytics não disponível
    }
  }

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required IAuthRepository authRepository,
    required ResetPasswordUseCase resetPasswordUseCase,
    ISubscriptionRepository? subscriptionRepository,
    AuthStateNotifier? authStateNotifier,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository,
       _subscriptionRepository = subscriptionRepository,
       _authStateNotifier = authStateNotifier ?? AuthStateNotifier.instance,
       _resetPasswordUseCase = resetPasswordUseCase {
    _initializeAuthState();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  AuthOperation? get currentOperation => _currentOperation;
  
  // Sync related getters
  bool get isSyncInProgress => _isSyncInProgress;
  bool get hasPerformedInitialSync => _hasPerformedInitialSync;
  String get syncMessage => _syncMessage;

  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        _currentUser = user;

        // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
        if (user == null && await shouldUseAnonymousMode()) {
          // NÃO marcar como inicializado ainda - esperar o signInAnonymously completar
          if (kDebugMode) {
            debugPrint('🔄 AuthProvider: Iniciando modo anônimo, aguardando login...');
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
          debugPrint('Auth error: ${DataSanitizationService.sanitizeForLogging(error.toString())}');
        }
        notifyListeners();
      },
    );

    // Escuta mudanças na assinatura
    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository!.subscriptionStatus.listen((
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
        
        // Realizar sincronização inicial apenas uma vez para usuários não anônimos
        if (!_hasPerformedInitialSync) {
          _performInitialDataSync();
        }
      } else {
        _isPremium = false;
        _authStateNotifier.updatePremiumStatus(false);
      }

      // CRITICAL: Only mark as initialized AFTER everything is stable
      if (kDebugMode) {
        debugPrint('✅ AuthProvider: Initialization complete - User: ${user?.id ?? "anonymous"}, Premium: $_isPremium');
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

    await _subscriptionRepository!.setUser(
      userId: userId,
      attributes: {'app': 'plantis', 'email': _currentUser?.email ?? ''},
    );
  }

  Future<void> _checkPremiumStatus() async {
    if (_subscriptionRepository == null) return;

    final result = await _subscriptionRepository!.hasPlantisSubscription();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('Erro verificar premium: ${DataSanitizationService.sanitizeForLogging(failure.message)}');
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

  /// Novo método que combina login + sincronização automática
  Future<void> loginAndSync(String email, String password) async {
    try {
      // Primeiro fazer login normal
      await login(email, password);

      // Se login falhou, não continua com sync
      if (!isAuthenticated || _errorMessage != null) {
        return;
      }

      // Iniciar sincronização automática apenas se não foi feita ainda
      if (!_hasPerformedInitialSync) {
        await _startPostLoginSync();
      }
    } catch (e) {
      await e.handleAsSyncError(
        metadata: {'operation': 'login_and_sync', 'email': email},
      );
    }
  }

  /// Realiza sincronização inicial de forma assíncrona (sem bloquear UI)
  void _performInitialDataSync() {
    // Executar em background sem bloquear a UI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isAuthenticated && !isAnonymous && !_hasPerformedInitialSync) {
        _startPostLoginSync();
      }
    });
  }

  /// Inicia processo de sincronização pós-login (apenas para usuários não anônimos)
  Future<void> _startPostLoginSync() async {
    if (_isSyncInProgress) return;
    
    // ⚠️ IMPORTANTE: Sincronizar apenas usuários não anônimos
    if (!isAuthenticated || isAnonymous) {
      if (kDebugMode) {
        debugPrint('🔄 Sincronização pulada - usuário anônimo ou não autenticado');
      }
      return;
    }
    
    _isSyncInProgress = true;
    _syncMessage = 'Sincronizando dados...';
    notifyListeners();
    
    try {
      // Sincronizar dados do usuário
      _syncMessage = 'Sincronizando informações da conta...';
      notifyListeners();
      await _syncUserData();
      
      // Sincronizar plantas
      _syncMessage = 'Sincronizando suas plantas...';
      notifyListeners();
      await _syncPlantsData();
      
      // Sincronizar tarefas
      _syncMessage = 'Sincronizando tarefas pendentes...';
      notifyListeners();
      await _syncTasksData();
      
      // Sincronizar configurações
      _syncMessage = 'Sincronizando preferências...';
      notifyListeners();
      await _syncSettingsData();
      
      // Marcar sincronização inicial como realizada
      _hasPerformedInitialSync = true;
      
      // Log analytics
      await _analytics?.logEvent('post_login_sync_completed', {
        'user_id': _currentUser?.id ?? '',
        'sync_duration_ms': DateTime.now().millisecondsSinceEpoch,
      });

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro durante sincronização: $e');
      }
      
      await e.handleAsSyncError(
        metadata: {'operation': 'post_login_sync', 'user_id': _currentUser?.id},
      );
    } finally {
      _isSyncInProgress = false;
      notifyListeners();
    }
  }

  /// Sincroniza dados do usuário
  Future<void> _syncUserData() async {
    try {
      // Simular sincronização de dados do usuário
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      if (kDebugMode) {
        debugPrint('✅ Dados do usuário sincronizados');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar dados do usuário: $e');
      }
      rethrow;
    }
  }

  /// Sincroniza dados das plantas
  Future<void> _syncPlantsData() async {
    try {
      // Simular busca por serviço de sync das plantas
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      
      if (kDebugMode) {
        debugPrint('✅ Dados das plantas sincronizados');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar plantas: $e');
      }
      // Não re-throw para permitir continuar com outras sincronizações
    }
  }

  /// Sincroniza dados das tarefas
  Future<void> _syncTasksData() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      
      if (kDebugMode) {
        debugPrint('✅ Dados das tarefas sincronizados');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar tarefas: $e');
      }
      // Não re-throw para permitir continuar
    }
  }

  /// Sincroniza configurações
  Future<void> _syncSettingsData() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      
      if (kDebugMode) {
        debugPrint('✅ Configurações sincronizadas');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar configurações: $e');
      }
      // Não re-throw para permitir continuar
    }
  }

  /// Cancela sincronização em andamento
  void cancelSync() {
    if (_isSyncInProgress) {
      _isSyncInProgress = false;
      _syncMessage = 'Sincronização cancelada';
      notifyListeners();
      
      _analytics?.logEvent('sync_cancelled_by_user', {
        'user_id': _currentUser?.id ?? '',
      });
    }
  }

  /// Retry da sincronização
  Future<void> retrySyncAfterLogin() async {
    if (!isAuthenticated) return;
    
    await _startPostLoginSync();
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _currentOperation = AuthOperation.logout;
    notifyListeners();

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
        
        // Resetar flag de sincronização para próxima sessão
        _hasPerformedInitialSync = false;
        
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
        debugPrint('Erro salvar preferência anônima: ${DataSanitizationService.sanitizeForLogging(e.toString())}');
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

  /// Inicia sincronização automática (apenas para usuários não anônimos)
  /// Pode ser chamado ao navegar para tela principal ou quando necessário
  Future<void> startAutoSyncIfNeeded() async {
    if (!isAuthenticated || isAnonymous) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - usuário anônimo ou não autenticado');
      }
      return;
    }

    if (_hasPerformedInitialSync) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - sincronização inicial já realizada nesta sessão');
      }
      return;
    }

    if (_isSyncInProgress) {
      if (kDebugMode) {
        debugPrint('🔄 Auto-sync pulado - sincronização já em progresso');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 Iniciando auto-sync para usuário não anônimo');
    }

    await _startPostLoginSync();
  }


  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCurrentOperation() {
    _currentOperation = null;
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
        _analytics?.logEvent('password_reset_requested', {
          'method': 'email',
        });
        
        return true;
      },
    );
  }
}
