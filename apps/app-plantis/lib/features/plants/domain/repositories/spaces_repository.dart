import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/space.dart';

abstract class SpacesRepository {
  /// Obtém todos os espaços do usuário
  Future<Either<Failure, List<Space>>> getSpaces();

  /// Obtém um espaço específico por ID
  Future<Either<Failure, Space>> getSpaceById(String id);

  /// Adiciona um novo espaço
  Future<Either<Failure, Space>> addSpace(Space space);

  /// Atualiza um espaço existente
  Future<Either<Failure, Space>> updateSpace(Space space);

  /// Remove um espaço
  Future<Either<Failure, void>> deleteSpace(String id);

  /// Busca espaços por nome
  Future<Either<Failure, List<Space>>> searchSpaces(String query);

  /// Verifica se um espaço pode ser removido (não tem plantas)
  Future<Either<Failure, bool>> canDeleteSpace(String spaceId);

  /// Stream para observar mudanças nos espaços
  Stream<List<Space>> watchSpaces();

  /// Sincroniza mudanças pendentes com o servidor
  Future<Either<Failure, void>> syncPendingChanges();
}
