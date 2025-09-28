import 'dart:async';
import 'package:core/core.dart';

// Auth State class to represent authentication status
class AuthState {

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  bool get isAuthenticated => user != null;
  bool get isAnonymous => user?.provider == AuthProvider.anonymous;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }
  final FirebaseAuthService _authService;
  late final StreamSubscription<UserEntity?> _authStateSubscription;

  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      _authStateSubscription = _authService.currentUser.listen((user) {
        state = state.copyWith(
          user: user,
          isInitialized: true,
        );
      });
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao inicializar autenticação: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro no login: $e',
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro no registro: $e',
      );
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.signInAnonymously();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro no login anônimo: $e',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _authService.signOut();
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          state = state.copyWith(
            user: null,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro no logout: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

// Providers using dependency injection from core
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = FirebaseAuthService();
  return AuthNotifier(authService);
});