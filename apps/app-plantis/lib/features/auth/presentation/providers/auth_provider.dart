import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/widgets/loading_overlay.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAuthRepository _authRepository;
  final ISubscriptionRepository? _subscriptionRepository;
  final AuthStateNotifier _authStateNotifier;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isPremium = false;
  AuthOperation? _currentOperation;
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
    AuthStateNotifier? authStateNotifier,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository,
       _subscriptionRepository = subscriptionRepository,
       _authStateNotifier = authStateNotifier ?? AuthStateNotifier.instance {
    _initializeAuthState();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _isPremium;
  AuthOperation? get currentOperation => _currentOperation;

  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) async {
        _currentUser = user;

        // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
        if (user == null && await shouldUseAnonymousMode()) {
          // Marca como inicializado ANTES de fazer login anônimo para evitar redirecionamentos
          _isInitialized = true;
          _authStateNotifier.updateInitializationStatus(true);
          notifyListeners();
          await signInAnonymously();
          return; // O signInAnonymously vai disparar este listener novamente
        }

        _isInitialized = true;
        
        // Update AuthStateNotifier with user changes
        _authStateNotifier.updateUser(user);
        _authStateNotifier.updateInitializationStatus(true);

        // Sincroniza com RevenueCat quando o usuário faz login (não anônimo)
        if (user != null && !isAnonymous && _subscriptionRepository != null) {
          await _syncUserWithRevenueCat(user.id);
          await _checkPremiumStatus();
        } else {
          _isPremium = false;
          _authStateNotifier.updatePremiumStatus(false);
        }

        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isInitialized = true;
        _authStateNotifier.updateInitializationStatus(true);
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
        debugPrint('Erro ao verificar status premium: ${failure.message}');
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

  void clearCurrentOperation() {
    _currentOperation = null;
    notifyListeners();
  }
}
