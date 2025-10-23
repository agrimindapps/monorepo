/// Error handling module for app-gasometer
///
/// Exports:
/// - Failures hierarchy (core + gasometer-specific)
/// - ExceptionMapper for exception to failure conversion
/// - Extensions for convenient error handling
///
/// Usage:
/// ```dart
/// import 'package:gasometer/core/errors/errors.dart';
///
/// try {
///   // operation
/// } on FirebaseException catch (e, stackTrace) {
///   return Left(ExceptionMapper.mapException(e, stackTrace));
/// }
/// ```

export 'failures.dart';
export 'exception_mapper.dart';
