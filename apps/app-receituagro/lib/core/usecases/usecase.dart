import 'package:core/core.dart' hide Column;

/// Interface base para todos os use cases
/// Segue padrão Clean Architecture
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case sem parâmetros
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}
