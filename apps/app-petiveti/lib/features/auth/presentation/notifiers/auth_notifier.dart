import 'dart:async';

import 'package:core/core.dart' hide User;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/interfaces/usecase.dart' as local;
import '../../../../core/providers/realtime_sync_notifier.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/pet_data_sync_service.dart';
import '../../domain/services/rate_limit_service.dart';
import '../../domain/usecases/auth_usecases.dart' as auth_usecases;
import '../providers/auth_providers.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user?.id == other.user?.id &&
          error == other.error &&
          isAnonymous == other.isAnonymous;

  @override
  int get hashCode =>
      status.hashCode ^
      (user?.id.hashCode ?? 0) ^
      (error?.hashCode ?? 0) ^
      isAnonymous.hashCode;

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.id}, isAuth: $isAuthenticated, isAnon: $isAnonymous)';
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
    _rateLimitService = ref.watch(rateLimitServiceProvider);
    _petDataSyncService = ref.watch(petDataSyncServiceProvider);

    // Check auth state
    _checkAuthState();

    return const AuthState();
  }

  Future<void> _checkAuthState() async {
    final result = await _getCurrentUser(const local.NoParams());
    
    // Verificar se o provider ainda está montado
    if (!ref.mounted) return;
    
    result.fold(
      (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        );
      },
      (user) async {
        if (!ref.mounted) return;
        
        final isAnonymous = user?.isAnonymous ?? false;
        if (user == null && await shouldUseAnonymousMode()) {
          if (!ref.mounted) return;
          await signInAnonymously();
          return;
        }

        if (!ref.mounted) return;
        
        state = state.copyWith(
          status: user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: user,
          isAnonymous: isAnonymous,
        );

        // Iniciar realtime sync se autenticado
        if (user != null && ref.mounted) {
          unawaited(ref.read(realtimeSyncProvider.notifier).startListening(user.id));
        }
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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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

          // Iniciar realtime sync
          unawaited(ref.read(realtimeSyncProvider.notifier).startListening(user.id));

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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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

        // Iniciar realtime sync
        ref.read(realtimeSyncProvider.notifier).startListening(user.id);

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
      (_) {
        // Parar realtime sync (se provider ainda montado)
        if (ref.mounted) {
          ref.read(realtimeSyncProvider.notifier).stopListening();
        }

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      },
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
AuthState authState(Ref ref) {
  return ref.watch(authProvider);
}

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authProvider).user;
}

@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authProvider).isAuthenticated;
}

@riverpod
bool authLoading(Ref ref) {
  return ref.watch(authProvider).isLoading;
}

@riverpod
String? authError(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.hasError ? authState.error : null;
}
