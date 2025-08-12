import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/core.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/di/injection_container.dart' as di;

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAuthRepository _authRepository;
  final ISubscriptionRepository? _subscriptionRepository;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionStream;
  
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
    ISubscriptionRepository? subscriptionRepository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository,
        _subscriptionRepository = subscriptionRepository {
    _initializeAuthState();
  }
  
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  
  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        _currentUser = user;
        
        // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
        if (user == null && await shouldUseAnonymousMode()) {
          await signInAnonymously();
          return; // O signInAnonymously vai disparar este listener novamente
        }
        
        _isInitialized = true;
        
        // Sincroniza com RevenueCat quando o usuário faz login (não anônimo)
        if (user != null && !isAnonymous && _subscriptionRepository != null) {
          await _syncUserWithRevenueCat(user.id);
          await _checkPremiumStatus();
        } else {
          _isPremium = false;
        }
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isInitialized = true;
        notifyListeners();
      },
    );
    
    // Escuta mudanças na assinatura
    if (_subscriptionRepository != null) {
      _subscriptionStream = _subscriptionRepository!.subscriptionStatus.listen(
        (subscription) {
          _isPremium = subscription?.isActive ?? false;
          notifyListeners();
        },
      );
    }
  }
  
  Future<void> _syncUserWithRevenueCat(String userId) async {
    if (_subscriptionRepository == null) return;
    
    await _subscriptionRepository!.setUser(
      userId: userId,
      attributes: {
        'app': 'plantis',
        'email': _currentUser?.email ?? '',
      },
    );
  }
  
  Future<void> _checkPremiumStatus() async {
    if (_subscriptionRepository == null) return;
    
    final result = await _subscriptionRepository!.hasPlantisSubscription();
    result.fold(
      (failure) {
        debugPrint('Erro ao verificar status premium: ${failure.message}');
        _isPremium = false;
      },
      (hasPremium) {
        _isPremium = hasPremium;
      },
    );
  }
  
  @override
  void dispose() {
    _userSubscription?.cancel();
    _subscriptionStream?.cancel();
    super.dispose();
  }
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _loginUseCase(LoginParams(
      email: email,
      password: password,
    ));
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        
        // Log login event
        _analytics?.logLogin('email');
        
        notifyListeners();
      },
    );
  }
  
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _logoutUseCase();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _currentUser = null;
        _isLoading = false;
        
        // Log logout event
        _analytics?.logLogout();
        
        notifyListeners();
      },
    );
  }
  
  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
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
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  Future<void> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _authRepository.signInAnonymously();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        
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
      debugPrint('Erro ao salvar preferência anônima: $e');
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
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}