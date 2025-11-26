import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/defensivo_entity.dart';
import '../repositories/defensivos_repository.dart';

/// Use case to get a defensivo by id
///
/// Retrieves a specific defensivo by its id
class GetDefensivoByIdUseCase
    implements UseCase<DefensivoEntity, GetDefensivoByIdParams> {
  final IDefensivosRepository _repository;

  const GetDefensivoByIdUseCase(this._repository);

  @override
  Future<Either<Failure, DefensivoEntity>> call(
    GetDefensivoByIdParams params,
  ) async {
    // Validate params
    if (params.id.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do defensivo não pode ser vazio'),
      );
    }

    return await _repository.getDefensivoById(params.id);
  }
}

/// Parameters for GetDefensivoByIdUseCase
class GetDefensivoByIdParams extends Equatable {
  final String id;

  const GetDefensivoByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}
