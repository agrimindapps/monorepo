import 'package:core/core.dart' show AuthProvider, EnhancedAccountDeletionService;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/link_anonymous_with_email_usecase.dart';
import '../../domain/usecases/login_usecase.dart' as local_login;
import '../../domain/usecases/logout_usecase.dart' as local_logout;
import '../../domain/usecases/refresh_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sign_in_anonymously_usecase.dart';
import '../providers/auth_di_providers.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Riverpod notifier for authentication operations
///
/// Manages authentication state following Clean Architecture patterns
/// Uses use cases for all domain operations
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final local_login.LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final local_logout.LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final RefreshUserUseCase _refreshUserUseCase;
  late final SignInAnonymouslyUseCase _signInAnonymouslyUseCase;
  late final LinkAnonymousWithEmailUseCase _linkAnonymousWithEmailUseCase;
  late final EnhancedAccountDeletionService? _enhancedDeletionService;

  @override
  AuthState build() {
    // Get use cases from Riverpod providers
    _loginUseCase = ref.watch(loginUseCaseProvider);
    _registerUseCase = ref.watch(registerUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);
    _getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
    _refreshUserUseCase = ref.watch(refreshUserUseCaseProvider);
    _signInAnonymouslyUseCase = ref.watch(signInAnonymouslyUseCaseProvider);
    _linkAnonymousWithEmailUseCase =
        ref.watch(linkAnonymousWithEmailUseCaseProvider);

    // Try to get optional service
    try {
      _enhancedDeletionService =
          ref.watch(enhancedAccountDeletionServiceProvider);
    } catch (e) {
      _enhancedDeletionService = null;
      debugPrint('AuthNotifier: EnhancedAccountDeletionService not available');
    }

    // Initialize auth state
    _initializeAuthState();

    return const AuthState();
  }

  /// Computed properties for UI
  bool get isAnyOperationInProgress =>
      state.isLoading ||
      state.isLoggingIn ||
      state.isRegistering ||
      state.isLoggingOut ||
      state.isRefreshing;

  String get userDisplayName => state.currentUser?.displayName ?? 'Usuário';
  String get userEmail => state.currentUser?.email ?? '';
  String? get userProfileImage => state.currentUser?.photoUrl;
  bool get hasProfileImage => state.currentUser?.photoUrl?.isNotEmpty == true;
  bool get hasValidUser =>
      state.currentUser != null && state.currentUser!.id.isNotEmpty;

  /// Initializes authentication state by checking for logged user
  Future<void> _initializeAuthState() async {
    try {
      debugPrint('AuthNotifier: Inicializando estado de autenticação');

      state = state.copyWith(
        isInitializing: true,
        errorMessage: null,
      );

      final result = await _getCurrentUserUseCase.call(
        const GetCurrentUserParams(),
      );

      result.fold(
        (failure) {
          debugPrint(
            'AuthNotifier: Falha ao obter usuário atual - ${failure.message}',
          );
          state = state.copyWith(
            currentUser: null,
            isLoggedIn: false,
            isInitializing: false,
            errorMessage: null,
          );
        },
        (user) {
          if (user != null) {
            debugPrint('AuthNotifier: Usuário encontrado - ${user.id}');
            state = state.copyWith(
              currentUser: user,
              isLoggedIn: true,
              isInitializing: false,
              errorMessage: null,
            );
          } else {
            debugPrint('AuthNotifier: Nenhum usuário logado');
            state = state.copyWith(
              currentUser: null,
              isLoggedIn: false,
              isInitializing: false,
              errorMessage: null,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro na inicialização - $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(
        currentUser: null,
        isLoggedIn: false,
        isInitializing: false,
        errorMessage: null,
      );
    }
  }

  /// Authenticates user with email and password
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
        errorMessage: null,
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
            isLoggingIn: false,
            isLoading: false,
            errorMessage: failure.message,
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
            errorMessage: null,
          );
          return Right<Failure, UserEntity>(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no login - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no login: ${e.toString()}';
      state = state.copyWith(
        isLoggingIn: false,
        isLoading: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Registers new user
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
        errorMessage: null,
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
            isRegistering: false,
            isLoading: false,
            errorMessage: failure.message,
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
            errorMessage: null,
          );
          return Right(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no registro - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no registro: ${e.toString()}';
      state = state.copyWith(
        isRegistering: false,
        isLoading: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Logs out user
  Future<Either<Failure, void>> logout({
    bool clearAllData = true,
    bool logAnalytics = true,
  }) async {
    try {
      debugPrint('AuthNotifier: Iniciando logout');

      state = state.copyWith(
        isLoggingOut: true,
        isLoading: true,
        errorMessage: null,
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
            currentUser: null,
            isLoggedIn: false,
            isLoggingOut: false,
            isLoading: false,
            errorMessage: 'Falha no logout, mas sessão local foi encerrada',
          );
          return Left<Failure, void>(failure);
        },
        (_) {
          debugPrint('AuthNotifier: Logout bem-sucedido');
          state = state.copyWith(
            currentUser: null,
            isLoggedIn: false,
            isLoggingOut: false,
            isLoading: false,
            errorMessage: null,
          );
          return const Right<Failure, void>(null);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no logout - $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(
        currentUser: null,
        isLoggedIn: false,
        isLoggingOut: false,
        isLoading: false,
        errorMessage: 'Erro no logout: ${e.toString()}',
      );
      return Left(UnknownFailure(message: 'Erro no logout: ${e.toString()}'));
    }
  }

  /// Refreshes current user data
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

      state = state.copyWith(
        isRefreshing: true,
        errorMessage: null,
      );

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
            isRefreshing: false,
            errorMessage: failure.message,
          );
          return Left(failure);
        },
        (updatedUser) {
          debugPrint('AuthNotifier: Dados atualizados - ${updatedUser.id}');
          state = state.copyWith(
            currentUser: updatedUser,
            isLoggedIn: true,
            isRefreshing: false,
            errorMessage: null,
          );
          return Right(updatedUser);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro na atualização - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro na atualização: ${e.toString()}';
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Deletes user account
  Future<bool> deleteAccount({String? password}) async {
    if (state.currentUser == null) {
      state = state.copyWith(errorMessage: 'Nenhum usuário autenticado');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      debugPrint('AuthNotifier: Iniciando exclusão de conta');

      if (_enhancedDeletionService != null) {
        final result = await _enhancedDeletionService.deleteAccount(
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
              isLoading: false,
              errorMessage: error.message,
            );
            return false;
          },
          (deletionResult) {
            if (deletionResult.isSuccess) {
              debugPrint('AuthNotifier: Conta deletada com sucesso');
              state = state.copyWith(
                currentUser: null,
                isLoggedIn: false,
                isLoading: false,
                errorMessage: null,
              );
              return true;
            } else {
              debugPrint(
                'AuthNotifier: Falha na exclusão - ${deletionResult.userMessage}',
              );
              state = state.copyWith(
                isLoading: false,
                errorMessage: deletionResult.userMessage,
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
          isLoading: false,
          errorMessage:
              'Funcionalidade de exclusão de conta não está disponível',
        );
        return false;
      }
    } catch (e) {
      debugPrint('AuthNotifier: Erro inesperado ao deletar conta - $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
      return false;
    }
  }

  /// Clears error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Forces authentication status check
  Future<void> checkAuthenticationStatus() async {
    await _initializeAuthState();
  }

  /// Sends password reset email
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try {
      debugPrint('AuthNotifier: Enviando email de recuperação para $email');

      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final repository = ref.read(authRepositoryProvider);
      final result = await repository.forgotPassword(email: email);

      return result.fold(
        (Failure failure) {
          debugPrint(
            'AuthNotifier: Falha no envio de recuperação - ${failure.message}',
          );
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
          return Left<Failure, void>(failure);
        },
        (_) {
          debugPrint('AuthNotifier: Email de recuperação enviado com sucesso');
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
          );
          return const Right<Failure, void>(null);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado na recuperação - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro ao enviar email de recuperação: ${e.toString()}';
      state = state.copyWith(
        isLoading: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Signs in anonymously (guest mode)
  Future<Either<Failure, UserEntity>> loginAnonymously() async {
    try {
      debugPrint('AuthNotifier: Iniciando login anônimo');

      state = state.copyWith(
        isLoggingIn: true,
        isLoading: true,
        errorMessage: null,
      );

      final result = await _signInAnonymouslyUseCase.call(const NoParams());

      return result.fold(
        (Failure failure) {
          debugPrint('AuthNotifier: Falha no login anônimo - ${failure.message}');
          state = state.copyWith(
            isLoggingIn: false,
            isLoading: false,
            errorMessage: failure.message,
          );
          return Left<Failure, UserEntity>(failure);
        },
        (UserEntity user) {
          debugPrint('AuthNotifier: Login anônimo bem-sucedido - ${user.id}');
          state = state.copyWith(
            currentUser: user,
            isLoggedIn: true,
            isAnonymous: user.provider == AuthProvider.anonymous,
            isLoggingIn: false,
            isLoading: false,
            errorMessage: null,
          );
          return Right<Failure, UserEntity>(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado no login anônimo - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no login anônimo: ${e.toString()}';
      state = state.copyWith(
        isLoggingIn: false,
        isLoading: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }

  /// Links anonymous account with email/password
  Future<Either<Failure, UserEntity>> linkAnonymousWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthNotifier: Vinculando conta anônima com $email');

      if (!state.isAnonymous) {
        const error = 'Apenas contas anônimas podem ser vinculadas';
        state = state.copyWith(errorMessage: error);
        return const Left(ValidationFailure(message: error));
      }

      state = state.copyWith(
        isLinkingAccount: true,
        isLoading: true,
        errorMessage: null,
      );

      final result = await _linkAnonymousWithEmailUseCase.call(
        LinkAnonymousParams(
          name: name,
          email: email,
          password: password,
        ),
      );

      return result.fold(
        (Failure failure) {
          debugPrint('AuthNotifier: Falha na vinculação - ${failure.message}');
          state = state.copyWith(
            isLinkingAccount: false,
            isLoading: false,
            errorMessage: failure.message,
          );
          return Left<Failure, UserEntity>(failure);
        },
        (UserEntity user) {
          debugPrint('AuthNotifier: Conta vinculada com sucesso - ${user.id}');
          state = state.copyWith(
            currentUser: user,
            isLoggedIn: true,
            isAnonymous: false, // Não é mais anônimo
            isLinkingAccount: false,
            isLoading: false,
            errorMessage: null,
          );
          return Right<Failure, UserEntity>(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthNotifier: Erro inesperado na vinculação - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro ao vincular conta: ${e.toString()}';
      state = state.copyWith(
        isLinkingAccount: false,
        isLoading: false,
        errorMessage: error,
      );
      return Left(UnknownFailure(message: error));
    }
  }
}
