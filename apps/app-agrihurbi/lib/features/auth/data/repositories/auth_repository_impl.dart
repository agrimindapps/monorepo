import 'package:core/core.dart' hide UserEntity, Failure, NetworkFailure, ValidationFailure, UnknownFailure, CacheFailure, ServerFailure;
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementação do repositório de autenticação seguindo Clean Architecture
/// 
/// Aplica estratégia local-first com fallback para remoto
/// Mantém consistência entre dados locais e remotos
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;

  const AuthRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivity,
  );

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Iniciando login para $email');
      final hasConnection = await _hasNetworkConnection();
      
      if (hasConnection) {
        final remoteResult = await _loginRemote(email, password);
        
        return remoteResult.fold(
          (failure) {
            debugPrint('AuthRepositoryImpl: Falha no login remoto - ${failure.message}');
            return Left(failure);
          },
          (userModel) async {
            await _cacheUserLocally(userModel);
            debugPrint('AuthRepositoryImpl: Login remoto bem-sucedido - ${userModel.id}');
            return Right(userModel.toEntity());
          },
        );
      } else {
        debugPrint('AuthRepositoryImpl: Sem conectividade - login offline não disponível');
        return const Left(NetworkFailure(
          message: 'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro inesperado no login - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro inesperado no login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Iniciando registro para $email');
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para criar nova conta.',
        ));
      }
      final remoteResult = await _registerRemote(name, email, password, phone);
      
      return remoteResult.fold(
        (failure) {
          debugPrint('AuthRepositoryImpl: Falha no registro - ${failure.message}');
          return Left(failure);
        },
        (userModel) async {
          await _cacheUserLocally(userModel);
          debugPrint('AuthRepositoryImpl: Registro bem-sucedido - ${userModel.id}');
          return Right(userModel.toEntity());
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro inesperado no registro - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro inesperado no registro: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      debugPrint('AuthRepositoryImpl: Iniciando login anônimo');
      
      final userModel = await _remoteDataSource.signInAnonymously();
      await _cacheUserLocally(userModel);
      
      debugPrint('AuthRepositoryImpl: Login anônimo bem-sucedido - ${userModel.id}');
      return Right(userModel.toEntity());
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro no login anônimo - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro no login anônimo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> linkAnonymousWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Vinculando conta anônima com email $email');
      
      // Obtém usuário anônimo atual
      final cachedUser = await _localDataSource.getLastUser();
      if (cachedUser == null) {
        return const Left(ValidationFailure(message: 'Nenhum usuário anônimo encontrado'));
      }
      
      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        return const Left(NetworkFailure(message: 'Conexão necessária para vincular conta.'));
      }
      
      final userModel = await _remoteDataSource.linkAnonymousWithEmail(
        anonymousUserId: cachedUser.id,
        name: name,
        email: email,
        password: password,
      );
      
      await _cacheUserLocally(userModel);
      
      debugPrint('AuthRepositoryImpl: Conta vinculada com sucesso - ${userModel.id}');
      return Right(userModel.toEntity());
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro ao vincular conta - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro ao vincular conta: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      debugPrint('AuthRepositoryImpl: Iniciando logout');
      await _clearLocalUserData();
      final hasConnection = await _hasNetworkConnection();
      
      if (hasConnection) {
        try {
          await _remoteDataSource.logout();
          debugPrint('AuthRepositoryImpl: Logout remoto bem-sucedido');
        } catch (e) {
          debugPrint('AuthRepositoryImpl: Falha no logout remoto (ignorada): $e');
        }
      }
      
      debugPrint('AuthRepositoryImpl: Logout concluído');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro no logout - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro no logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      debugPrint('AuthRepositoryImpl: Obtendo usuário atual');
      final cachedUser = await _localDataSource.getLastUser();
      
      if (cachedUser != null) {
        debugPrint('AuthRepositoryImpl: Usuário encontrado no cache - ${cachedUser.id}');
        return Right(cachedUser.toEntity());
      } else {
        debugPrint('AuthRepositoryImpl: Nenhum usuário no cache');
        return const Right(null);
      }
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro ao obter usuário atual - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(CacheFailure(message: 'Falha ao obter usuário do cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshUser({
    required String userId,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Atualizando dados do usuário $userId');
      final cachedUser = await _localDataSource.getLastUser();
      
      if (cachedUser == null) {
        return const Left(ValidationFailure(message: 'Nenhum usuário logado para atualizar'));
      }
      
      if (cachedUser.id != userId) {
        return const Left(ValidationFailure(message: 'ID do usuário não corresponde ao logado'));
      }
      final hasConnection = await _hasNetworkConnection();
      
      if (hasConnection) {
        try {
          final remoteUser = await _remoteDataSource.getCurrentUser();
          
          if (remoteUser != null) {
            await _cacheUserLocally(remoteUser);
            debugPrint('AuthRepositoryImpl: Dados atualizados do servidor');
            return Right(remoteUser.toEntity());
          }
        } catch (e) {
          debugPrint('AuthRepositoryImpl: Falha na atualização remota - $e');
        }
      }
      debugPrint('AuthRepositoryImpl: Retornando dados do cache');
      return Right(cachedUser.toEntity());
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na atualização - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na atualização: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final cachedUser = await _localDataSource.getLastUser();
      return cachedUser != null && cachedUser.isEmailVerified;
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Erro ao verificar login - $e');
      return false;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Atualizando perfil do usuário $userId');
      
      final cachedUser = await _localDataSource.getLastUser();
      
      if (cachedUser == null || cachedUser.id != userId) {
        return const Left(ValidationFailure(message: 'Usuário não encontrado'));
      }
      final updatedUser = cachedUser.copyWith(
        displayName: name ?? cachedUser.displayName,
        photoUrl: profileImageUrl ?? cachedUser.photoUrl,
      );
      await _cacheUserLocally(updatedUser);
      final hasConnection = await _hasNetworkConnection();
      
      if (hasConnection) {
        try {
          final remoteUpdated = await _remoteDataSource.updateProfile(
            userId: userId,
            name: name,
            phone: phone,
            profileImageUrl: profileImageUrl,
          );
          
          if (remoteUpdated != null) {
            await _cacheUserLocally(remoteUpdated);
            debugPrint('AuthRepositoryImpl: Perfil atualizado remotamente');
            return Right(remoteUpdated.toEntity());
          }
        } catch (e) {
          debugPrint('AuthRepositoryImpl: Falha na atualização remota do perfil - $e');
        }
      }
      
      debugPrint('AuthRepositoryImpl: Perfil atualizado localmente');
      return Right(updatedUser.toEntity());
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na atualização do perfil - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na atualização do perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Alterando senha');
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para alterar senha.',
        ));
      }
      
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      debugPrint('AuthRepositoryImpl: Senha alterada com sucesso');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na alteração de senha - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na alteração de senha: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Solicitando redefinição de senha para $email');
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para recuperação de senha.',
        ));
      }
      
      await _remoteDataSource.forgotPassword(email: email);
      
      debugPrint('AuthRepositoryImpl: Email de recuperação enviado');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na recuperação de senha - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na recuperação de senha: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Redefinindo senha com token');
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para redefinir senha.',
        ));
      }
      
      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      
      debugPrint('AuthRepositoryImpl: Senha redefinida com sucesso');
      return const Right(null);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na redefinição de senha - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na redefinição de senha: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailTaken({
    required String email,
  }) async {
    try {
      debugPrint('AuthRepositoryImpl: Verificando se email $email está em uso');
      
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para verificação de email.',
        ));
      }
      
      final isEmailTaken = await _remoteDataSource.isEmailTaken(email: email);
      
      debugPrint('AuthRepositoryImpl: Email em uso: $isEmailTaken');
      return Right(isEmailTaken);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na verificação de email - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na verificação de email: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    try {
      final token = await _localDataSource.getAccessToken();
      return Right(token);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro ao obter token - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(CacheFailure(message: 'Erro ao obter token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshAccessToken() async {
    try {
      debugPrint('AuthRepositoryImpl: Renovando token de acesso');
      
      final hasConnection = await _hasNetworkConnection();
      
      if (!hasConnection) {
        return const Left(NetworkFailure(
          message: 'Conexão com a internet necessária para renovar token.',
        ));
      }
      
      final newToken = await _remoteDataSource.refreshToken();
      await _localDataSource.saveAccessToken(newToken);
      
      debugPrint('AuthRepositoryImpl: Token renovado');
      return Right(newToken);
    } catch (e, stackTrace) {
      debugPrint('AuthRepositoryImpl: Erro na renovação de token - $e');
      debugPrint('StackTrace: $stackTrace');
      return Left(UnknownFailure(message: 'Erro na renovação de token: ${e.toString()}'));
    }
  }

  /// Verifica se há conexão de rede
  Future<bool> _hasNetworkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi) ||
             connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Erro na verificação de conectividade - $e');
      return false;
    }
  }

  /// Executa login remoto
  Future<Either<Failure, UserModel>> _loginRemote(String email, String password) async {
    try {
      final userModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Executa registro remoto
  Future<Either<Failure, UserModel>> _registerRemote(
    String name,
    String email,
    String password,
    String? phone,
  ) async {
    try {
      final userModel = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      return Right(userModel);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Salva usuário no cache local
  Future<void> _cacheUserLocally(UserModel user) async {
    try {
      await _localDataSource.cacheUser(user);
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Erro ao salvar no cache - $e');
      rethrow;
    }
  }

  /// Limpa dados locais do usuário
  Future<void> _clearLocalUserData() async {
    try {
      await _localDataSource.clearUser();
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Erro ao limpar cache - $e');
      rethrow;
    }
  }

  /// Mapeia exceções para failures específicas
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is ServerFailure) {
      return exception;
    } else if (exception is NetworkFailure) {
      return exception;
    } else if (exception is ValidationFailure) {
      return exception;
    } else if (exception.toString().toLowerCase().contains('unauthorized')) {
      return const InvalidCredentialsFailure();
    } else if (exception.toString().toLowerCase().contains('email already')) {
      return const EmailAlreadyInUseFailure();
    } else if (exception.toString().toLowerCase().contains('user not found')) {
      return const UserNotFoundFailure();
    } else if (exception.toString().toLowerCase().contains('token expired')) {
      return const TokenExpiredFailure();
    } else if (exception.toString().toLowerCase().contains('weak password')) {
      return const WeakPasswordFailure();
    } else {
      return UnknownFailure(message: 'Erro inesperado: ${exception.toString()}');
    }
  }
}
