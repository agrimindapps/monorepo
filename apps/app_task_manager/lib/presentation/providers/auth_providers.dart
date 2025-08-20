import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection_container.dart' as di;
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/watch_auth_state.dart';

// Provider para o estado de autenticação
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final watchAuthState = di.sl<WatchAuthState>();
  return watchAuthState();
});

// Provider para usuário atual
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final getCurrentUser = di.sl<GetCurrentUser>();
  final result = await getCurrentUser();
  
  return result.fold(
    (failure) => throw failure,
    (user) => user,
  );
});

// Provider para login
final signInProvider = FutureProvider.family<UserEntity, SignInRequest>((ref, request) async {
  final signIn = di.sl<SignIn>();
  
  final result = await signIn(SignInParams(
    email: request.email,
    password: request.password,
  ));
  
  return result.fold(
    (failure) => throw failure,
    (user) {
      // Invalidar o auth state para atualizar
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProvider);
      return user;
    },
  );
});

// Provider para registro
final signUpProvider = FutureProvider.family<UserEntity, SignUpRequest>((ref, request) async {
  final signUp = di.sl<SignUp>();
  
  final result = await signUp(SignUpParams(
    email: request.email,
    password: request.password,
    name: request.name,
  ));
  
  return result.fold(
    (failure) => throw failure,
    (user) {
      // Invalidar o auth state para atualizar
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProvider);
      return user;
    },
  );
});

// Provider para logout
final signOutProvider = FutureProvider<void>((ref) async {
  final signOut = di.sl<SignOut>();
  
  final result = await signOut();
  
  return result.fold(
    (failure) => throw failure,
    (_) {
      // Invalidar todos os providers de auth
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUserProvider);
    },
  );
});

// NotifierProvider para gerenciar estado de autenticação
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthNotifier({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AsyncValue.loading()) {
    _checkAuthState();
  }

  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  Future<void> _checkAuthState() async {
    final result = await _getCurrentUser();
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    final result = await _signIn(SignInParams(
      email: email,
      password: password,
    ));
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    
    final result = await _signUp(SignUpParams(
      email: email,
      password: password,
      name: name,
    ));
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final result = await _signOut();
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> refreshAuthState() async {
    await _checkAuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(
    signIn: di.sl<SignIn>(),
    signUp: di.sl<SignUp>(),
    signOut: di.sl<SignOut>(),
    getCurrentUser: di.sl<GetCurrentUser>(),
  );
});

// Classes para parâmetros
class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SignInRequest &&
      other.email == email &&
      other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

class SignUpRequest {
  final String email;
  final String password;
  final String name;

  const SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SignUpRequest &&
      other.email == email &&
      other.password == password &&
      other.name == name;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ name.hashCode;
}