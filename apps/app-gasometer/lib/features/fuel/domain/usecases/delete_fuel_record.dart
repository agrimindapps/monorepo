import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
class DeleteFuelRecord implements UseCase<Unit, DeleteFuelRecordParams> {
  final FuelRepository repository;

  DeleteFuelRecord(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteFuelRecordParams params) async {
    if (params.id.isEmpty) {
      return const Left(InvalidFuelDataFailure('ID do registro é obrigatório'));
    }

    return await repository.deleteFuelRecord(params.id);
  }
}

class DeleteFuelRecordParams extends UseCaseParams {
  final String id;

  const DeleteFuelRecordParams({required this.id});

  @override
  List<Object> get props => [id];
}