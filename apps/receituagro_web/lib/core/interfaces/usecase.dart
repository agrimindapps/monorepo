import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Base interface for all use cases
///
/// [Type] - The return type on success
/// [Params] - The parameters passed to the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when the use case doesn't need parameters
class NoParams {
  const NoParams();
}
