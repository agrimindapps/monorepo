import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' show EnhancedAccountDeletionService;
import 'auth_providers.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/pet_data_sync_service.dart';
import '../../domain/usecases/auth_usecases.dart' as auth_usecases;
import '../../../../core/interfaces/usecase.dart' as local;

part 'auth_provider.g.dart';

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

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late final auth_usecases.SignInWithEmail _signInWithEmail;
  late final auth_usecases.SignUpWithEmail _signUpWithEmail;
  late final auth_usecases.SignInWithGoogle _signInWithGoogle;
  late final auth_usecases.SignInWithApple _signInWithApple;
  late final auth_usecases.SignInWithFacebook _signInWithFacebook;
  late final auth_usecases.SignInAnonymously _signInAnonymously;
  late final auth_usecases.SignOut _signOut;
  late final auth_usecases.GetCurrentUser _getCurrentUser;
  late final auth_usecases.SendEmailVerification _sendEmailVerification;
  late final auth_usecases.SendPasswordResetEmail _sendPasswordResetEmail;
  late final auth_usecases.UpdateProfile _updateProfile;
  late final EnhancedAccountDeletionService _enhancedDeletionService;
  DateTime? _lastLoginAttempt;
  DateTime? _lastRegisterAttempt;
  int _loginAttempts = 0;
  int _registerAttempts = 0;
  static const int _maxAttempts = 5;
  static const Duration _cooldownPeriod = Duration(minutes: 2);

  @override
  AuthState build() {
    _signInWithEmail = ref.watch(signInWithEmailProvider);
    _signUpWithEmail = ref.watch(signUpWithEmailProvider);
    _signInWithGoogle = ref.watch(signInWithGoogleProvider);
    _signInWithApple = ref.watch(signInWithAppleProvider);
    _signInWithFacebook = ref.watch(signInWithFacebookProvider);
    _signInAnonymously = ref.watch(signInAnonymouslyProvider);
    _signOut = ref.watch(signOutProvider);
    _getCurrentUser = ref.watch(getCurrentUserProvider);
    _sendEmailVerification = ref.watch(sendEmailVerificationProvider);
    _sendPasswordResetEmail = ref.watch(sendPasswordResetEmailProvider);
    _updateProfile = ref.watch(updateProfileProvider);
    _enhancedDeletionService = ref.watch(enhancedAccountDeletionServiceProvider);
    
    // Check auth state after build
    Future.microtask(() => _checkAuthState());
    
    return const AuthState();
  }

  Future<void> _checkAuthState() async {
    final result = await _getCurrentUser(const local.NoParams());
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      ),
      (user) async {
        final isAnonymous = user?.isAnonymous ?? false;
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
    if (!_canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_loginAttempts),
      );
      return false;
    }
    _lastLoginAttempt = DateTime.now();
    _loginAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params = auth_usecases.SignInWithEmailParams(email: email, password: password);
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
    if (!_canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_loginAttempts),
      );
      return false;
    }
    _lastLoginAttempt = DateTime.now();
    _loginAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final params = auth_usecases.SignInWithEmailParams(email: email, password: password);
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
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  }

  Future<bool> signUpWithEmail(String email, String password, String? name) async {
    if (!_canAttemptRegister()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _getRateLimitMessage(_registerAttempts),
      );
      return false;
    }
    _lastRegisterAttempt = DateTime.now();
    _registerAttempts++;

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params = auth_usecases.SignUpWithEmailParams(email: email, password: password, name: name);
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

    final result = await _signInWithGoogle(const local.NoParams());

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

    final result = await _signInWithApple(const local.NoParams());

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

    final result = await _signInWithFacebook(const local.NoParams());

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

    final result = await _signInAnonymously(const local.NoParams());

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
        _saveAnonymousPreference();
        
        return true;
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signOut(const local.NoParams());

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
    final result = await _sendEmailVerification(const local.NoParams());
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
    final params = auth_usecases.UpdateProfileParams(name: name, photoUrl: photoUrl);
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

  Future<bool> deleteAccount({String? password}) async {
    if (state.user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Nenhum usuário autenticado',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final result = await _enhancedDeletionService.deleteAccount(
        password: password ?? '',
        userId: state.user!.id,
        isAnonymous: state.isAnonymous,
      );

      return result.fold(
        (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            error: error.message,
          );
          return false;
        },
        (deletionResult) {
          if (deletionResult.isSuccess) {
            _performPostDeletionCleanup();
            return true;
          } else {
            state = state.copyWith(
              status: AuthStatus.error,
              error: deletionResult.userMessage,
            );
            return false;
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  void _performPostDeletionCleanup() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
  Future<void> _saveAnonymousPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_anonymous_mode', true);
    } catch (e) {
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
    }
  }

  Future<void> initializeAnonymousIfNeeded() async {
    if (!state.isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
}

// Derived providers (now use authProvider from code generation)
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
