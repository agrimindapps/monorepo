import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@injectable
class SearchFuelRecords implements UseCase<List<FuelRecordEntity>, SearchFuelRecordsParams> {

  SearchFuelRecords(this.repository);
  final FuelRepository repository;

  @override
  Future<Either<Failure, List<FuelRecordEntity>>> call(SearchFuelRecordsParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure('Termo de busca não pode estar vazio'));
    }

    if (params.query.trim().length < 2) {
      return const Left(ValidationFailure('Termo de busca deve ter pelo menos 2 caracteres'));
    }

    return repository.searchFuelRecords(params.query.trim());
  }
}

class SearchFuelRecordsParams with EquatableMixin {

  const SearchFuelRecordsParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}
