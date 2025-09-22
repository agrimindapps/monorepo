import 'dart:async';

import 'package:core/core.dart' hide Failure, UseCase, NoParamsUseCase, AuthenticationFailure, NetworkFailure, ServerFailure, ValidationFailure, UserEntity, AuthProvider;
import 'package:core/core.dart' as core show UserEntity, AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart' as gasometer_entity;
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/auth_rate_limiter.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/widgets/logout_loading_dialog.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/watch_auth_state.dart';
import '../../data/datasources/auth_local_data_source.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final GetCurrentUser _getCurrentUser;
  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final DeleteAccount _deleteAccount;
  final UpdateProfile _updateProfile;
  final SendPasswordReset _sendPasswordReset;
  final AnalyticsService _analytics;
  final PlatformService _platformService;
  final AuthRateLimiter _rateLimiter;
  final AuthLocalDataSource _authLocalDataSource;
  
  // MonorepoAuthCache instance for cross-module security
  final MonorepoAuthCache _monorepoAuthCache = MonorepoAuthCache();
  
  gasometer_entity.UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  StreamSubscription<void>? _authStateSubscription;
  
  // Flags de sincronização simplificadas
  bool _isSyncing = false;
  
  // SECURITY + UX FIX: Flag to prevent automatic anonymous login during active login attempts
  bool _isInLoginAttempt = false;
  
  AuthProvider({
    required GetCurrentUser getCurrentUser,
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required DeleteAccount deleteAccount,
    required UpdateProfile updateProfile,
    required SendPasswordReset sendPasswordReset,
    required AnalyticsService analytics,
    required PlatformService platformService,
    required AuthRateLimiter rateLimiter,
    required AuthLocalDataSource authLocalDataSource,
  })  : _getCurrentUser = getCurrentUser,
        _watchAuthState = watchAuthState,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _deleteAccount = deleteAccount,
        _updateProfile = updateProfile,
        _sendPasswordReset = sendPasswordReset,
        _analytics = analytics,
        _platformService = platformService,
        _rateLimiter = rateLimiter,
        _authLocalDataSource = authLocalDataSource {
    _initializeAuthState();
    // Initialize MonorepoAuthCache for cross-module security
    _initializeMonorepoAuthCache();
  }
  
  gasometer_entity.UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  String? get userDisplayName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;
  String get userId => _currentUser?.id ?? '';
  
  // Getters para sync progress simplificados
  bool get isSyncing => _isSyncing;
  bool get isSyncInProgress => _isSyncing; // Alias para compatibilidade com app-plantis
  String get syncMessage => 'Sincronizando dados automotivos...';
  
  /// Obtém informações sobre o rate limiting de login
  Future<AuthRateLimitInfo> getRateLimitInfo() => _rateLimiter.getRateLimitInfo();
  
  /// Verifica se pode tentar fazer login (não está em lockout)
  Future<bool> canAttemptLogin() => _rateLimiter.canAttemptLogin();
  
  /// Reset do rate limiting (apenas para desenvolvimento/admin)
  Future<void> resetRateLimit() => _rateLimiter.resetRateLimit();
  
  /// Initialize MonorepoAuthCache for cross-module security
  Future<void> _initializeMonorepoAuthCache() async {
    try {
      await _monorepoAuthCache.initialize();
      if (kDebugMode) {
        debugPrint('🔐 MonorepoAuthCache inicializado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erro ao inicializar MonorepoAuthCache: $e');
      }
    }
  }
  
  Future<void> _initializeAuthState() async {
    if (kDebugMode) {
      debugPrint('🔐 Iniciando inicialização do AuthState...');
    }
    
    try {
      // Get current user first
      if (kDebugMode) {
        debugPrint('🔐 Obtendo usuário atual...');
      }
      
      final result = await _getCurrentUser();
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('🔐 Falha ao obter usuário: ${failure.message}');
          }
          _errorMessage = _mapFailureToMessage(failure);
          _isInitialized = true;
          notifyListeners();
        },
        (user) async {
          if (kDebugMode) {
            debugPrint('🔐 Usuário obtido: ${user?.id ?? 'null'}');
          }
          
          _currentUser = _convertFromCoreUser(user);
          _isInitialized = true;
          
          if (user != null) {
            if (kDebugMode) {
              debugPrint('🔐 Configurando sessão para usuário existente');
            }
            await _setupUserSession(_currentUser);
          } else {
            // If no user and should use anonymous mode, initialize anonymously
            final shouldUseAnonymous = await shouldUseAnonymousMode();
            if (kDebugMode) {
              debugPrint('🔐 Usuário nulo. Deve usar anônimo? $shouldUseAnonymous (Platform: web=${_platformService.isWeb}, mobile=${_platformService.isMobile}, isInLoginAttempt=${_isInLoginAttempt})');
            }
            
            if (shouldUseAnonymous) {
              if (kDebugMode) {
                debugPrint('🔐 Iniciando modo anônimo automaticamente');
              }
              await signInAnonymously();
              return;
            }
          }
          
          if (kDebugMode) {
            debugPrint('🔐 AuthState inicializado com sucesso. Usuário autenticado: $isAuthenticated');
          }
          notifyListeners();
        },
      );
      
      // Watch for auth state changes
      _authStateSubscription = _watchAuthState().listen((result) {
        result.fold(
          (failure) {
            _errorMessage = _mapFailureToMessage(failure);
            notifyListeners();
          },
          (user) async {
            _currentUser = _convertFromCoreUser(user);
            
            if (user != null) {
              await _setupUserSession(_currentUser);
            } else {
              _isPremium = false;
            }
            
            notifyListeners();
          },
        );
      });
    } catch (e) {
      _errorMessage = 'Erro ao inicializar autenticação: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> _setupUserSession(gasometer_entity.UserEntity? user) async {
    if (user == null) return;
    try {
      if (user.isAnonymous) {
        if (kDebugMode) {
        debugPrint('🔐 Usuário anônimo logado');
      }
        _isPremium = false;
        return;
      }
      
      // For registered users, set up analytics and check premium
      // Note: Only setting user ID for analytics, not logging sensitive info
      await _analytics.setUserId(user.id);
      await _analytics.setUserProperties({
        'user_type': user.isAnonymous ? 'anonymous' : 'authenticated',
        'is_premium': _isPremium.toString(),
      });
      
      // Check premium status (simplified - in a real app you'd have a use case for this)
      _isPremium = user.isPremium;
    } catch (e) {
      debugPrint('Erro ao configurar sessão do usuário: $e');
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (failure is ServerFailure) {
      return 'Erro do servidor. Tente novamente mais tarde.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }
  
  
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isInLoginAttempt = true; // SECURITY + UX FIX: Mark that we're in an active login attempt
    notifyListeners();
    
    try {
      // Verifica rate limiting antes de tentar login
      final canAttempt = await _rateLimiter.canAttemptLogin();
      if (!canAttempt) {
        final rateLimitInfo = await _rateLimiter.getRateLimitInfo();
        _errorMessage = rateLimitInfo.lockoutMessage;
        _isLoading = false;
        notifyListeners();
        
        // Log tentativa bloqueada
        await _analytics.logUserAction('login_blocked_rate_limit', parameters: {
          'lockout_minutes_remaining': rateLimitInfo.lockoutTimeRemainingMinutes,
        });
        return;
      }
      
      final result = await _signInWithEmail(SignInWithEmailParams(
        email: email,
        password: password,
      ));
      
      result.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('🔐 AuthProvider: Login falhou - Tipo: ${failure.runtimeType}, Mensagem: ${failure.message}');
          }
          
          // Registra tentativa falhada no rate limiter
          await _rateLimiter.recordFailedAttempt();
          
          // Obter informações atualizadas do rate limiter
          final rateLimitInfo = await _rateLimiter.getRateLimitInfo();
          
          String errorMsg = _mapFailureToMessage(failure);
          
          if (kDebugMode) {
            debugPrint('🔐 AuthProvider: Mensagem de erro mapeada: $errorMsg');
          }
          
          // Adiciona aviso de rate limiting se aplicável
          if (!rateLimitInfo.canAttemptLogin) {
            errorMsg = rateLimitInfo.lockoutMessage;
          } else if (rateLimitInfo.warningMessage.isNotEmpty) {
            errorMsg += '\n\n${rateLimitInfo.warningMessage}';
          }
          
          _errorMessage = errorMsg;
          _isLoading = false;
          _isInLoginAttempt = false; // SECURITY + UX FIX: Clear login attempt flag on failure
          
          if (kDebugMode) {
            debugPrint('🔐 AuthProvider: Definindo errorMessage como: $_errorMessage');
            debugPrint('🔐 AuthProvider: Chamando notifyListeners()');
          }
          
          notifyListeners();
          
          // Log analytics para tentativa falhada
          await _analytics.logUserAction('login_failed', parameters: {
            'method': 'email',
            'failure_type': failure.runtimeType.toString(),
            'attempts_remaining': rateLimitInfo.attemptsRemaining,
            'is_locked': rateLimitInfo.isLocked,
          });
        },
        (user) async {
          // Registra tentativa bem-sucedida (limpa rate limiting)
          await _rateLimiter.recordSuccessfulAttempt();
          
          _currentUser = _convertFromCoreUser(user);
          _isLoading = false;
          _isInLoginAttempt = false; // SECURITY + UX FIX: Clear login attempt flag on success
          
          // Log analytics
          await _analytics.logLogin('email');
          await _analytics.logUserAction('login_success', parameters: {
            'method': 'email',
          });
          
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro interno no sistema de login. Tente novamente.';
      _isLoading = false;
      _isInLoginAttempt = false; // SECURITY + UX FIX: Clear login attempt flag on exception
      notifyListeners();
      
      // Log erro inesperado
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'login_method_error',
      );
    }
  }
  
  Future<void> register(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _signUpWithEmail(SignUpWithEmailParams(
      email: email,
      password: password,
      displayName: displayName,
    ));
    
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) async {
        _currentUser = _convertFromCoreUser(user);
        _isLoading = false;
        
        // Log analytics
        await _analytics.logUserAction('register_success', parameters: {
          'method': 'email',
        });
        
        notifyListeners();
      },
    );
  }
  
  Future<void> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🔐 Iniciando login anônimo...');
    }
    
    final result = await _signInAnonymously();
    
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('🔐 Erro no login anônimo: ${failure.message}');
        }
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) async {
        _currentUser = _convertFromCoreUser(user);
        if (kDebugMode) {
          debugPrint('🔐 Usuário anônimo criado com sucesso');
        }
        _isLoading = false;
        
        // Salvar preferência de modo anônimo
        await _saveAnonymousPreference();
        
        // Log analytics para modo anônimo
        await _analytics.logAnonymousSignIn();
        await _analytics.setUserProperties({
          'user_type': 'anonymous',
          'is_premium': 'false',
        });
        
        if (kDebugMode) {
          debugPrint('🔐 Usuário logado anonimamente');
        }
        notifyListeners();
      },
    );
  }
  
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Log analytics antes do logout
      await _analytics.logLogout();
      
      final result = await _signOut();
      
      result.fold(
        (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _isLoading = false;
          notifyListeners();
        },
        (_) async {
          _currentUser = null;
          _isPremium = false;
          _isLoading = false;
          
          // SECURITY FIX: Clear cross-module cache to prevent contamination
          try {
            await _monorepoAuthCache.clearModuleData('app-gasometer');
            if (kDebugMode) {
              debugPrint('🔐 MonorepoAuthCache limpo para app-gasometer');
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Erro ao limpar MonorepoAuthCache: $e');
            }
            // Não falha o logout se houver erro na limpeza do cache
          }
          
          if (kDebugMode) {
            debugPrint('🔐 Logout realizado com sucesso');
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout com loading dialog profissional
  /// 
  /// Exibe um dialog de loading não-cancelável durante o processo de logout
  /// que é mantido por 2 segundos para melhor UX
  Future<void> logoutWithLoadingDialog(BuildContext context) async {
    try {
      // Mostrar o dialog de loading
      showLogoutLoading(
        context,
        message: 'Saindo...',
        duration: const Duration(seconds: 2),
      );

      // Executar logout em paralelo com o dialog
      await logout();

      if (kDebugMode) {
        debugPrint('🔐 Logout com loading dialog concluído');
      }
    } catch (e) {
      // Fechar dialog se houver erro
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      notifyListeners();
      
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'logout_with_dialog_error',
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _sendPasswordReset(SendPasswordResetParams(email: email));
    
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateUserProfile({String? displayName, String? photoUrl}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _updateProfile(UpdateProfileParams(
      displayName: displayName,
      photoUrl: photoUrl,
    ));
    
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (updatedUser) {
        _currentUser = _convertFromCoreUser(updatedUser);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Update user's local avatar (base64 format)
  Future<bool> updateAvatar(String avatarBase64) async {
    try {
      if (_currentUser == null) return false;

      // Update user with new avatar
      final updatedUser = _currentUser!.copyWith(avatarBase64: avatarBase64);
      _currentUser = updatedUser;
      
      // Persist the avatar locally through the auth data source
      // This will be handled by the local data source implementation
      await _saveUserLocallyWithAvatar(updatedUser);
      
      // Log avatar update
      await _analytics.logUserAction('avatar_updated', parameters: {
        'avatar_size_kb': (avatarBase64.length * 3 ~/ 4 / 1024).toString(),
        'user_type': _currentUser!.type.toString(),
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao salvar avatar: ${e.toString()}';
      
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_update_error',
      );
      
      notifyListeners();
      return false;
    }
  }

  /// Remove user's local avatar
  Future<bool> removeAvatar() async {
    try {
      if (_currentUser == null) return false;

      // Update user removing avatar
      final updatedUser = _currentUser!.copyWith(avatarBase64: null);
      _currentUser = updatedUser;
      
      // Persist the changes locally
      await _saveUserLocallyWithAvatar(updatedUser);
      
      // Log avatar removal
      await _analytics.logUserAction('avatar_removed', parameters: {
        'user_type': _currentUser!.type.toString(),
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover avatar: ${e.toString()}';
      
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'avatar_remove_error',
      );
      
      notifyListeners();
      return false;
    }
  }

  /// Helper method to save user data locally including avatar
  Future<void> _saveUserLocallyWithAvatar(gasometer_entity.UserEntity user) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Salvando dados do usuário localmente com avatar');
      }
      
      // Convert gasometer UserEntity to core UserEntity for storage
      final coreUser = _convertToCore(user);
      await _authLocalDataSource.cacheUser(coreUser);
      
    } catch (e) {
      throw Exception('Falha ao salvar dados do usuário localmente: $e');
    }
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Log deletion attempt for analytics
      await _analytics.logUserAction('account_deletion_attempted');
      
      // For non-anonymous users, require password verification
      if (_currentUser != null && !_currentUser!.isAnonymous) {
        if (currentPassword == null || currentPassword.isEmpty) {
          _errorMessage = 'Senha atual é obrigatória para exclusão de conta.';
          _isLoading = false;
          notifyListeners();
          return;
        }
        
        // Re-authenticate with current credentials
        final reAuthResult = await _signInWithEmail(SignInWithEmailParams(
          email: _currentUser!.email!,
          password: currentPassword,
        ));
        
        // Check if re-authentication failed
        final reAuthSuccess = reAuthResult.fold(
          (failure) {
            _errorMessage = 'Senha atual incorreta. Verifique e tente novamente.';
            return false;
          },
          (_) => true,
        );
        
        if (!reAuthSuccess) {
          _isLoading = false;
          notifyListeners();
          
          await _analytics.logUserAction('account_deletion_reauthentication_failed');
          return;
        }
        
        await _analytics.logUserAction('account_deletion_reauthentication_success');
      }
      
      // Proceed with account deletion
      final result = await _deleteAccount();
      
      result.fold(
        (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _isLoading = false;
          notifyListeners();
          
          // Log deletion error
          _analytics.logUserAction('account_deletion_error', parameters: {
            'error': failure.message,
          });
        },
        (_) async {
          // Log successful deletion
          await _analytics.logUserAction('account_deletion_success');
          
          // Clear user state
          _currentUser = null;
          _isPremium = false;
          _isLoading = false;
          
          if (kDebugMode) {
            debugPrint('🔐 Conta deletada com sucesso');
          }
          
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao deletar conta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      
      // Log unexpected error
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'delete_account_error',
      );
    }
  }
  
  Future<void> _saveAnonymousPreference() async {
    // Anonymous preference is now handled by the auth data source
    if (kDebugMode) {
      debugPrint('🔐 Preferência de modo anônimo salva');
    }
  }
  
  Future<bool> shouldUseAnonymousMode() async {
    try {
      // SECURITY + UX FIX: Don't use anonymous mode if we're in the middle of a login attempt
      if (_isInLoginAttempt) {
        if (kDebugMode) {
          debugPrint('🔐 Não usar anônimo - tentativa de login em andamento');
        }
        return false;
      }
      
      // Use platform service to determine if anonymous mode should be used by default
      return _platformService.shouldUseAnonymousByDefault;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao verificar modo anônimo: $e');
      }
      return _platformService.shouldUseAnonymousByDefault;
    }
  }
  
  Future<void> initializeAnonymousIfNeeded() async {
    if (!isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
  
  void clearError() {
    // Só notificar se realmente há uma mensagem de erro para limpar
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  /// Login com sincronização automática simplificada - padrão app-plantis
  Future<void> loginAndSync(String email, String password) async {
    try {
      // 1. Fazer login primeiro (reutilizar método existente)
      await login(email, password);
      
      // 2. Se login falhou, não continua com sync
      if (!isAuthenticated || _errorMessage != null) {
        // SECURITY + UX FIX: Ensure UI is notified of login failure
        // The login() method already sets the error and calls notifyListeners(),
        // but we ensure it here for consistency
        if (_errorMessage != null) {
          notifyListeners();
        }
        return;
      }
      
      // 3. Iniciar sincronização em background (não bloqueia navegação)
      if (!isAnonymous) {
        _performBackgroundSync();
      }
    } catch (e) {
      _errorMessage = 'Erro interno no login com sincronização. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'loginAndSync_error',
      );
    }
  }
  
  /// Executa sincronização em background sem bloquear navegação
  void _performBackgroundSync() {
    // Executar em background sem bloquear a UI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isAuthenticated && !isAnonymous) {
        _startBackgroundDataSync();
      }
    });
  }
  
  /// Sincronização de dados em background (padrão app-plantis)
  Future<void> _startBackgroundDataSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      if (kDebugMode) {
        debugPrint('🔄 Iniciando sincronização em background...');
      }
      
      // Sincronizar dados do Gasometer de forma simples
      await _syncGasometerData();
      
      await _analytics.log('gasometer_background_sync_completed');
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na sincronização em background: $e');
      }
      
      await _analytics.recordError(
        e,
        StackTrace.current,
        reason: 'gasometer_background_sync_error',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Sincronizar dados do Gasometer usando UnifiedSync
  Future<void> _syncGasometerData() async {
    try {
      // Usar o UnifiedSyncManager para sincronizar todos os dados do app gasometer
      final syncResult = await UnifiedSyncManager.instance.forceSyncApp('gasometer');

      syncResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ Erro na sincronização UnifiedSync: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Sincronização UnifiedSync concluída com sucesso');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro na sincronização Gasometer: $e');
      }
    }
  }
  
  /// Sincroniza dados específicos por entidade (implementação obsoleta)
  /// O UnifiedSyncManager agora gerencia automaticamente todas as entidades
  @deprecated
  Future<void> _syncStepData(String dataType) async {
    // Implementação obsoleta - UnifiedSyncManager gerencia automaticamente
    // todas as entidades registradas no GasometerSyncConfig
    if (kDebugMode) {
      debugPrint('⚠️ _syncStepData obsoleto - usando UnifiedSyncManager');
    }
  }
  
  /// Para sincronização em andamento
  void stopSync() {
    _isSyncing = false;
    notifyListeners();
  }
  
  /// Convert core UserEntity to gasometer UserEntity
  gasometer_entity.UserEntity? _convertFromCoreUser(core.UserEntity? coreUser) {
    if (coreUser == null) return null;
    
    // Convert from core UserEntity to gasometer UserEntity
    return gasometer_entity.UserEntity(
      id: coreUser.id,
      email: coreUser.email,
      displayName: coreUser.displayName,
      photoUrl: coreUser.photoUrl,
      avatarBase64: null, // Core doesn't have local avatar support
      type: _mapAuthProviderToUserType(coreUser.provider),
      isEmailVerified: coreUser.isEmailVerified,
      createdAt: coreUser.createdAt ?? DateTime.now(),
      lastSignInAt: coreUser.lastLoginAt,
      metadata: {
        'provider': coreUser.provider.name,
        'phone': coreUser.phone,
        'isActive': coreUser.isActive,
      },
    );
  }


  /// Map AuthProvider to UserType
  gasometer_entity.UserType _mapAuthProviderToUserType(core.AuthProvider provider) {
    switch (provider) {
      case core.AuthProvider.anonymous:
        return gasometer_entity.UserType.anonymous;
      case core.AuthProvider.email:
      case core.AuthProvider.google:
      case core.AuthProvider.apple:
      case core.AuthProvider.facebook:
        return gasometer_entity.UserType.registered;
    }
  }

  /// Convert gasometer UserEntity to core UserEntity
  core.UserEntity _convertToCore(gasometer_entity.UserEntity gasometerUser) {
    return core.UserEntity(
      id: gasometerUser.id,
      email: gasometerUser.email ?? '',
      displayName: gasometerUser.displayName ?? '',
      photoUrl: gasometerUser.photoUrl,
      isEmailVerified: gasometerUser.isEmailVerified,
      lastLoginAt: gasometerUser.lastSignInAt,
      provider: _mapUserTypeToAuthProvider(gasometerUser.type),
      phone: gasometerUser.metadata['phone'] as String?,
      isActive: gasometerUser.metadata['isActive'] as bool? ?? true,
      createdAt: gasometerUser.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Map UserType to AuthProvider for reverse conversion
  core.AuthProvider _mapUserTypeToAuthProvider(gasometer_entity.UserType userType) {
    switch (userType) {
      case gasometer_entity.UserType.anonymous:
        return core.AuthProvider.anonymous;
      case gasometer_entity.UserType.registered:
      case gasometer_entity.UserType.premium:
        return core.AuthProvider.email; // Default to email for registered users
    }
  }


  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
  
}

/// Enum para operações de sync (se não existir)
enum SyncOperationType {
  sync,
  create,
  update,
  delete,
}