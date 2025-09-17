import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/result.dart';

/// Interface base para todos os use cases
/// Define o padrão de implementação com parâmetros opcionais
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Interface base para use cases usando Result pattern
abstract class ResultUseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Use case sem parâmetros
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Use case sem parâmetros usando Result pattern
abstract class NoParamsResultUseCase<Type> {
  Future<Result<Type>> call();
}

/// Classe para use cases que não precisam de parâmetros
class NoParams {
  const NoParams();
}