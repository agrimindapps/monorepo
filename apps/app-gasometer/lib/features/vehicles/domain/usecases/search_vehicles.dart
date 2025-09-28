import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';

@lazySingleton
class SearchVehicles implements UseCase<List<VehicleEntity>, SearchVehiclesParams> {

  SearchVehicles(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(SearchVehiclesParams params) async {
    return await repository.searchVehicles(params.query);
  }
}

class SearchVehiclesParams extends UseCaseParams {

  const SearchVehiclesParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}