import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class SearchVaccines implements UseCase<List<Vaccine>, SearchVaccinesParams> {
  final VaccineRepository repository;

  SearchVaccines(this.repository);

  @override
  Future<Either<Failure, List<Vaccine>>> call(SearchVaccinesParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Termo de busca é obrigatório'));
    }

    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    return await repository.searchVaccines(params.query, params.animalId);
  }
}

class SearchVaccinesParams {
  final String query;
  final String? animalId;
  
  const SearchVaccinesParams({
    required this.query,
    this.animalId,
  });
  
  // Factory constructors for convenience
  factory SearchVaccinesParams.global(String query) => SearchVaccinesParams(query: query);
  factory SearchVaccinesParams.byAnimal(String query, String animalId) => 
    SearchVaccinesParams(query: query, animalId: animalId);
}