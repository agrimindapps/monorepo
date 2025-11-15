import '../utils/typedef.dart';

abstract class UseCaseWithParams<T, Params> {
  const UseCaseWithParams();
  
  ResultFuture<T> call(Params params);
}

abstract class UseCaseWithoutParams<T> {
  const UseCaseWithoutParams();
  
  ResultFuture<T> call();
}

abstract class StreamUseCase<T, Params> {
  const StreamUseCase();
  
  Stream<T> call(Params params);
}

abstract class StreamUseCaseWithoutParams<T> {
  const StreamUseCaseWithoutParams();
  
  Stream<T> call();
}

/// No parameters class for use cases that don't require parameters
class NoParams {
  const NoParams();
}
