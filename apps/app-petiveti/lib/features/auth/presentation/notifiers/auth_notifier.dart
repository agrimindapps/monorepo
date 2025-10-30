import 'package:core/core.dart' hide User;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/interfaces/usecase.dart' as local;
import '../../domain/entities/user.dart';
import '../../domain/services/pet_data_sync_service.dart';
import '../../domain/services/rate_limit_service.dart';
import '../../domain/usecases/auth_usecases.dart' as auth_usecases;

part 'auth_notifier.g.dart';

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

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && error != null;
}

@riverpod
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
  late final RateLimitService _rateLimitService;
  late final PetDataSyncService _petDataSyncService;

  @override
  AuthState build() {
    _signInWithEmail = di.getIt<auth_usecases.SignInWithEmail>();
    _signUpWithEmail = di.getIt<auth_usecases.SignUpWithEmail>();
    _signInWithGoogle = di.getIt<auth_usecases.SignInWithGoogle>();
    _signInWithApple = di.getIt<auth_usecases.SignInWithApple>();
    _signInWithFacebook = di.getIt<auth_usecases.SignInWithFacebook>();
    _signInAnonymously = di.getIt<auth_usecases.SignInAnonymously>();
    _signOut = di.getIt<auth_usecases.SignOut>();
    _getCurrentUser = di.getIt<auth_usecases.GetCurrentUser>();
    _sendEmailVerification = di.getIt<auth_usecases.SendEmailVerification>();
    _sendPasswordResetEmail = di.getIt<auth_usecases.SendPasswordResetEmail>();
    _updateProfile = di.getIt<auth_usecases.UpdateProfile>();
    _enhancedDeletionService = di.getIt<EnhancedAccountDeletionService>();
    _rateLimitService = di.getIt<RateLimitService>();
    _petDataSyncService = di.getIt<PetDataSyncService>();

    _checkAuthState();

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
          status: user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: user,
          isAnonymous: isAnonymous,
        );
      },
    );
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (!_rateLimitService.canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _rateLimitService.getRateLimitMessageForLogin(),
      );
      return false;
    }
    _rateLimitService.recordLoginAttempt();

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params =
        auth_usecases.SignInWithEmailParams(email: email, password: password);
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
        _rateLimitService.resetLoginAttempts();

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
  Future<bool> loginAndSync(String email, String password,
      {bool showSyncOverlay = true}) async {
    if (!_rateLimitService.canAttemptLogin()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _rateLimitService.getRateLimitMessageForLogin(),
      );
      return false;
    }
    _rateLimitService.recordLoginAttempt();

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final params =
          auth_usecases.SignInWithEmailParams(email: email, password: password);
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
          _rateLimitService.resetLoginAttempts();

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
      await _petDataSyncService.syncPetData();

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Erro interno no login com sincronização. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String? name) async {
    if (!_rateLimitService.canAttemptRegister()) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: _rateLimitService.getRateLimitMessageForRegister(),
      );
      return false;
    }
    _rateLimitService.recordRegisterAttempt();

    state = state.copyWith(status: AuthStatus.loading, error: null);

    final params = auth_usecases.SignUpWithEmailParams(
        email: email, password: password, name: name);
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
        _rateLimitService.resetRegisterAttempts();

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
    final params =
        auth_usecases.UpdateProfileParams(name: name, photoUrl: photoUrl);
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
      // Silent fail
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
      // Silent fail
    }
  }

  Future<void> initializeAnonymousIfNeeded() async {
    if (!state.isAuthenticated && await shouldUseAnonymousMode()) {
      await signInAnonymously();
    }
  }
}

// Derived providers
@riverpod
AuthState authState(AuthStateRef ref) {
  return ref.watch(authNotifierProvider);
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(authNotifierProvider).user;
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
}

@riverpod
bool authLoading(AuthLoadingRef ref) {
  return ref.watch(authNotifierProvider).isLoading;
}

@riverpod
String? authError(AuthErrorRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.hasError ? authState.error : null;
}
