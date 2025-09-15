import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/analytics/analytics_service.dart';
import '../models/user_session_data.dart';
import '../services/device_identity_service.dart';
import '../services/sync_orchestrator.dart';

/// AuthProvider específico do ReceitauAgro
/// Integra com o core package FirebaseAuthService e gerencia estado de autenticação
/// Baseado na implementação bem-sucedida do app-gasometer
class ReceitaAgroAuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final DeviceIdentityService _deviceService;
  final ReceitaAgroAnalyticsService _analytics;
  final SyncOrchestrator? _syncOrchestrator;
  
  StreamSubscription<UserEntity?>? _userSubscription;
  UserEntity? _currentUser;
  UserSessionData? _sessionData;
  bool _isLoading = false;
  String? _errorMessage;

  ReceitaAgroAuthProvider({
    required IAuthRepository authRepository,
    required DeviceIdentityService deviceService,
    required ReceitaAgroAnalyticsService analytics,
    SyncOrchestrator? syncOrchestrator,
  })  : _authRepository = authRepository,
        _deviceService = deviceService,
        _analytics = analytics,
        _syncOrchestrator = syncOrchestrator {
    _initializeAuthProvider();
  }

  // ===== GETTERS =====
  UserEntity? get currentUser => _currentUser;
  UserSessionData? get sessionData => _sessionData;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isAnonymous;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // User type based on authentication state
  UserType get userType {
    if (!isAuthenticated) return UserType.guest;
    // TODO: Integrate with Premium service to determine premium status
    return UserType.registered;
  }

  // ===== INITIALIZATION =====
  
  Future<void> _initializeAuthProvider() async {
    try {
      // Ouvir mudanças no estado de autenticação
      _userSubscription = _authRepository.currentUser.listen(
        _handleUserStateChange,
        onError: (error) {
          if (kDebugMode) print('❌ Auth Provider: Error in user stream - $error');
          _errorMessage = 'Erro na autenticação: $error';
          notifyListeners();
        },
      );

      // Verificar se já existe usuário logado
      final isLoggedIn = await _authRepository.isLoggedIn;
      if (isLoggedIn && _currentUser != null) {
        await _initializeUserSession(_currentUser!);
      }
      
      if (kDebugMode) print('✅ Auth Provider: Initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Auth Provider: Initialization error - $e');
      _errorMessage = 'Erro na inicialização: $e';
      notifyListeners();
    }
  }

  Future<void> _handleUserStateChange(UserEntity? user) async {
    final previousUser = _currentUser;
    _currentUser = user;

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

    notifyListeners();
  }

  Future<void> _initializeUserSession(UserEntity user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Generate session data
      final deviceId = await _deviceService.getDeviceUuid();
      _sessionData = UserSessionData(
        userId: user.id,
        deviceId: deviceId,
        loginTime: DateTime.now(),
        isAnonymous: user.isAnonymous,
      );

      // Set analytics user properties
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties(
        userType: _mapToAnalyticsUserType(userType),
        isPremium: false, // TODO: Check premium status
        deviceCount: 1, // TODO: Get actual device count
      );

      // Migration removed - functionality not in use

      _errorMessage = null;
      if (kDebugMode) print('✅ Auth Provider: User session initialized for ${user.displayName}');
    } catch (e) {
      _errorMessage = 'Erro na inicialização da sessão: $e';
      if (kDebugMode) print('❌ Auth Provider: Session initialization error - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearUserSession() async {
    _sessionData = null;
    _errorMessage = null;
    
    // Clear analytics
    await _analytics.clearUser();
    
    if (kDebugMode) print('✅ Auth Provider: Session cleared');
  }

  Future<void> _handleDeviceLogin(UserEntity user) async {
    try {
      // TODO: Implement device limit validation
      // This will be implemented in Sprint 4
      _analytics.trackDeviceAdded('mobile'); // TODO: Get actual platform from device service
    } catch (e) {
      if (kDebugMode) print('❌ Auth Provider: Device login handling error - $e');
    }
  }

  /// Trigger sincronização automática após autenticação bem-sucedida
  /// Preserva dados locais e sincroniza com a nuvem
  Future<void> _triggerPostAuthSync(UserEntity user, UserEntity? previousUser) async {
    if (_syncOrchestrator == null) {
      if (kDebugMode) print('⚠️ Auth Provider: SyncOrchestrator not available, skipping post-auth sync');
      return;
    }

    try {
      _analytics.trackEvent('post_auth_sync_triggered', parameters: {
        'user_id': user.id,
        'was_anonymous': (previousUser?.isAnonymous ?? false).toString(),
        'new_login': (previousUser?.id != user.id).toString(),
      });

      if (kDebugMode) print('🔄 Auth Provider: Triggering post-authentication sync for user ${user.displayName}');

      // Executar sincronização em background para não bloquear a UI
      _syncOrchestrator!.performFullSync().then((result) {
        if (result.success) {
          _analytics.trackEvent('post_auth_sync_success', parameters: {
            'operations_sent': result.operationsSent.toString(),
            'operations_received': result.operationsReceived.toString(),
            'conflicts': result.conflicts.length.toString(),
          });

          if (kDebugMode) {
            print('✅ Auth Provider: Post-auth sync completed successfully');
            print('   - Operations sent: ${result.operationsSent}');
            print('   - Operations received: ${result.operationsReceived}');
            print('   - Conflicts: ${result.conflicts.length}');
          }

          // Se havia dados de usuário anônimo e agora está logado, 
          // garantir que os dados foram preservados
          if (previousUser?.isAnonymous == true && !user.isAnonymous) {
            _analytics.trackEvent('anonymous_to_authenticated_migration', parameters: {
              'previous_user_id': previousUser?.id ?? 'unknown',
              'new_user_id': user.id,
              'migration_result': 'success',
            });

            if (kDebugMode) print('✅ Auth Provider: Anonymous to authenticated migration completed');
          }
        } else {
          _analytics.trackEvent('post_auth_sync_failed', parameters: {
            'error': result.message ?? 'unknown',
          });

          if (kDebugMode) print('❌ Auth Provider: Post-auth sync failed: ${result.message}');
        }
      }).catchError((error) {
        _analytics.trackError('post_auth_sync_exception', error.toString());
        if (kDebugMode) print('❌ Auth Provider: Post-auth sync exception: $error');
      });

    } catch (e) {
      _analytics.trackError('post_auth_sync_trigger_error', e.toString());
      if (kDebugMode) print('❌ Auth Provider: Error triggering post-auth sync: $e');
    }
  }

  // ===== AUTHENTICATION METHODS =====

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _analytics.trackAuthFunnelStep('login_attempt');

      final result = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _analytics.trackError('auth_login', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackAuthFunnelStep('login_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _analytics.trackError('auth_login', e.toString());
      return AuthResult.failure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _analytics.trackAuthFunnelStep('signup_attempt');

      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
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
      _errorMessage = 'Erro inesperado: $e';
      _analytics.trackError('auth_signup', e.toString());
      return AuthResult.failure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signInAnonymously() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authRepository.signInAnonymously();

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackLogin('anonymous');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      return AuthResult.failure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (!isAnonymous) {
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
          _errorMessage = failure.message;
          _analytics.trackError('auth_upgrade', failure.message);
          return AuthResult.failure(failure.message);
        },
        (user) {
          _analytics.trackAuthFunnelStep('anonymous_upgrade_success');
          return AuthResult.success(user);
        },
      );
    } catch (e) {
      _errorMessage = 'Erro inesperado: $e';
      _analytics.trackError('auth_upgrade', e.toString());
      return AuthResult.failure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authRepository.signOut();
      
      result.fold(
        (failure) => _errorMessage = failure.message,
        (_) {
          _analytics.trackLogout('user_action');
          // Sign in anonymously after logout to maintain app functionality
          signInAnonymously();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authRepository.sendPasswordResetEmail(email: email);
      
      result.fold(
        (failure) => _errorMessage = failure.message,
        (_) {
          _errorMessage = null;
          _analytics.trackEvent('password_reset_sent');
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao enviar email: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== UTILITY METHODS =====

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool canAccessFeature(String feature) {
    if (!isAuthenticated) return false;
    
    // TODO: Integrate with Premium service
    // For now, all authenticated users have access
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

enum UserType { guest, registered, premium }

// Extension to check if UserEntity is anonymous
extension UserEntityExtensions on UserEntity {
  bool get isAnonymous => provider.toString() == 'anonymous';
}

/// Alias for compatibility (different from core.AuthProvider enum)
typedef AuthProvider = ReceitaAgroAuthProvider;