import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fuel_record_entity.dart';
import '../repositories/fuel_repository.dart';

@lazySingleton
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

    return await repository.searchFuelRecords(params.query.trim());
  }
}

class SearchFuelRecordsParams extends UseCaseParams {

  const SearchFuelRecordsParams({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}