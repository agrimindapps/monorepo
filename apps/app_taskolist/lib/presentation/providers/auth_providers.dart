import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart' as core;

import '../../core/di/injection_container.dart' as di;
import '../../infrastructure/services/crashlytics_service.dart';
import '../../infrastructure/services/auth_service.dart';

// Provider para o TaskManagerAuthService
final taskManagerAuthServiceProvider = Provider<TaskManagerAuthService>((ref) {
  return di.sl<TaskManagerAuthService>();
});

// Provider para o estado de autenticação usando o TaskManagerAuthService
final authStateStreamProvider = StreamProvider<core.UserEntity?>((ref) {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return authService.currentUser;
});

// Provider para verificar se está logado
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return await authService.isLoggedIn;
});

// Provider para usuário atual
final currentUserProvider = FutureProvider<core.UserEntity?>((ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return authService.currentUser.first;
});

// Request classes para login/registro
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
    required this.displayName
  });
}

// Provider para login
final signInProvider = FutureProvider.family<core.UserEntity, SignInRequest>((ref, request) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  final crashlyticsService = di.sl<TaskManagerCrashlyticsService>();
  
  try {
    final result = await authService.signInWithEmailAndPassword(
      email: request.email,
      password: request.password,
    );
    
    return result.fold(
      (failure) {
        // Log erro de autenticação
        crashlyticsService.recordAuthError(
          authMethod: 'email_password',
          errorCode: 'login_failed',
          errorMessage: failure.message,
        );
        throw failure;
      },
      (user) {
        return user;
      },
    );
  } catch (e) {
    crashlyticsService.recordError(
      exception: e,
      stackTrace: StackTrace.current,
      reason: 'Login error in provider',
    );
    rethrow;
  }
});

// Provider para registro
final signUpProvider = FutureProvider.family<core.UserEntity, SignUpRequest>((ref, request) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  final crashlyticsService = di.sl<TaskManagerCrashlyticsService>();
  
  try {
    final result = await authService.signUpWithEmailAndPassword(
      email: request.email,
      password: request.password,
      displayName: request.displayName,
    );
    
    return result.fold(
      (failure) {
        crashlyticsService.recordAuthError(
          authMethod: 'email_password',
          errorCode: 'registration_failed',
          errorMessage: failure.message,
        );
        throw failure;
      },
      (user) {
        return user;
      },
    );
  } catch (e) {
    crashlyticsService.recordError(
      exception: e,
      stackTrace: StackTrace.current,
      reason: 'Registration error in provider',
    );
    rethrow;
  }
});

// Provider para logout
final signOutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  
  final result = await authService.signOut();
  return result.fold(
    (failure) => throw failure,
    (_) => null,
  );
});

// Auth notifier para gerenciar estado global de autenticação
class AuthNotifier extends StateNotifier<AsyncValue<core.UserEntity?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  final TaskManagerAuthService _authService;
  StreamSubscription<core.UserEntity?>? _subscription;

  void _init() {
    _subscription = _authService.currentUser.listen(
      (user) => state = AsyncValue.data(user),
      onError: (error, stackTrace) => state = AsyncValue.error(error, stackTrace),
    );
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
        throw failure; // Propagar o erro para quem chamou
      },
      (user) {
        print('✅ AuthNotifier: Login anônimo bem-sucedido: ${user?.id}');
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

  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _authService.sendPasswordResetEmail(email: email);
    
    result.fold(
      (failure) => throw failure,
      (_) => null,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Provider para o AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<core.UserEntity?>>((ref) {
  final authService = ref.watch(taskManagerAuthServiceProvider);
  return AuthNotifier(authService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentAuthenticatedUserProvider = Provider<core.UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});