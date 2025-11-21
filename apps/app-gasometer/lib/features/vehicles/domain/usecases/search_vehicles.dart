import 'package:core/core.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/vehicle_repository.dart';


class SearchVehicles implements UseCase<List<VehicleEntity>, SearchVehiclesParams> {

  SearchVehicles(this.repository);
  final VehicleRepository repository;

  @override
  Future<Either<Failure, List<VehicleEntity>>> call(SearchVehiclesParams params) async {
    return repository.searchVehicles(params.query);
  }
}

class SearchVehiclesParams with EquatableMixin {

  const SearchVehiclesParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}
