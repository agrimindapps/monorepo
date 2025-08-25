import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/platform_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/watch_auth_state.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final GetCurrentUser _getCurrentUser;
  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final UpdateProfile _updateProfile;
  final SendPasswordReset _sendPasswordReset;
  final AnalyticsService _analytics;
  final PlatformService _platformService;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  StreamSubscription? _authStateSubscription;
  
  AuthProvider({
    required GetCurrentUser getCurrentUser,
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInAnonymously signInAnonymously,
    required SignOut signOut,
    required UpdateProfile updateProfile,
    required SendPasswordReset sendPasswordReset,
    required AnalyticsService analytics,
    required PlatformService platformService,
  })  : _getCurrentUser = getCurrentUser,
        _watchAuthState = watchAuthState,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        _updateProfile = updateProfile,
        _sendPasswordReset = sendPasswordReset,
        _analytics = analytics,
        _platformService = platformService {
    _initializeAuthState();
  }
  
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  String? get userDisplayName => _currentUser?.displayName;
  String? get userEmail => _currentUser?.email;
  String get userId => _currentUser?.id ?? '';
  
  Future<void> _initializeAuthState() async {
    try {
      // Get current user first
      final result = await _getCurrentUser();
      result.fold(
        (failure) {
          _errorMessage = _mapFailureToMessage(failure);
          _isInitialized = true;
          notifyListeners();
        },
        (user) async {
          _currentUser = user;
          _isInitialized = true;
          
          if (user != null) {
            await _setupUserSession(user);
          } else {
            // If no user and should use anonymous mode, initialize anonymously
            if (await shouldUseAnonymousMode()) {
              debugPrint('🔐 Iniciando modo anônimo automaticamente');
              await signInAnonymously();
              return;
            }
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
            _currentUser = user;
            
            if (user != null) {
              await _setupUserSession(user);
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
  
  Future<void> _setupUserSession(UserEntity user) async {
    try {
      if (user.isAnonymous) {
        if (kDebugMode) {
        debugPrint('🔐 Usuário anônimo: ${user.id.substring(0, 8)}...');
      }
        _isPremium = false;
        return;
      }
      
      // For registered users, set up analytics and check premium
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
  
  
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _signInWithEmail(SignInWithEmailParams(
      email: email,
      password: password,
    ));
    
    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) async {
        _currentUser = user;
        _isLoading = false;
        
        // Log analytics
        await _analytics.logLogin('email');
        await _analytics.logUserAction('login_success', parameters: {
          'method': 'email',
        });
        
        notifyListeners();
      },
    );
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
        _currentUser = user;
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
    
    debugPrint('🔐 Iniciando login anônimo...');
    
    final result = await _signInAnonymously();
    
    result.fold(
      (failure) {
        debugPrint('🔐 Erro no login anônimo: ${failure.message}');
        _errorMessage = _mapFailureToMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (user) async {
        _currentUser = user;
        if (kDebugMode) {
          debugPrint('🔐 Usuário anônimo criado: ${user.id.substring(0, 8)}...');
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
          debugPrint('🔐 Usuário logado anonimamente. isAuthenticated: $isAuthenticated');
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
        (_) {
          _currentUser = null;
          _isPremium = false;
          _isLoading = false;
          
          debugPrint('🔐 Usuário deslogado');
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
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
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  Future<void> _saveAnonymousPreference() async {
    // Anonymous preference is now handled by the auth data source
    debugPrint('🔐 Preferência de modo anônimo salva via data source');
  }
  
  Future<bool> shouldUseAnonymousMode() async {
    try {
      // Use platform service to determine if anonymous mode should be used by default
      return _platformService.shouldUseAnonymousByDefault;
    } catch (e) {
      debugPrint('Erro ao verificar modo anônimo: $e');
      return _platformService.shouldUseAnonymousByDefault;
    }
  }
  
  Future<void> initializeAnonymousIfNeeded() async {
    if (!isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
}