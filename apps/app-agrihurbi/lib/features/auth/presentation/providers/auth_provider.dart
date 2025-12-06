import 'package:core/core.dart' show EnhancedAccountDeletionService;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart' as local_login;
import '../../domain/usecases/logout_usecase.dart' as local_logout;
import '../../domain/usecases/refresh_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_di_providers.dart';

part 'auth_provider.g.dart';

/// State class for Auth
class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isInitializing;
  final bool isLoggingIn;
  final bool isRegistering;
  final bool isLoggingOut;
  final bool isRefreshing;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.isInitializing = true,
    this.isLoggingIn = false,
    this.isRegistering = false,
    this.isLoggingOut = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    bool? isLoggedIn,
    bool? isInitializing,
    bool? isLoggingIn,
    bool? isRegistering,
    bool? isLoggingOut,
    bool? isRefreshing,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isInitializing: isInitializing ?? this.isInitializing,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isRegistering: isRegistering ?? this.isRegistering,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Estado geral indicando se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
      isLoading || isLoggingIn || isRegistering || isLoggingOut || isRefreshing;

  /// Informações do usuário para exibição
  String get userDisplayName => currentUser?.displayName ?? 'Usuário';
  String get userEmail => currentUser?.email ?? '';
  String? get userProfileImage => currentUser?.photoUrl;
  bool get hasProfileImage => currentUser?.photoUrl?.isNotEmpty == true;

  /// Verifica se o usuário atual é válido
  bool get hasValidUser => currentUser != null && currentUser!.id.isNotEmpty;
}

/// Auth Notifier using Riverpod code generation
///
/// Gerencia estado de autenticação seguindo padrões Riverpod
/// Utiliza use cases para todas as operações de domínio
@riverpod
class AuthNotifier extends _$AuthNotifier {
  local_login.LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  RegisterUseCase get _registerUseCase => ref.read(registerUseCaseProvider);
  local_logout.LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);
  GetCurrentUserUseCase get _getCurrentUserUseCase => ref.read(getCurrentUserUseCaseProvider);
  RefreshUserUseCase get _refreshUserUseCase => ref.read(refreshUserUseCaseProvider);
  EnhancedAccountDeletionService? get _enhancedDeletionService {
    try {
      return ref.read(enhancedAccountDeletionServiceProvider);
    } catch (_) {
      return null;
    }
  }

  @override
  AuthState build() {
    _initializeAuthState();
    return const AuthState();
  }

  // Convenience getters for backward compatibility
  UserEntity? get currentUser => state.currentUser;
  bool get isLoading => state.isLoading;
  bool get isLoggedIn => state.isLoggedIn;
  bool get isInitializing => state.isInitializing;
  bool get isLoggingIn => state.isLoggingIn;
  bool get isRegistering => state.isRegistering;
  bool get isLoggingOut => state.isLoggingOut;
  bool get isRefreshing => state.isRefreshing;
  String? get errorMessage => state.errorMessage;
  bool get isAnyOperationInProgress => state.isAnyOperationInProgress;
  String get userDisplayName => state.userDisplayName;
  String get userEmail => state.userEmail;
  String? get userProfileImage => state.userProfileImage;
  bool get hasProfileImage => state.hasProfileImage;
  bool get hasValidUser => state.hasValidUser;

  /// Inicializa o estado de autenticação verificando usuário logado
  Future<void> _initializeAuthState() async {
    try {
      debugPrint('AuthNotifier: Inicializando estado de autenticação');

      state = state.copyWith(isInitializing: true, clearError: true);

      final result = await _getCurrentUserUseCase.call(
        const GetCurrentUserParams(),
      );

      result.fold(
        (failure) {
          debugPrint(
            'AuthNotifier: Falha ao obter usuário atual - ${failure.message}',
          );
          state = state.copyWith(
            isInitializing: false,
            isLoggedIn: false,
            clearUser: true,
          );
        },
        (user) {
          if (user != null) {
            debugPrint('AuthNotifier: Usuário encontrado - ${user.id}');
            state = state.copyWith(
              currentUser: user,
              isLoggedIn: true,
              isInitializing: false,
            );
          } else {
            debugPrint('AuthNotifier: Nenhum usuário logado');
            state = state.copyWith(
              isInitializing: false,
              isLoggedIn: false,
              clearUser: true,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro na inicialização - $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(
        isInitializing: false,
        isLoggedIn: false,
        clearUser: true,
      );
    }
  }

  /// Autentica usuário com email e senha
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('AuthNotifier: Iniciando login para $email');

      state = state.copyWith(
        isLoggingIn: true,
        isLoading: true,
        clearError: true,
      );

      final result = await _loginUseCase.call(
        local_login.LoginParams(
          email: email,
          password: password,
          rememberMe: rememberMe,
        ),
      );

      return result.fold(
        (Failure failure) {
          debugPrint('AuthNotifier: Falha no login - ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            isLoggingIn: false,
            isLoading: false,
          );
          return Left<Failure, UserEntity>(failure);
        },
        (UserEntity user) {
          debugPrint('AuthNotifier: Login bem-sucedido - ${user.id}');
          state = state.copyWith(
            currentUser: user,
            isLoggedIn: true,
            isLoggingIn: false,
            isLoading: false,
            clearError: true,
          );
          return Right<Failure, UserEntity>(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no login - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no login: ${e.toString()}';
      state = state.copyWith(
        errorMessage: error,
        isLoggingIn: false,
        isLoading: false,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Registra novo usuário
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    bool acceptTerms = false,
  }) async {
    try {
      debugPrint('AuthNotifier: Iniciando registro para $email');

      state = state.copyWith(
        isRegistering: true,
        isLoading: true,
        clearError: true,
      );

      final result = await _registerUseCase.call(
        RegisterParams(
          name: name,
          email: email,
          password: password,
          phone: phone,
          acceptTerms: acceptTerms,
        ),
      );

      return result.fold(
        (failure) {
          debugPrint('AuthNotifier: Falha no registro - ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            isRegistering: false,
            isLoading: false,
          );
          return Left(failure);
        },
        (user) {
          debugPrint('AuthNotifier: Registro bem-sucedido - ${user.id}');
          state = state.copyWith(
            currentUser: user,
            isLoggedIn: true,
            isRegistering: false,
            isLoading: false,
            clearError: true,
          );
          return Right(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no registro - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no registro: ${e.toString()}';
      state = state.copyWith(
        errorMessage: error,
        isRegistering: false,
        isLoading: false,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Encerra sessão do usuário
  Future<Either<Failure, void>> logout({
    bool clearAllData = true,
    bool logAnalytics = true,
  }) async {
    try {
      debugPrint('AuthNotifier: Iniciando logout');

      state = state.copyWith(
        isLoggingOut: true,
        isLoading: true,
        clearError: true,
      );

      final result = await _logoutUseCase.call(
        local_logout.LogoutParams(
          clearAllData: clearAllData,
          logAnalytics: logAnalytics,
        ),
      );

      return result.fold(
        (Failure failure) {
          debugPrint('AuthNotifier: Falha no logout - ${failure.message}');
          state = state.copyWith(
            errorMessage: 'Falha no logout, mas sessão local foi encerrada',
            isLoggedIn: false,
            isLoggingOut: false,
            isLoading: false,
            clearUser: true,
          );
          return Left<Failure, void>(failure);
        },
        (_) {
          debugPrint('AuthNotifier: Logout bem-sucedido');
          state = state.copyWith(
            isLoggedIn: false,
            isLoggingOut: false,
            isLoading: false,
            clearUser: true,
            clearError: true,
          );
          return const Right<Failure, void>(null);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no logout - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro no logout: ${e.toString()}';
      state = state.copyWith(
        errorMessage: error,
        isLoggedIn: false,
        isLoggingOut: false,
        isLoading: false,
        clearUser: true,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Atualiza dados do usuário atual
  Future<Either<Failure, UserEntity>> refreshUser({
    bool forceRemoteSync = false,
    bool validateRefreshedData = true,
    bool fallbackToCurrent = true,
  }) async {
    try {
      if (state.currentUser == null) {
        const error = 'Nenhum usuário logado para atualizar';
        state = state.copyWith(errorMessage: error);
        return const Left(ValidationFailure(message: error));
      }

      debugPrint(
        'AuthNotifier: Atualizando dados do usuário ${state.currentUser!.id}',
      );

      state = state.copyWith(isRefreshing: true, clearError: true);

      final result = await _refreshUserUseCase.call(
        RefreshUserParams(
          forceRemoteSync: forceRemoteSync,
          validateRefreshedData: validateRefreshedData,
          fallbackToCurrent: fallbackToCurrent,
        ),
      );

      return result.fold(
        (failure) {
          debugPrint('AuthNotifier: Falha na atualização - ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            isRefreshing: false,
          );
          return Left(failure);
        },
        (updatedUser) {
          debugPrint('AuthNotifier: Dados atualizados - ${updatedUser.id}');
          state = state.copyWith(
            currentUser: updatedUser,
            isRefreshing: false,
            clearError: true,
          );
          return Right(updatedUser);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro na atualização - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro na atualização: ${e.toString()}';
      state = state.copyWith(
        errorMessage: error,
        isRefreshing: false,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Força verificação do estado de autenticação
  Future<void> checkAuthenticationStatus() async {
    await _initializeAuthState();
  }

  /// Deleta a conta do usuário
  Future<bool> deleteAccount({String? password}) async {
    if (state.currentUser == null) {
      state = state.copyWith(errorMessage: 'Nenhum usuário autenticado');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      debugPrint('AuthNotifier: Iniciando exclusão de conta');

      if (_enhancedDeletionService != null) {
        final result = await _enhancedDeletionService!.deleteAccount(
          password: password ?? '',
          userId: state.currentUser!.id,
          isAnonymous: false,
        );

        return result.fold(
          (error) {
            debugPrint(
              'AuthNotifier: Erro ao deletar conta - ${error.message}',
            );
            state = state.copyWith(
              errorMessage: error.message,
              isLoading: false,
            );
            return false;
          },
          (deletionResult) {
            if (deletionResult.isSuccess) {
              debugPrint('AuthNotifier: Conta deletada com sucesso');
              state = state.copyWith(
                isLoading: false,
                isLoggedIn: false,
                clearUser: true,
                clearError: true,
              );
              return true;
            } else {
              debugPrint(
                'AuthNotifier: Falha na exclusão - ${deletionResult.userMessage}',
              );
              state = state.copyWith(
                errorMessage: deletionResult.userMessage,
                isLoading: false,
              );
              return false;
            }
          },
        );
      } else {
        debugPrint(
          'AuthNotifier: EnhancedAccountDeletionService not available',
        );
        state = state.copyWith(
          errorMessage: 'Funcionalidade de exclusão de conta não está disponível',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      debugPrint('AuthNotifier: Erro inesperado ao deletar conta - $e');
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoading: false,
      );
      return false;
    }
  }
}
