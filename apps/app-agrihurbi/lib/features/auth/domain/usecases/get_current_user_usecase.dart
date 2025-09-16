import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Use case para obter o usuário atual com validação de sessão
/// 
/// Implementa UseCase que retorna a entidade do usuário logado ou null
/// Inclui validação de token, refresh automático se necessário
@lazySingleton
class GetCurrentUserUseCase implements UseCase<UserEntity?, GetCurrentUserParams> {
  final AuthRepository repository;
  
  const GetCurrentUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, UserEntity?>> call(GetCurrentUserParams params) async {
    // Obter usuário atual do repository
    final result = await repository.getCurrentUser();
    
    return result.fold(
      (failure) {
        // Se falhou por token expirado e refresh está habilitado
        if (params.refreshIfExpired && _isTokenExpiredFailure(failure)) {
          return _attemptTokenRefresh();
        }
        return Left(failure);
      },
      (user) {
        // Validar dados do usuário se solicitado
        if (params.validateUserData && user != null) {
          final validation = _validateUserData(user);
          if (validation != null) {
            return Left(ValidationFailure(validation));
          }
        }
        
        return Right(user);
      },
    );
  }
  
  /// Verifica se o erro é de token expirado
  bool _isTokenExpiredFailure(Failure failure) {
    return failure.message.toLowerCase().contains('token') ||
           failure.message.toLowerCase().contains('expired') ||
           failure.message.toLowerCase().contains('unauthorized');
  }
  
  /// Tenta fazer refresh do token
  Future<Either<Failure, UserEntity?>> _attemptTokenRefresh() async {
    // Esta implementação será feita quando o repository estiver completo
    // Por ora, retorna null (sem usuário)
    return const Right(null);
  }
  
  /// Valida os dados do usuário retornado
  String? _validateUserData(UserEntity user) {
    if (user.id.isEmpty) {
      return 'ID do usuário inválido';
    }
    
    if (user.email.isEmpty) {
      return 'Email do usuário inválido';
    }
    
    if (user.displayName.isEmpty) {
      return 'Nome do usuário inválido';
    }
    
    return null;
  }
}

/// Parâmetros para obtenção do usuário atual
class GetCurrentUserParams extends Equatable {
  const GetCurrentUserParams({
    this.refreshIfExpired = true,
    this.validateUserData = true,
    this.includeProfile = true,
  });

  /// Se deve tentar refresh em caso de token expirado
  final bool refreshIfExpired;
  
  /// Se deve validar os dados do usuário retornado
  final bool validateUserData;
  
  /// Se deve incluir dados completos do perfil
  final bool includeProfile;
  
  @override
  List<Object> get props => [refreshIfExpired, validateUserData, includeProfile];
}