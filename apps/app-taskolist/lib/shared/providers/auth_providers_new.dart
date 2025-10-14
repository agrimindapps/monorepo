import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide getIt;

import '../../core/di/injection.dart' as di;
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/crashlytics_service.dart';
import '../../infrastructure/services/sync_service.dart';

part 'auth_providers_new.g.dart';

// ============================================================================
// Service Providers (mantém injeção via GetIt)
// ============================================================================

@riverpod
TaskManagerAuthService taskManagerAuthService(TaskManagerAuthServiceRef ref) {
  return di.getIt<TaskManagerAuthService>();
}

@riverpod
TaskManagerSyncService taskManagerSyncService(TaskManagerSyncServiceRef ref) {
  return di.getIt<TaskManagerSyncService>();
}

@riverpod
TaskManagerCrashlyticsService taskManagerCrashlyticsService(
  TaskManagerCrashlyticsServiceRef ref,
) {
  return di.getIt<TaskManagerCrashlyticsService>();
}

// ============================================================================
// Auth State Streams
// ============================================================================

@riverpod
Stream<core.UserEntity?> authStateStream(AuthStateStreamRef ref) {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return authService.currentUser;
}

@riverpod
Future<bool> isLoggedIn(IsLoggedInRef ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return await authService.isLoggedIn;
}

@riverpod
Future<core.UserEntity?> currentUser(CurrentUserRef ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return authService.currentUser.first;
}

// ============================================================================
// Auth Actions (family providers convertidos para parâmetros)
// ============================================================================

@riverpod
Future<core.UserEntity> signIn(
  SignInRef ref, {
  required String email,
  required String password,
}) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);

  try {
    final result = await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        unawaited(
          crashlyticsService.recordAuthError(
            authMethod: 'email_password',
            errorCode: 'login_failed',
            errorMessage: failure.message,
          ),
        );
        throw Exception(failure.message);
      },
      (user) => user,
    );
  } catch (e) {
    unawaited(
      crashlyticsService.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Login error in provider',
      ),
    );
    rethrow;
  }
}

@riverpod
Future<core.UserEntity> signUp(
  SignUpRef ref, {
  required String email,
  required String password,
  required String displayName,
}) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);

  try {
    final result = await authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      (failure) {
        unawaited(
          crashlyticsService.recordAuthError(
            authMethod: 'email_password',
            errorCode: 'registration_failed',
            errorMessage: failure.message,
          ),
        );
        throw Exception(failure.message);
      },
      (user) => user,
    );
  } catch (e) {
    unawaited(
      crashlyticsService.recordError(
        exception: e,
        stackTrace: StackTrace.current,
        reason: 'Registration error in provider',
      ),
    );
    rethrow;
  }
}

@riverpod
Future<void> signOut(SignOutRef ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);

  final result = await authService.signOut();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
}

// ============================================================================
// Auth Notifier (StateNotifier → @riverpod class)
// ============================================================================

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final TaskManagerAuthService _authService;
  late final TaskManagerSyncService _syncService;
  StreamSubscription<core.UserEntity?>? _subscription;

  bool _isSyncInProgress = false;
  bool _hasPerformedInitialSync = false;
  String _syncMessage = 'Sincronizando dados...';

  bool get isSyncInProgress => _isSyncInProgress;
  bool get hasPerformedInitialSync => _hasPerformedInitialSync;
  String get syncMessage => _syncMessage;

  @override
  FutureOr<core.UserEntity?> build() async {
    _authService = ref.watch(taskManagerAuthServiceProvider);
    _syncService = ref.watch(taskManagerSyncServiceProvider);

    // Listen to auth state changes
    _subscription = _authService.currentUser.listen(
      (user) => state = AsyncValue.data(user),
      onError:
          (Object error, StackTrace stackTrace) =>
              state = AsyncValue.error(error, stackTrace),
    );

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Return initial user state
    return await _authService.currentUser.first;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(String email, String password, String displayName) async {
    state = const AsyncValue.loading();

    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final result = await _authService.signOut();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signInAnonymously() async {
    print('🔄 AuthNotifier: Iniciando signInAnonymously...');
    state = const AsyncValue.loading();

    final result = await _authService.signInAnonymously();

    result.fold(
      (failure) {
        print('❌ AuthNotifier: Erro no login anônimo: $failure');
        state = AsyncValue.error(failure, StackTrace.current);
        throw Exception(failure.message);
      },
      (user) {
        print('✅ AuthNotifier: Login anônimo bem-sucedido: ${user.id}');
        state = AsyncValue.data(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithGoogle();

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> loginAndSync(String email, String password) async {
    try {
      await signInWithEmailAndPassword(email, password);
      final currentState = state;
      if (currentState is AsyncError ||
          (currentState is AsyncData && currentState.value == null)) {
        return;
      }

      final user = (currentState as AsyncData<core.UserEntity?>).value!;
      if (!_hasPerformedInitialSync && !isAnonymous(user)) {
        await _startPostLoginSync(user);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _startPostLoginSync(core.UserEntity user) async {
    if (_isSyncInProgress) return;
    if (isAnonymous(user)) return;

    _isSyncInProgress = true;
    _syncMessage = 'Sincronizando dados...';

    try {
      const isUserPremium = false;
      final result = await _syncService.syncAll(
        userId: user.id,
        isUserPremium: isUserPremium,
      );

      result.fold(
        (failure) {
          print('❌ Erro na sincronização pós-login: ${failure.message}');
        },
        (_) {
          _hasPerformedInitialSync = true;
        },
      );
    } catch (e) {
      print('❌ Erro durante sincronização: $e');
    } finally {
      _isSyncInProgress = false;
    }
  }

  bool isAnonymous(core.UserEntity user) {
    return user.provider.name == 'anonymous';
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _authService.sendPasswordResetEmail(email: email);
    result.fold((failure) => throw Exception(failure.message), (_) => null);
  }
}

// ============================================================================
// Derived Providers (computados a partir do auth state)
// ============================================================================

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
}

@riverpod
core.UserEntity? currentAuthenticatedUser(CurrentAuthenticatedUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}
