import 'package:core/core.dart' as core_lib;

/// Re-export Failure from core
typedef Failure = core_lib.Failure;

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network Error',
    super.code,
    super.details,
  });
}

/// Server-related failures  
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server Error',
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache Error',
    super.code,
    super.details,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation Error',
    super.code,
    super.details,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication Error',
    super.code,
    super.details,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission Error',
    super.code,
    super.details,
  });
}

/// Generic failures
class GeneralFailure extends Failure {
  const GeneralFailure({
    super.message = 'General Error',
    super.code,
    super.details,
  });
}

/// Premium feature required failures
class PremiumRequiredFailure extends Failure {
  const PremiumRequiredFailure({
    super.message = 'Premium feature required',
    super.code,
    super.details,
  });
}

/// Calculation-related failures
class CalculationFailure extends Failure {
  const CalculationFailure({
    super.message = 'Calculation Error',
    super.code,
    super.details,
  });
}

/// Data format failures
class DataFormatFailure extends Failure {
  const DataFormatFailure({
    super.message = 'Data Format Error',
    super.code,
    super.details,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Operation Timeout',
    super.code,
    super.details,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource Not Found',
    super.code,
    super.details,
  });
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Unknown Error',
    super.code,
    super.details,
  });
}