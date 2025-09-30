import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@injectable
class GetAllFuelRecords implements NoParamsUseCase<List<FuelRecordEntity>> {

  GetAllFuelRecords(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call() async {
    return repository.getAllFuelRecords();
  }
}