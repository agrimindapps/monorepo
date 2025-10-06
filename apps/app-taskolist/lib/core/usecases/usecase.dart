import '../utils/typedef.dart';

abstract class UseCaseWithParams<Type, Params> {
  const UseCaseWithParams();
  
  ResultFuture<Type> call(Params params);
}

abstract class UseCaseWithoutParams<Type> {
  const UseCaseWithoutParams();
  
  ResultFuture<Type> call();
}

abstract class StreamUseCase<Type, Params> {
  const StreamUseCase();
  
  Stream<Type> call(Params params);
}

abstract class StreamUseCaseWithoutParams<Type> {
  const StreamUseCaseWithoutParams();
  
  Stream<Type> call();
}

/// No parameters class for use cases that don't require parameters
class NoParams {
  const NoParams();
}
