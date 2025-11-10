import 'package:core/core.dart' hide Column;

/// Type definitions for common return types
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = Future<Either<Failure, void>>;
