import 'dart:async';

import 'package:core/core.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

import '../../features/analytics/enhanced_analytics_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../di/injection_container.dart' as di;
import '../extensions/user_entity_receituagro_extension.dart';
import '../data/models/user_session_data.dart';
import '../services/device_identity_service.dart';
import '../services/receituagro_data_cleaner.dart';
// sync_orchestrator.dart removed - using UnifiedSyncManager from core package

/// AuthProvider específico do ReceitauAgro
/// Integra com o core package FirebaseAuthService e gerencia estado de autenticação
/// Baseado na implementação bem-sucedida do app-gasometer
class ReceitaAgroAuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final DeviceIdentityService _deviceService;
  final ReceitaAgroAnalyticsService _analytics;
  // Sync now handled by UnifiedSyncManager from core package
  
  StreamSubscription<UserEntity?>? _userSubscription;
  UserEntity? _currentUser;
  UserSessionData? _sessionData;
  bool _isLoading = false;
  String? _errorMessage;

  ReceitaAgroAuthProvider({
    required IAuthRepository authRepository,
    required DeviceIdentityService deviceService,
    required ReceitaAgroAnalyticsService analytics,
  })  : _authRepository = authRepository,
        _deviceService = deviceService,
        _analytics = analytics {
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
        onError: (Object error) {
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
      if (kDebugMode) print('🔄 Auth Provider: Handling device login for user ${user.id}');
      
      // Get current device info
      final deviceInfo = await _deviceService.getDeviceInfo();
      
      // Convert DeviceInfo to DeviceEntity for validation
      final deviceEntity = DeviceEntity(
        id: deviceInfo.uuid,
        uuid: deviceInfo.uuid,
        name: deviceInfo.name,
        model: deviceInfo.model,
        platform: deviceInfo.platform,
        systemVersion: deviceInfo.systemVersion,
        appVersion: deviceInfo.appVersion,
        buildNumber: deviceInfo.buildNumber,
        isPhysicalDevice: deviceInfo.isPhysicalDevice,
        manufacturer: deviceInfo.manufacturer,
        firstLoginAt: deviceInfo.firstLoginAt,
        lastActiveAt: DateTime.now(),
        isActive: true,
      );
      
      // Import SettingsProvider to register device
      final settingsProvider = di.sl<SettingsProvider>();
      await settingsProvider.initialize(user.id);
      
      // Try to add/validate device automatically
      final success = await settingsProvider.addDevice(deviceEntity);
      
      if (success) {
        if (kDebugMode) print('✅ Auth Provider: Device ${deviceInfo.name} registered successfully');
        _analytics.trackDeviceAdded(deviceInfo.platform);
      } else {
        if (kDebugMode) print('⚠️ Auth Provider: Device registration failed or device already exists');
        // Even if registration fails (e.g., device already exists), still track for analytics
        _analytics.trackDeviceAdded(deviceInfo.platform);
      }
      
      // Sincroniza perfil do usuário com Firestore
      await _syncUserProfile(user, deviceInfo);
    } catch (e) {
      if (kDebugMode) print('❌ Auth Provider: Device login handling error - $e');
      // Log error but don't block login process
      _analytics.trackError('device_login_error', e.toString());
    }
  }

  /// Trigger sincronização automática após autenticação bem-sucedida
  /// Preserva dados locais e sincroniza com a nuvem
  Future<void> _triggerPostAuthSync(UserEntity user, UserEntity? previousUser) async {
    try {
      _analytics.trackEvent('post_auth_sync_triggered', parameters: {
        'user_id': user.id,
        'was_anonymous': (previousUser?.isAnonymous ?? false).toString(),
        'new_login': (previousUser?.id != user.id).toString(),
      });

      if (kDebugMode) print('🔄 Auth Provider: Triggering post-authentication sync for user ${user.displayName}');

      // Executar sincronização em background para não bloquear a UI
      unawaited(UnifiedSyncManager.instance.forceSyncApp('receituagro').then((result) {
        result.fold(
          (failure) {
            _analytics.trackEvent('post_auth_sync_failed', parameters: {
              'error': failure.message,
            });
            if (kDebugMode) print('❌ Auth Provider: Post-auth sync failed: ${failure.message}');
          },
          (_) {
            _analytics.trackEvent('post_auth_sync_success', parameters: {
              'sync_completed': 'true',
            });

            if (kDebugMode) {
              print('✅ Auth Provider: Post-auth sync completed successfully');
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
          },
        );
      }).catchError((Object error) {
        _analytics.trackError('post_auth_sync_exception', error.toString());
        if (kDebugMode) print('❌ Auth Provider: Post-auth sync exception: $error');
      }));

    } catch (e) {
      _analytics.trackError('post_auth_sync_trigger_error', e.toString());
      if (kDebugMode) print('❌ Auth Provider: Error triggering post-auth sync: $e');
    }
  }

  /// Força sincronização manual dos dados do usuário
  /// Útil quando o usuário quer garantir que seus dados estão atualizados
  Future<bool> forceSyncUserData() async {
    if (_currentUser == null || _currentUser!.isAnonymous) {
      if (kDebugMode) print('⚠️ Auth Provider: Cannot sync - user not authenticated');
      return false;
    }

    try {
      _analytics.trackEvent('manual_sync_triggered', parameters: {
        'user_id': _currentUser!.id,
        'trigger_source': 'manual_button',
      });

      if (kDebugMode) print('🔄 Auth Provider: Starting manual sync for user ${_currentUser!.displayName}');

      final result = await UnifiedSyncManager.instance.forceSyncApp('receituagro');

      return result.fold(
        (failure) {
          _analytics.trackEvent('manual_sync_failure', parameters: {
            'error': failure.message,
          });
          if (kDebugMode) print('❌ Auth Provider: Manual sync failed: ${failure.message}');
          return false;
        },
        (_) {
          _analytics.trackEvent('manual_sync_success', parameters: {
            'sync_completed': 'true',
          });

          if (kDebugMode) {
            print('✅ Auth Provider: Manual sync completed successfully');
          }
          return true;
        },
      );
    } catch (e) {
      _analytics.trackError('manual_sync_exception', e.toString());
      if (kDebugMode) print('❌ Auth Provider: Manual sync exception: $e');
      return false;
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

  /// Excluir conta do usuário usando o AccountDeletionService do core
  /// Integra com ReceitaAgroDataCleaner para limpeza de dados específicos
  Future<AuthResult> deleteAccount() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('🗑️ ReceitaAgroAuthProvider: Iniciando exclusão de conta');
      }

      _analytics.trackEvent('account_deletion_attempt', parameters: {
        'user_id': _currentUser?.id ?? 'unknown',
        'user_type': userType.toString(),
      });

      // Criar instância do ReceitaAgroDataCleaner
      final dataCleaner = ReceitaAgroDataCleaner();

      // Criar AccountDeletionService com o data cleaner específico
      final accountDeletionService = AccountDeletionService(
        authRepository: _authRepository,
        appDataCleaner: dataCleaner,
      );

      // Executar exclusão completa
      final result = await accountDeletionService.deleteAccount();

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _analytics.trackEvent('account_deletion_failed', parameters: {
            'error': failure.message,
            'user_id': _currentUser?.id ?? 'unknown',
          });

          if (kDebugMode) {
            debugPrint('❌ ReceitaAgroAuthProvider: Exclusão de conta falhou - ${failure.message}');
          }

          return AuthResult.failure(failure.message);
        },
        (deletionResult) {
          _analytics.trackEvent('account_deletion_success', parameters: {
            'user_id': _currentUser?.id ?? 'unknown',
            'firebase_delete_success': deletionResult.firebaseDeleteSuccess.toString(),
            'local_data_cleaned': (deletionResult.localDataCleanupResult?['success'] == true).toString(),
            'data_cleanup_verified': deletionResult.dataCleanupVerified.toString(),
            'total_records_cleared': deletionResult.localDataCleanupResult?['totalRecordsCleared']?.toString() ?? '0',
          });

          if (kDebugMode) {
            debugPrint('✅ ReceitaAgroAuthProvider: Exclusão de conta concluída com sucesso');
            debugPrint('   Firebase: ${deletionResult.firebaseDeleteSuccess ? '✅' : '❌'}');
            debugPrint('   Dados locais: ${deletionResult.localDataCleanupResult?['success'] == true ? '✅' : '⚠️'}');
            debugPrint('   Verificação: ${deletionResult.dataCleanupVerified ? '✅' : '⚠️'}');
          }

          // Clear local state (Firebase auth will trigger user state change automatically)
          _currentUser = null;
          _sessionData = null;
          _errorMessage = null;

          return AuthResult.success(const UserEntity(
            id: 'deleted',
            email: 'deleted@account.com',
            displayName: 'Conta excluída',
            provider: core.AuthProvider.anonymous,
          ));
        },
      );

    } catch (e) {
      _errorMessage = 'Erro inesperado durante exclusão: $e';
      _analytics.trackError('account_deletion_exception', e.toString());

      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroAuthProvider: Erro inesperado durante exclusão - $e');
      }

      return AuthResult.failure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obter preview dos dados que serão excluídos
  /// Útil para mostrar ao usuário o que será removido
  Future<Map<String, dynamic>?> getAccountDeletionPreview() async {
    try {
      if (kDebugMode) {
        debugPrint('📊 ReceitaAgroAuthProvider: Obtendo preview de exclusão');
      }

      final dataCleaner = ReceitaAgroDataCleaner();
      final accountDeletionService = AccountDeletionService(
        authRepository: _authRepository,
        appDataCleaner: dataCleaner,
      );

      final result = await accountDeletionService.getAccountDeletionPreview();

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          if (kDebugMode) {
            debugPrint('❌ ReceitaAgroAuthProvider: Erro ao obter preview - ${failure.message}');
          }
          return null;
        },
        (preview) {
          if (kDebugMode) {
            debugPrint('✅ ReceitaAgroAuthProvider: Preview obtido com sucesso');
            debugPrint('   App: ${preview['appName']}');
            debugPrint('   Dados para limpar: ${preview['hasDataToClear']}');
            debugPrint('   Registros totais: ${preview['dataStats']?['totalRecords'] ?? 0}');
          }
          return preview;
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao obter preview: $e';
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroAuthProvider: Erro inesperado no preview - $e');
      }
      return null;
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

  /// Sincroniza perfil do usuário usando sistema core
  Future<void> _syncUserProfile(UserEntity user, DeviceInfo deviceInfo) async {
    try {
      // Verifica se o usuário é válido para sync
      if (user.id.isEmpty) {
        if (kDebugMode) print('🔄 Auth Provider: User ID inválido - pulando sincronização de perfil');
        return;
      }

      // Cria entidade de sincronização usando UserEntity com extensão
      final profileEntity = user.withReceitaAgroData(
        deviceId: deviceInfo.uuid,
        platform: deviceInfo.platform,
        appVersion: deviceInfo.appVersion,
      ).copyWith(
        updatedAt: DateTime.now(),
        userId: user.id,
      );

      // Executa sincronização - primeiro tenta atualizar, se falhar cria novo
      final updateResult = await UnifiedSyncManager.instance.update<UserEntity>('receituagro', profileEntity.id, profileEntity);
      
      await updateResult.fold(
        (core.Failure failure) async {
          // Se falhou update, tenta criar
          if (kDebugMode) print('Auth Provider: Update falhou, tentando criar: ${failure.message}');
          final createResult = await UnifiedSyncManager.instance.create<UserEntity>('receituagro', profileEntity);
          createResult.fold(
            (core.Failure createFailure) {
              if (kDebugMode) print('❌ Auth Provider: Erro na sincronização de perfil (create): ${createFailure.message}');
              _analytics.trackError('user_profile_sync_error', createFailure.message);
            },
            (String entityId) {
              if (kDebugMode) print('✅ Auth Provider: Perfil do usuário criado com sucesso: $entityId');
            },
          );
        },
        (_) {
          if (kDebugMode) print('✅ Auth Provider: Perfil do usuário atualizado com sucesso');
        },
      );
      
    } catch (e) {
      if (kDebugMode) print('❌ Auth Provider: Erro ao sincronizar perfil do usuário: $e');
      _analytics.trackError('user_profile_sync_error', e.toString());
      // Não relança a exceção para não quebrar o fluxo de login
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