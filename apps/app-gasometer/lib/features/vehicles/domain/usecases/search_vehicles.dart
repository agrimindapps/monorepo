import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class SearchVehicles implements UseCase<List<VehicleEntity>, SearchVehiclesParams> {
  final VehicleRepository repository;

  SearchVehicles(this.repository);

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(SearchVehiclesParams params) async {
    return await repository.searchVehicles(params.query);
  }
}

class SearchVehiclesParams extends UseCaseParams {
  final String query;

  const SearchVehiclesParams({required this.query});

  @override
  List<Object> get props => [query];
}