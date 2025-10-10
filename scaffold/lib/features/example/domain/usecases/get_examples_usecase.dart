import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Use case for getting all examples
/// No parameters needed, simply fetches all examples
@injectable
class GetExamplesUseCase implements UseCase<List<ExampleEntity>, NoParams> {
  const GetExamplesUseCase(this._repository);

  final ExampleRepository _repository;

  @override
  Future<Either<Failure, List<ExampleEntity>>> call(NoParams params) async {
    return _repository.getExamples();
  }
}
