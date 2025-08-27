import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

/// Interface base para todos os use cases
/// Segue padrão Clean Architecture
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case sem parâmetros
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}