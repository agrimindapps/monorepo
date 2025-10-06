import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

/// Use case para refresh dos dados do usuário com validação e sincronização
/// 
/// Implementa UseCase que retorna a entidade atualizada do usuário
/// Inclui sincronização com servidor, atualização de cache local
@lazySingleton
class RefreshUserUseCase implements UseCase<UserEntity, RefreshUserParams> {
  final AuthRepository repository;
  
  const RefreshUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(RefreshUserParams params) async {
    final currentUserResult = await repository.getCurrentUser();
    
    return await currentUserResult.fold(
      (failure) => Left(failure),
      (currentUser) async {
        if (currentUser == null) {
          return const Left(ValidationFailure('Nenhum usuário logado'));
        }
        final refreshResult = await repository.refreshUser(userId: currentUser.id);
        
        return refreshResult.fold(
          (failure) {
            if (params.fallbackToCurrent) {
              return Right(currentUser);
            }
            return Left(failure);
          },
          (refreshedUser) {
            if (params.validateRefreshedData) {
              final validation = _validateRefreshedUserData(refreshedUser, currentUser);
              if (validation != null) {
                return Left(ValidationFailure(validation));
              }
            }
            
            return Right(refreshedUser);
          },
        );
      },
    );
  }
  
  /// Valida os dados do usuário após refresh
  String? _validateRefreshedUserData(UserEntity refreshed, UserEntity original) {
    if (refreshed.id != original.id) {
      return 'Inconsistência de ID após refresh';
    }
    if (refreshed.email != original.email) {
      return 'Email foi alterado inesperadamente';
    }
    if (refreshed.displayName.trim().isEmpty) {
      return 'Nome do usuário vazio após refresh';
    }
    
    return null;
  }
}

/// Parâmetros para refresh dos dados do usuário
class RefreshUserParams extends Equatable {
  const RefreshUserParams({
    this.forceRemoteSync = false,
    this.validateRefreshedData = true,
    this.fallbackToCurrent = true,
    this.updateLastLoginTime = false,
  });

  /// Se deve forçar sincronização com servidor
  final bool forceRemoteSync;
  
  /// Se deve validar os dados após refresh
  final bool validateRefreshedData;
  
  /// Se deve retornar dados atuais em caso de falha
  final bool fallbackToCurrent;
  
  /// Se deve atualizar horário do último login
  final bool updateLastLoginTime;
  
  @override
  List<Object> get props => [
    forceRemoteSync, 
    validateRefreshedData, 
    fallbackToCurrent,
    updateLastLoginTime,
  ];
}