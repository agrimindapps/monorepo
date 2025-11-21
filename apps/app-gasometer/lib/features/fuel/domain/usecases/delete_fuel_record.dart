import 'package:core/core.dart';
import '../repositories/fuel_repository.dart';


class DeleteFuelRecord implements UseCase<Unit, DeleteFuelRecordParams> {

  DeleteFuelRecord(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteFuelRecordParams params) async {
    if (params.id.isEmpty) {
      return const Left(ValidationFailure('ID do registro é obrigatório'));
    }

    return repository.deleteFuelRecord(params.id);
  }
}

class DeleteFuelRecordParams with EquatableMixin {

  const DeleteFuelRecordParams({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}
