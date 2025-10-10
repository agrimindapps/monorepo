import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// CRUD operations service for examples
/// Single Responsibility: Only handles CRUD operations
/// This follows the SOLID principle of having focused services
@injectable
class ExampleCrudService {
  const ExampleCrudService(this._repository);

  final ExampleRepository _repository;

  /// Get all examples
  Future<Either<Failure, List<ExampleEntity>>> getAll() async {
    return _repository.getExamples();
  }

  /// Get example by ID
  Future<Either<Failure, ExampleEntity>> getById(String id) async {
    return _repository.getExampleById(id);
  }

  /// Add new example
  Future<Either<Failure, ExampleEntity>> add(ExampleEntity example) async {
    return _repository.addExample(example);
  }

  /// Update existing example
  Future<Either<Failure, ExampleEntity>> update(ExampleEntity example) async {
    return _repository.updateExample(example);
  }

  /// Delete example
  Future<Either<Failure, void>> delete(String id) async {
    return _repository.deleteExample(id);
  }
}
