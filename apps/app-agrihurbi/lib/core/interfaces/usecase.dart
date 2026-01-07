import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base UseCase interface for all use cases in the application
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// UseCase for operations that don't require parameters
class NoParams {
  const NoParams();
}
