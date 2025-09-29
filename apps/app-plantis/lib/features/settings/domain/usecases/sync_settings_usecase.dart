import 'package:core/core.dart';

import '../repositories/i_settings_repository.dart';

/// UseCase para sincronizar configurações do usuário
/// Responsável por carregar as configurações mais recentes do servidor/local
class SyncSettingsUseCase {
  final ISettingsRepository _repository;

  SyncSettingsUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    try {
      // Carrega as configurações (o repository já gerencia cache/remote)
      final result = await _repository.loadSettings();

      return result.fold(
        (failure) => Left(failure),
        (settings) {
          // Configurações carregadas com sucesso
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao sincronizar configurações: ${e.toString()}'),
      );
    }
  }
}

/// UseCase para sincronizar dados do perfil do usuário
class SyncUserProfileUseCase {
  final IAuthRepository _authRepository;

  SyncUserProfileUseCase(this._authRepository);

  Future<Either<Failure, UserEntity?>> call() async {
    try {
      // Aguarda o usuário atual (com timeout para evitar travamento)
      final user = await _authRepository.currentUser
          .timeout(const Duration(seconds: 5))
          .first;

      if (user == null) {
        return const Right(null);
      }

      // Usuário carregado com sucesso
      return Right(user);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao sincronizar perfil do usuário: ${e.toString()}'),
      );
    }
  }
}