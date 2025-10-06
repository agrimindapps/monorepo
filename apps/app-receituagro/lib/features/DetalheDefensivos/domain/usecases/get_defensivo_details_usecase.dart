import 'package:core/core.dart';
import '../../../../core/errors/failures.dart' as app_failures;
import '../../../../core/usecases/usecase.dart' as app_usecase;
import '../../../../core/utils/typedef.dart';
import '../entities/defensivo_entity.dart';
import '../repositories/defensivo_repository.dart';

/// Caso de uso para buscar detalhes de um defensivo
/// 
/// Este use case encapsula a lógica de negócio para buscar
/// um defensivo específico, seguindo Clean Architecture
class GetDefensivoDetailsUseCase implements app_usecase.UseCase<DefensivoEntity, GetDefensivoDetailsParams> {
  const GetDefensivoDetailsUseCase(this._repository);

  final DefensivoRepository _repository;

  @override
  ResultFuture<DefensivoEntity> call(GetDefensivoDetailsParams params) async {
    if (params.idReg != null) {
      final result = await _repository.getDefensivoById(params.idReg!);
      if (result.isRight()) {
        return result;
      }
      if (params.nome != null) {
        return await _repository.getDefensivoByName(params.nome!);
      }
      return result;
    }
    if (params.nome != null) {
      return await _repository.getDefensivoByName(params.nome!);
    }
    return const Left(
      app_failures.ServerFailure('ID de registro ou nome do defensivo é obrigatório'),
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
