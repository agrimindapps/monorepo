import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../core/providers/core_providers.dart';
import '../../infrastructure/services/auth_service.dart';
import '../../infrastructure/services/sync_service.dart';

part 'auth_providers.g.dart';

final authStateStreamProvider = StreamProvider<core.UserEntity?>((ref) async* {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);
  yield* authService.currentUser;
});
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);
  return await authService.isLoggedIn;
});
final currentUserProvider = FutureProvider<core.UserEntity?>((ref) async {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);
  return authService.currentUser.first;
});

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

final signInProvider = FutureProvider.family<core.UserEntity, SignInRequest>((
  ref,
  request,
) async {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);

  try {
    final result = await authService.signInWithEmailAndPassword(
      email: request.email,
      password: request.password,
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
      (user) {
        return user;
      },
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
});
final signUpProvider = FutureProvider.family<core.UserEntity, SignUpRequest>((
  ref,
  request,
) async {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);
  final crashlyticsService = ref.watch(taskManagerCrashlyticsServiceProvider);

  try {
    final result = await authService.signUpWithEmailAndPassword(
      email: request.email,
      password: request.password,
      displayName: request.displayName,
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
      (user) {
        return user;
      },
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
});
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = await ref.watch(taskManagerAuthServiceProvider.future);

  final result = await authService.signOut();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

/// Notifier para gerenciar autenticação
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late TaskManagerAuthService _authService;
  late TaskManagerSyncService _syncService;
  StreamSubscription<core.UserEntity?>? _subscription;
  bool _isSyncInProgress = false;
  bool _hasPerformedInitialSync = false;

  @override
  Future<core.UserEntity?> build() async {
    _authService = ref.watch(taskManagerAuthServiceProvider).requireValue;
    _syncService = ref.watch(taskManagerSyncServiceProvider);

    // Cleanup subscription ao descartar notifier
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Inicializar subscription para manter estado sincronizado
    _subscription = _authService.currentUser.listen(
      (user) => state = AsyncValue.data(user),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );

    return _authService.currentUser.first;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (user) => user,
      );
    });
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncValue.loading();

    final result = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (user) => user,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final result = await _authService.signOut();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> signInAnonymously() async {
    debugPrint('🔄 AuthNotifier: Iniciando signInAnonymously...');
    state = const AsyncValue.loading();

    final result = await _authService.signInAnonymously();

    result.fold(
      (failure) {
        debugPrint('❌ AuthNotifier: Erro no login anônimo: $failure');
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (user) {
        debugPrint('✅ AuthNotifier: Login anônimo bem-sucedido: ${user.id}');
        state = AsyncValue.data(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    final result = await _authService.signInWithGoogle();

    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (user) => user,
      );
    });
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

  /// Inicia processo de sincronização pós-login (apenas para usuários não anônimos)
  Future<void> _startPostLoginSync(core.UserEntity user) async {
    if (_isSyncInProgress) return;
    if (isAnonymous(user)) {
      return;
    }

    _isSyncInProgress = true;

    try {
      const isUserPremium = false;
      final result = await _syncService.syncAll(
        userId: user.id,
        isUserPremium: isUserPremium,
      );

      result.fold(
        (failure) {
          debugPrint('❌ Erro na sincronização pós-login: ${failure.message}');
        },
        (_) {
          _hasPerformedInitialSync = true;
        },
      );
    } catch (e) {
      debugPrint('❌ Erro durante sincronização: $e');
    } finally {
      _isSyncInProgress = false;
    }
  }

  /// Verifica se é usuário anônimo
  bool isAnonymous(core.UserEntity user) {
    return user.provider.name == 'anonymous';
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _authService.sendPasswordResetEmail(email: email);

    result.fold((failure) => throw Exception(failure.message), (_) => null);
  }
}

/// Provider que retorna se o usuário está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Provider que retorna o usuário autenticado atual
final currentAuthenticatedUserProvider = Provider<core.UserEntity?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});
