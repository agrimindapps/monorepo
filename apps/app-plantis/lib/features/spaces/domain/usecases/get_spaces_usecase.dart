import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/space.dart';
import '../repositories/spaces_repository.dart';

class GetSpacesUseCase implements UseCase<List<Space>, NoParams> {
  final SpacesRepository repository;
  
  GetSpacesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<Space>>> call(NoParams params) async {
    return repository.getSpaces();
  }
}

class GetSpaceByIdUseCase implements UseCase<Space, String> {
  final SpacesRepository repository;
  
  GetSpaceByIdUseCase(this.repository);
  
  @override
  Future<Either<Failure, Space>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do espaço é obrigatório'));
    }
    return repository.getSpaceById(id);
  }
}

class SearchSpacesUseCase implements UseCase<List<Space>, String> {
  final SpacesRepository repository;
  
  SearchSpacesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<Space>>> call(String query) async {
    if (query.trim().isEmpty) {
      return repository.getSpaces();
    }
    return repository.searchSpaces(query.trim());
  }
}