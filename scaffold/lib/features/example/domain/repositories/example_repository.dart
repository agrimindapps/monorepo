import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';

/// Repository interface for Example feature
/// Defines the contract for example data operations
/// Implementation will be in the data layer
abstract class ExampleRepository {
  /// Get all examples
  Future<Either<Failure, List<ExampleEntity>>> getExamples();

  /// Get example by ID
  Future<Either<Failure, ExampleEntity>> getExampleById(String id);

  /// Add new example
  Future<Either<Failure, ExampleEntity>> addExample(ExampleEntity example);

  /// Update existing example
  Future<Either<Failure, ExampleEntity>> updateExample(ExampleEntity example);

  /// Delete example
  Future<Either<Failure, void>> deleteExample(String id);
}
