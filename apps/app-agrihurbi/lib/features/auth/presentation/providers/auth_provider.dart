import 'package:core/core.dart' show EnhancedAccountDeletionService;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart' as local_login;
import '../../domain/usecases/logout_usecase.dart' as local_logout;
import '../../domain/usecases/refresh_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// Provider Riverpod para AuthProvider
///
/// Integra GetIt com Riverpod para gerenciamento de estado
final authProviderProvider = Provider<AuthProvider>((ref) {
  return getIt<AuthProvider>();
});

/// Provider para operações de autenticação usando Clean Architecture
///
/// Gerencia estado de autenticação seguindo padrões Provider
/// Utiliza use cases para todas as operações de domínio
@singleton
class AuthProvider extends ChangeNotifier {
  final local_login.LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final local_logout.LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RefreshUserUseCase _refreshUserUseCase;
  final EnhancedAccountDeletionService? _enhancedDeletionService;

  AuthProvider({
    required local_login.LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required local_logout.LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RefreshUserUseCase refreshUserUseCase,
    EnhancedAccountDeletionService? enhancedAccountDeletionService,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _refreshUserUseCase = refreshUserUseCase,
       _enhancedDeletionService = enhancedAccountDeletionService {
    _initializeAuthState();
  }

  // === ESTADO PRIVADO ===

  UserEntity? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isInitializing = true;

  // Estados específicos de operações
  bool _isLoggingIn = false;
  bool _isRegistering = false;
  bool _isLoggingOut = false;
  bool _isRefreshing = false;

  String? _errorMessage;

  // === GETTERS PÚBLICOS ===

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;

  bool get isLoggingIn => _isLoggingIn;
  bool get isRegistering => _isRegistering;
  bool get isLoggingOut => _isLoggingOut;
  bool get isRefreshing => _isRefreshing;

  String? get errorMessage => _errorMessage;

  /// Estado geral indicando se alguma operação está em andamento
  bool get isAnyOperationInProgress =>
      _isLoading ||
      _isLoggingIn ||
      _isRegistering ||
      _isLoggingOut ||
      _isRefreshing;

  /// Informações do usuário para exibição
  String get userDisplayName => _currentUser?.displayName ?? 'Usuário';
  String get userEmail => _currentUser?.email ?? '';
  String? get userProfileImage => _currentUser?.photoUrl;
  bool get hasProfileImage => _currentUser?.photoUrl?.isNotEmpty == true;

  /// Inicializa o estado de autenticação verificando usuário logado
  Future<void> _initializeAuthState() async {
    try {
      debugPrint('AuthProvider: Inicializando estado de autenticação');

      _isInitializing = true;
      _clearError();
      notifyListeners();

      final result = await _getCurrentUserUseCase.call(
        const GetCurrentUserParams(),
      );

      result.fold(
        (failure) {
          debugPrint(
            'AuthProvider: Falha ao obter usuário atual - ${failure.message}',
          );
          _clearUserState();
        },
        (user) {
          if (user != null) {
            debugPrint('AuthProvider: Usuário encontrado - ${user.id}');
            _setUserState(user);
          } else {
            debugPrint('AuthProvider: Nenhum usuário logado');
            _clearUserState();
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: Erro na inicialização - $e');
      debugPrint('StackTrace: $stackTrace');
      _clearUserState();
    } finally {
      _isInitializing = false;
      notifyListeners();
      debugPrint('AuthProvider: Inicialização concluída');
    }
  }

  /// Autentica usuário com email e senha
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('AuthProvider: Iniciando login para $email');

      _isLoggingIn = true;
      _setLoading(true);
      _clearError();
      notifyListeners();

      final result = await _loginUseCase.call(
        local_login.LoginParams(
          email: email,
          password: password,
          rememberMe: rememberMe,
        ),
      );

      return result.fold(
        (Failure failure) {
          debugPrint('AuthProvider: Falha no login - ${failure.message}');
          _setError(failure.message);
          return Left<Failure, UserEntity>(failure);
        },
        (UserEntity user) {
          debugPrint('AuthProvider: Login bem-sucedido - ${user.id}');
          _setUserState(user);
          return Right<Failure, UserEntity>(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: Erro inesperado no login - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no login: ${e.toString()}';
      _setError(error);
      return Left(UnknownFailure(message: error));
    } finally {
      _isLoggingIn = false;
      _setLoading(false);
      notifyListeners();
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
      debugPrint('AuthProvider: Iniciando registro para $email');

      _isRegistering = true;
      _setLoading(true);
      _clearError();
      notifyListeners();

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
          debugPrint('AuthProvider: Falha no registro - ${failure.message}');
          _setError(failure.message);
          return Left(failure);
        },
        (user) {
          debugPrint('AuthProvider: Registro bem-sucedido - ${user.id}');
          _setUserState(user);
          return Right(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: Erro inesperado no registro - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro inesperado no registro: ${e.toString()}';
      _setError(error);
      return Left(UnknownFailure(message: error));
    } finally {
      _isRegistering = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Encerra sessão do usuário
  Future<Either<Failure, void>> logout({
    bool clearAllData = true,
    bool logAnalytics = true,
  }) async {
    try {
      debugPrint('AuthProvider: Iniciando logout');

      _isLoggingOut = true;
      _setLoading(true);
      _clearError();
      notifyListeners();

      final result = await _logoutUseCase.call(
        local_logout.LogoutParams(
          clearAllData: clearAllData,
          logAnalytics: logAnalytics,
        ),
      );

      return result.fold(
        (Failure failure) {
          debugPrint('AuthProvider: Falha no logout - ${failure.message}');
          // Mesmo com falha, limpa estado local
          _clearUserState();
          _setError('Falha no logout, mas sessão local foi encerrada');
          return Left<Failure, void>(failure);
        },
        (_) {
          debugPrint('AuthProvider: Logout bem-sucedido');
          _clearUserState();
          return const Right<Failure, void>(null);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: Erro inesperado no logout - $e');
      debugPrint('StackTrace: $stackTrace');
      // Sempre limpa estado local, mesmo com erro
      _clearUserState();
      final error = 'Erro no logout: ${e.toString()}';
      _setError(error);
      return Left(UnknownFailure(message: error));
    } finally {
      _isLoggingOut = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Atualiza dados do usuário atual
  Future<Either<Failure, UserEntity>> refreshUser({
    bool forceRemoteSync = false,
    bool validateRefreshedData = true,
    bool fallbackToCurrent = true,
  }) async {
    try {
      if (_currentUser == null) {
        const error = 'Nenhum usuário logado para atualizar';
        _setError(error);
        return const Left(ValidationFailure(message: error));
      }

      debugPrint(
        'AuthProvider: Atualizando dados do usuário ${_currentUser!.id}',
      );

      _isRefreshing = true;
      _clearError();
      notifyListeners();

      final result = await _refreshUserUseCase.call(
        RefreshUserParams(
          forceRemoteSync: forceRemoteSync,
          validateRefreshedData: validateRefreshedData,
          fallbackToCurrent: fallbackToCurrent,
        ),
      );

      return result.fold(
        (failure) {
          debugPrint('AuthProvider: Falha na atualização - ${failure.message}');
          _setError(failure.message);
          return Left(failure);
        },
        (updatedUser) {
          debugPrint('AuthProvider: Dados atualizados - ${updatedUser.id}');
          _setUserState(updatedUser);
          return Right(updatedUser);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthProvider: Erro na atualização - $e');
      debugPrint('StackTrace: $stackTrace');
      final error = 'Erro na atualização: ${e.toString()}';
      _setError(error);
      return Left(UnknownFailure(message: error));
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _clearError();
  }

  /// Verifica se o usuário atual é válido
  bool get hasValidUser => _currentUser != null && _currentUser!.id.isNotEmpty;

  /// Força verificação do estado de autenticação
  Future<void> checkAuthenticationStatus() async {
    await _initializeAuthState();
  }

  // === MÉTODOS PRIVADOS ===

  /// Define estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define mensagem de erro
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
    debugPrint('AuthProvider: Erro definido - $error');
  }

  /// Limpa mensagem de erro
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Define estado do usuário logado
  void _setUserState(UserEntity user) {
    _currentUser = user;
    _isLoggedIn = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('AuthProvider: Estado do usuário definido - ${user.id}');
  }

  /// Limpa estado do usuário
  void _clearUserState() {
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
    debugPrint('AuthProvider: Estado do usuário limpo');
  }

  /// Deleta a conta do usuário
  /// TODO: Integrate EnhancedAccountDeletionService when IAuthRepository adapter is implemented
  Future<bool> deleteAccount({String? password}) async {
    if (_currentUser == null) {
      _setError('Nenhum usuário autenticado');
      return false;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      debugPrint('AuthProvider: Iniciando exclusão de conta');

      if (_enhancedDeletionService != null) {
        // Use Enhanced Account Deletion Service if available
        final result = await _enhancedDeletionService.deleteAccount(
          password: password ?? '',
          userId: _currentUser!.id,
          isAnonymous: false, // agrihurbi doesn't support anonymous
        );

        return result.fold(
          (error) {
            debugPrint(
              'AuthProvider: Erro ao deletar conta - ${error.message}',
            );
            _setError(error.message);
            _isLoading = false;
            notifyListeners();
            return false;
          },
          (deletionResult) {
            if (deletionResult.isSuccess) {
              debugPrint('AuthProvider: Conta deletada com sucesso');
              _performPostDeletionCleanup();
              return true;
            } else {
              debugPrint(
                'AuthProvider: Falha na exclusão - ${deletionResult.userMessage}',
              );
              _setError(deletionResult.userMessage);
              _isLoading = false;
              notifyListeners();
              return false;
            }
          },
        );
      } else {
        // Fallback: Basic account deletion (requires implementation)
        debugPrint(
          'AuthProvider: EnhancedAccountDeletionService not available',
        );
        _setError('Funcionalidade de exclusão de conta não está disponível');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('AuthProvider: Erro inesperado ao deletar conta - $e');
      _setError('Erro inesperado: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _performPostDeletionCleanup() {
    _currentUser = null;
    _isLoggedIn = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    debugPrint('AuthProvider: Limpeza pós-exclusão concluída');
  }

  @override
  void dispose() {
    debugPrint('AuthProvider: Disposing');
    super.dispose();
  }
}
