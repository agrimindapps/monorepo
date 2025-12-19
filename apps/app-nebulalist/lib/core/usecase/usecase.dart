import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Base UseCase interface following Clean Architecture
/// [Type] is the return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Used when no parameters are needed
class NoParams {
  const NoParams();
}
