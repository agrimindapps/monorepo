import 'package:core/core.dart';

import '../repositories/livestock_repository.dart';

/// Use case para publicar catálogo de livestock no Firebase Storage
/// 
/// Este use case é executado apenas por admins e realiza:
/// 1. Lê todos bovinos/equinos do cache local (Drift)
/// 2. Gera JSONs dos catálogos
/// 3. Faz upload para Firebase Storage
/// 4. Atualiza metadata com timestamp
class PublishLivestockCatalogUseCase implements UseCase<Unit, NoParams> {
  final LivestockRepository _repository;
  
  const PublishLivestockCatalogUseCase(this._repository);
  
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    try {
      // 1. Busca todos os bovinos e equinos do cache local
      final bovinesResult = await _repository.getBovines();
      final equinesResult = await _repository.getEquines();
      
      // Verifica erros
      if (bovinesResult.isLeft()) {
        return Left(
          CacheFailure('Erro ao buscar bovinos: ${bovinesResult.fold((f) => f.message, (_) => '')}')
        );
      }
      
      if (equinesResult.isLeft()) {
        return Left(
          CacheFailure('Erro ao buscar equinos: ${equinesResult.fold((f) => f.message, (_) => '')}')
        );
      }
      
      final bovines = bovinesResult.getOrElse(() => []);
      final equines = equinesResult.getOrElse(() => []);
      
      // Valida que há dados para publicar
      if (bovines.isEmpty && equines.isEmpty) {
        return Left(
          ValidationFailure('Não há dados para publicar. Adicione bovinos ou equinos primeiro.')
        );
      }
      
      // 2. Publica catálogo (repository fará upload no Storage)
      final publishResult = await _repository.publishCatalogToStorage(
        bovines: bovines,
        equines: equines,
      );
      
      return publishResult;
      
    } catch (e) {
      return Left(ServerFailure('Erro ao publicar catálogo: $e'));
    }
  }
}
