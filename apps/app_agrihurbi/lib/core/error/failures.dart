import 'package:core/core.dart' as core_lib;

// Re-export failures from core package
typedef Failure = core_lib.Failure;
typedef NetworkFailure = core_lib.NetworkFailure;
typedef ServerFailure = core_lib.ServerFailure;
typedef CacheFailure = core_lib.CacheFailure;
typedef ValidationFailure = core_lib.ValidationFailure;
typedef UnknownFailure = core_lib.UnknownFailure;

// GeneralFailure maps to UnknownFailure
typedef GeneralFailure = core_lib.UnknownFailure;

// Additional app-specific failures
class AppNotFoundFailure extends Failure {
  const AppNotFoundFailure([String message = 'Resource not found']) : super(message: message);
}

class CalculationFailure extends Failure {
  const CalculationFailure([String message = 'Calculation error']) : super(message: message);
}