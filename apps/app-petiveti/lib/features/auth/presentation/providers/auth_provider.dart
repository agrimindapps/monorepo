import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isAnonymous;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isAnonymous = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isAnonymous,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && error != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final SignInWithFacebook _signInWithFacebook;
  final SignInAnonymously _signInAnonymously;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final SendEmailVerification _sendEmailVerification;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final UpdateProfile _updateProfile;
  final DeleteAccount _deleteAccount;

  // Rate limiting properties
  DateTime? _lastLoginAttempt;
  DateTime? _lastRegisterAttempt;
  int _loginAttempts = 0;
  int _registerAttempts = 0;
  static const int _maxAttempts = 5;
  static const Duration _cooldownPeriod = Duration(minutes: 2);

  AuthNotifier(
    this._signInWithEmail,
    this._signUpWithEmail,
    this._signInWithGoogle,
    this._signInWithApple,
    this._signInWithFacebook,
    this._signInAnonymously,
    this._signOut,
    this._getCurrentUser,
    this._sendEmailVerification,
    this._sendPasswordResetEmail,
    this._updateProfile,
    this._deleteAccount,
  ) : super(const AuthState()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      ),
      (user) async {
        final isAnonymous = user?.isAnonymous ?? false;
        
        // Se não há usuário e deve usar modo anônimo, inicializa anonimamente
        if (user == null && await shouldUseAnonymousMode()) {
          await signInAnonymously();
          return;
        }
        
        state = state.copyWith(
          status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
          user: user,
          isAnonymous: isAnonymous,
        );
      },
    );
  }

  // Rate limiting helper methods
  bool _canAttemptLogin() {
    if (_lastLoginAttempt == null) return true;
    
    final timeSinceLastAttempt = DateTime.now().difference(_lastLoginAttempt!);
    if (timeSinceLastAttempt > _cooldownPeriod) {
      _loginAttempts = 0;
      return true;
    }
    
    return _loginAttempts < _maxAttempts;
  }

  bool _canAttemptRegister() {
    if (_lastRegisterAttempt == null) return true;
    
    final timeSinceLastAttempt = DateTime.now().difference(_lastRegisterAttempt!);
    if (timeSinceLastAttempt > _cooldownPeriod) {
      _registerAttempts = 0;
      return true;
    }
    
    return _registerAttempts < _maxAttempts;
  }

  String _getRateLimitMessage(int attempts) {
    final remainingTime = _cooldownPeriod.inMinutes - 
      DateTime.now().difference(_lastLoginAttempt ?? _lastRegisterAttempt!).inMinutes;
    
    return 'Muitas tentativas. Aguarde ${remainingTime > 0 ? remainingTime : 1} minuto(s) antes de tentar novamente.';
  }

  Future<bool> signInWithEmail(String email, String password) async {
    // Check rate limiting
    if (!_canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_loginAttempts),
      );
      return false;
    }

    // Record attempt
    _lastLoginAttempt = DateTime.now();
    _loginAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params = SignInWithEmailParams(email: email, password: password);
    final result = await _signInWithEmail(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        // Reset attempts on successful login
        _loginAttempts = 0;
        _lastLoginAttempt = null;
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      },
    );
  }

  /// Login com sincronização automática de dados dos pets
  /// Adaptado do padrão usado no gasometer e plantis para o contexto do PetiVeti
  Future<bool> loginAndSync(String email, String password, {bool showSyncOverlay = true}) async {
    // Check rate limiting
    if (!_canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_loginAttempts),
      );
      return false;
    }

    // Record attempt
    _lastLoginAttempt = DateTime.now();
    _loginAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // 1. Fazer login primeiro
      final params = SignInWithEmailParams(email: email, password: password);
      final loginResult = await _signInWithEmail(params);
      
      bool loginSuccess = false;
      await loginResult.fold(
        (failure) async {
          state = state.copyWith(
            status: AuthStatus.error,
            error: failure.message,
          );
        },
        (user) async {
          // Reset attempts on successful login
          _loginAttempts = 0;
          _lastLoginAttempt = null;
          
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          loginSuccess = true;
        },
      );
      
      if (!loginSuccess) {
        return false;
      }
      
      // 2. Para o PetiVeti, a "sincronização" é mais simples inicialmente
      // Podemos simular um carregamento de dados iniciais dos pets
      await _performPetDataSync();
      
      return true;
      
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Erro interno no login com sincronização. Tente novamente.',
      );
      return false;
    }
  }

  /// Simula sincronização de dados dos pets
  /// No futuro, aqui seria onde carregaríamos dados do Firebase, cache local, etc.
  Future<void> _performPetDataSync() async {
    // Simular carregamento de dados iniciais
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    
    // Aqui no futuro poderíamos:
    // - Carregar lista de pets do usuário
    // - Sincronizar lembretes pendentes
    // - Atualizar dados de medicações
    // - Verificar consultas próximas
    // - etc.
  }

  Future<bool> signUpWithEmail(String email, String password, String? name) async {
    // Check rate limiting
    if (!_canAttemptRegister()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_registerAttempts),
      );
      return false;
    }

    // Record attempt
    _lastRegisterAttempt = DateTime.now();
    _registerAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params = SignUpWithEmailParams(email: email, password: password, name: name);
    final result = await _signUpWithEmail(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        // Reset attempts on successful registration
        _registerAttempts = 0;
        _lastRegisterAttempt = null;
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _signInWithGoogle(const NoParams());

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _signInWithApple(const NoParams());

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithFacebook() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _signInWithFacebook(const NoParams());

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      },
    );
  }

  Future<bool> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _signInAnonymously(const NoParams());

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isAnonymous: true,
        );
        
        // Salvar preferência de modo anônimo
        _saveAnonymousPreference();
        
        return true;
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signOut(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<bool> sendEmailVerification() async {
    final result = await _sendEmailVerification(const NoParams());
    return result.isRight();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final result = await _sendPasswordResetEmail(email);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updateProfile(String? name, String? photoUrl) async {
    final params = UpdateProfileParams(name: name, photoUrl: photoUrl);
    final result = await _updateProfile(params);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user);
        return true;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _deleteAccount(const NoParams());

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Anonymous authentication helper methods
  Future<void> _saveAnonymousPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_anonymous_mode', true);
    } catch (e) {
      // Ignora erros de persistência para não afetar o fluxo principal
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

  Future<void> clearAnonymousPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('use_anonymous_mode');
    } catch (e) {
      // Ignora erros de persistência
    }
  }

  Future<void> initializeAnonymousIfNeeded() async {
    if (!state.isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getIt<SignInWithEmail>(),
    getIt<SignUpWithEmail>(),
    getIt<SignInWithGoogle>(),
    getIt<SignInWithApple>(),
    getIt<SignInWithFacebook>(),
    getIt<SignInAnonymously>(),
    getIt<SignOut>(),
    getIt<GetCurrentUser>(),
    getIt<SendEmailVerification>(),
    getIt<SendPasswordResetEmail>(),
    getIt<UpdateProfile>(),
    getIt<DeleteAccount>(),
  );
});

// Convenience providers
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.hasError ? authState.error : null;
});