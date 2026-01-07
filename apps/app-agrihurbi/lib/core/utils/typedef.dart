import 'package:core/core.dart' show Failure;
import 'package:dartz/dartz.dart';

/// Future that returns an Either type
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Void result for operations that don't return data
typedef ResultVoid = Future<Either<Failure, void>>;

/// Map result type
typedef ResultMap = Map<String, dynamic>;

/// Data map type for API responses
typedef DataMap = Map<String, dynamic>;
