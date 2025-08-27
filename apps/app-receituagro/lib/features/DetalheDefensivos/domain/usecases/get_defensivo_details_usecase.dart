import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import '../entities/defensivo_details_entity.dart';
import '../repositories/i_defensivo_details_repository.dart';

class GetDefensivoDetailsParams {
  final String defensivoName;

  const GetDefensivoDetailsParams({required this.defensivoName});
}

/// Use case para buscar detalhes de um defensivo
/// Implementa padrão de single responsibility
class GetDefensivoDetailsUsecase implements UseCase<DefensivoDetailsEntity?, GetDefensivoDetailsParams> {
  final IDefensivoDetailsRepository repository;

  const GetDefensivoDetailsUsecase({required this.repository});

  @override
  Future<Either<Failure, DefensivoDetailsEntity?>> call(GetDefensivoDetailsParams params) async {
    return await repository.getDefensivoByName(params.defensivoName);
  }
}