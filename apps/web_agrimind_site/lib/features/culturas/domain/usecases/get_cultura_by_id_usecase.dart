import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/cultura_entity.dart';
import '../repositories/culturas_repository.dart';

/// Use case to get a cultura by id
///
/// Retrieves a specific cultura by its id
class GetCulturaByIdUseCase
    implements UseCase<CulturaEntity, GetCulturaByIdParams> {
  final ICulturasRepository _repository;

  const GetCulturaByIdUseCase(this._repository);

  @override
  Future<Either<Failure, CulturaEntity>> call(
    GetCulturaByIdParams params,
  ) async {
    // Validate params
    if (params.id.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da cultura não pode ser vazio'),
      );
    }

    return await _repository.getCulturaById(params.id);
  }
}

/// Parameters for GetCulturaByIdUseCase
class GetCulturaByIdParams extends Equatable {
  final String id;

  const GetCulturaByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}
