import 'package:core/core.dart';
import 'package:core/core.dart';

import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use case para obter defensivos completos para comparação e análise detalhada
/// Aplica princípio de responsabilidade única (SRP)
class GetDefensivosCompletosUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosCompletosUseCase(this._repository);

  /// Executa busca de defensivos com informações completas
  Future<Either<Failure, List<DefensivoEntity>>> call() async {
    return await _repository.getDefensivosCompletos();
  }
}