import 'package:core/core.dart' show Failure;
import 'package:dartz/dartz.dart';

/// Result type that can contain either a Failure or a success value
typedef Result<T> = Either<Failure, T>;

/// Future that returns a Result type
typedef ResultFuture<T> = Future<Result<T>>;

/// Void result for operations that don't return data
typedef ResultVoid = Future<Result<void>>;

/// Map result type
typedef ResultMap = Map<String, dynamic>;

/// Data map type for API responses
typedef DataMap = Map<String, dynamic>;