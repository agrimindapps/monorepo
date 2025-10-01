import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base UseCase interface for all use cases in the application
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// UseCase for operations that don't require parameters
class NoParams {
  const NoParams();
}
