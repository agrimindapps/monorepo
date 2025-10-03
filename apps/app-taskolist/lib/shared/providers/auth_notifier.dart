import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection.dart' as di;
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/crashlytics_service.dart';
import '../../infrastructure/services/sync_service.dart';

part 'auth_notifier.g.dart';

// =============================================================================
// DEPENDENCY PROVIDERS (Services from GetIt)
// =============================================================================

@riverpod
TaskManagerAuthService authService(AuthServiceRef ref) {
  return di.getIt<TaskManagerAuthService>();
}

@riverpod
TaskManagerSyncService syncService(SyncServiceRef ref) {
  return di.getIt<TaskManagerSyncService>();
}

@riverpod
TaskManagerCrashlyticsService crashlyticsService(CrashlyticsServiceRef ref) {
  return di.getIt<TaskManagerCrashlyticsService>();
}

// =============================================================================
// AUTH STATE CLASS
// =============================================================================

class AuthState {
  final core.UserEntity? user;
  final bool isSyncInProgress;
  final bool hasPerformedInitialSync;
  final String syncMessage;

  const AuthState({
    this.user,
    this.isSyncInProgress = false,
    this.hasPerformedInitialSync = false,
    this.syncMessage = 'Sincronizando dados...',
  });

  AuthState copyWith({
    core.UserEntity? user,
    bool? clearUser,
    bool? isSyncInProgress,
    bool? hasPerformedInitialSync,
    String? syncMessage,
  }) {
    return AuthState(
      user: clearUser == true ? null : (user ?? this.user),
      isSyncInProgress: isSyncInProgress ?? this.isSyncInProgress,
      hasPerformedInitialSync: hasPerformedInitialSync ?? this.hasPerformedInitialSync,
      syncMessage: syncMessage ?? this.syncMessage,
    );
  }
}

// =============================================================================
// AUTH ASYNC NOTIFIER (Watches auth stream)
// =============================================================================

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final TaskManagerAuthService _authService;
  late final TaskManagerSyncService _syncService;
  StreamSubscription<core.UserEntity?>? _authSubscription;

  @override
  Future<AuthState> build() async {
    _authService = ref.read(authServiceProvider);
    _syncService = ref.read(syncServiceProvider);

    // Setup stream listener
    _authSubscription = _authService.currentUser.listen(
      (user) {
        // Update state when stream emits
        state = AsyncValue.data(state.value?.copyWith(user: user) ?? AuthState(user: user));
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );

    // Cleanup on dispose
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Return initial state
    try {
      final user = await _authService.currentUser.first;
      return AuthState(user: user);
    } catch (e) {
      rethrow;
    }
  }

  // =============================================================================
  // ACTIONS
  // =============================================================================

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) => throw failure,
        (user) => AuthState(user: user),
      );
    });
  }

  Future<void> signUp(String email, String password, String displayName) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      return result.fold(
        (failure) => throw failure,
        (user) => AuthState(user: user),
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _authService.signOut();
      return result.fold(
        (failure) => throw failure,
        (_) => const AuthState(user: null),
      );
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await signIn(email, password);
  }

  Future<void> signInAnonymously() async {
    print('🔄 AuthNotifier: Iniciando signInAnonymously...');
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _authService.signInAnonymously();

      return result.fold(
        (failure) {
          print('❌ AuthNotifier: Erro no login anônimo: $failure');
          throw Exception(failure.message); // Propagar o erro
        },
        (user) {
          print('✅ AuthNotifier: Login anônimo bem-sucedido: ${user.id}');
          return AuthState(user: user);
        },
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _authService.signInWithGoogle();

      return result.fold(
        (failure) => throw failure,
        (user) => AuthState(user: user),
      );
    });
  }

  /// Novo método que combina login + sincronização automática
  Future<void> loginAndSync(String email, String password) async {
    try {
      // Primeiro fazer login normal
      await signInWithEmailAndPassword(email, password);

      // Verificar se login foi bem-sucedido
      final currentState = state;
      if (currentState is AsyncError ||
          (currentState is AsyncData && currentState.value?.user == null)) {
        return;
      }

      final user = (currentState as AsyncData<AuthState>).value!.user!;

      // Iniciar sincronização automática apenas se não foi feita ainda
      if (!state.value!.hasPerformedInitialSync && !_isAnonymous(user)) {
        await _startPostLoginSync(user);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Inicia processo de sincronização pós-login (apenas para usuários não anônimos)
  Future<void> _startPostLoginSync(core.UserEntity user) async {
    final currentState = state.value;
    if (currentState == null || currentState.isSyncInProgress) return;

    // ⚠️ IMPORTANTE: Sincronizar apenas usuários não anônimos
    if (_isAnonymous(user)) {
      return;
    }

    // Update state to show sync in progress
    state = AsyncValue.data(currentState.copyWith(
      isSyncInProgress: true,
      syncMessage: 'Sincronizando dados...',
    ));

    try {
      // TODO: Verificar status Premium quando RevenueCat estiver configurado
      const isUserPremium = false;

      // Executar sincronização usando o SyncService
      final result = await _syncService.syncAll(
        userId: user.id,
        isUserPremium: isUserPremium,
      );

      result.fold(
        (failure) {
          // Log do erro, mas não bloquear o usuário
          print('❌ Erro na sincronização pós-login: ${failure.message}');

          // Update state - sync failed but don't block
          state = AsyncValue.data(currentState.copyWith(
            isSyncInProgress: false,
            hasPerformedInitialSync: false,
          ));
        },
        (_) {
          // Marcar sincronização inicial como realizada
          state = AsyncValue.data(currentState.copyWith(
            isSyncInProgress: false,
            hasPerformedInitialSync: true,
          ));
        },
      );
    } catch (e) {
      print('❌ Erro durante sincronização: $e');

      // Update state - sync failed
      state = AsyncValue.data(currentState.copyWith(
        isSyncInProgress: false,
        hasPerformedInitialSync: false,
      ));
    }
  }

  /// Verifica se é usuário anônimo
  bool _isAnonymous(core.UserEntity user) {
    return user.provider.name == 'anonymous';
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _authService.sendPasswordResetEmail(email: email);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }
}

// =============================================================================
// FUTURE PROVIDERS (For specific auth operations)
// =============================================================================

/// Request classes para login/registro
class SignInRequest {
  final String email;
  final String password;

  SignInRequest({required this.email, required this.password});
}

class SignUpRequest {
  final String email;
  final String password;
  final String displayName;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

/// Provider para login (for one-time operations)
@riverpod
Future<core.UserEntity> signIn(SignInRef ref, SignInRequest request) async {
  final authService = ref.watch(authServiceProvider);
  final crashlyticsService = ref.watch(crashlyticsServiceProvider);

  try {
    final result = await authService.signInWithEmailAndPassword(
      email: request.email,
      password: request.password,
    );

    return result.fold(
      (failure) {
        // Log erro de autenticação
        unawaited(crashlyticsService.recordAuthError(
          authMethod: 'email_password',
          errorCode: 'login_failed',
          errorMessage: failure.message,
        ));
        throw Exception(failure.message);
      },
      (user) {
        return user;
      },
    );
  } catch (e) {
    unawaited(crashlyticsService.recordError(
      exception: e,
      stackTrace: StackTrace.current,
      reason: 'Login error in provider',
    ));
    rethrow;
  }
}

/// Provider para registro (for one-time operations)
@riverpod
Future<core.UserEntity> signUp(SignUpRef ref, SignUpRequest request) async {
  final authService = ref.watch(authServiceProvider);
  final crashlyticsService = ref.watch(crashlyticsServiceProvider);

  try {
    final result = await authService.signUpWithEmailAndPassword(
      email: request.email,
      password: request.password,
      displayName: request.displayName,
    );

    return result.fold(
      (failure) {
        unawaited(crashlyticsService.recordAuthError(
          authMethod: 'email_password',
          errorCode: 'registration_failed',
          errorMessage: failure.message,
        ));
        throw Exception(failure.message);
      },
      (user) {
        return user;
      },
    );
  } catch (e) {
    unawaited(crashlyticsService.recordError(
      exception: e,
      stackTrace: StackTrace.current,
      reason: 'Registration error in provider',
    ));
    rethrow;
  }
}

// =============================================================================
// STREAM PROVIDERS
// =============================================================================

/// Provider para o estado de autenticação usando stream
@riverpod
Stream<core.UserEntity?> authStateStream(AuthStateStreamRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
}

// =============================================================================
// CONVENIENCE PROVIDERS (Derived state)
// =============================================================================

/// Provider para verificar se está logado
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (state) => state.user != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider para usuário atual
@riverpod
core.UserEntity? currentAuthenticatedUser(CurrentAuthenticatedUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (state) => state.user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider para verificar se está sincronizando
@riverpod
bool isSyncInProgress(IsSyncInProgressRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (state) => state.isSyncInProgress,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider para mensagem de sync
@riverpod
String syncMessage(SyncMessageRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (state) => state.syncMessage,
    loading: () => 'Carregando...',
    error: (_, __) => 'Erro',
  );
}
