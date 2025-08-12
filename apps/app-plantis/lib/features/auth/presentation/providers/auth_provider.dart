import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAuthRepository _authRepository;
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  StreamSubscription<UserEntity?>? _userSubscription;
  
  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required IAuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository {
    _initializeAuthState();
  }
  
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  
  void _initializeAuthState() {
    _userSubscription = _authRepository.currentUser.listen(
      (user) {
        _currentUser = user;
        _isInitialized = true;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isInitialized = true;
        notifyListeners();
      },
    );
  }
  
  @override
  void dispose() {
    _userSubscription?.cancel();
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
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}