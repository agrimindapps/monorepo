import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/defensivo_entity.dart';
import '../repositories/defensivo_repository.dart';

/// Caso de uso para buscar detalhes de um defensivo
/// 
/// Este use case encapsula a lógica de negócio para buscar
/// um defensivo específico, seguindo Clean Architecture
class GetDefensivoDetailsUseCase implements UseCase<DefensivoEntity, GetDefensivoDetailsParams> {
  const GetDefensivoDetailsUseCase(this._repository);

  final DefensivoRepository _repository;

  @override
  ResultFuture<DefensivoEntity> call(GetDefensivoDetailsParams params) async {
    // Primeiro tenta buscar por ID de registro
    if (params.idReg != null) {
      final result = await _repository.getDefensivoById(params.idReg!);
      return result.fold(
        (failure) {
          // Se falhou por ID, tenta por nome como fallback
          if (params.nome != null) {
            return _repository.getDefensivoByName(params.nome!);
          }
          return Left(failure);
        },
        (defensivo) => Right(defensivo),
      );
    }
    
    // Se não tem ID, busca por nome
    if (params.nome != null) {
      return _repository.getDefensivoByName(params.nome!);
    }
    
    // Se não tem nem ID nem nome, retorna erro
    return const Left(
      ServerFailure('ID de registro ou nome do defensivo é obrigatório'),
    );
  }
}

/// Parâmetros para buscar detalhes de um defensivo
class GetDefensivoDetailsParams {
  final String? idReg;
  final String? nome;

  const GetDefensivoDetailsParams({
    this.idReg,
    this.nome,
  });

  /// Valida se os parâmetros são válidos
  bool get isValid => idReg != null || nome != null;
}