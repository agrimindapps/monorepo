import 'package:core/core.dart' show Equatable;

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message);
}
class VehicleNotFoundFailure extends Failure {
  const VehicleNotFoundFailure(super.message);
}

class DuplicateVehicleFailure extends Failure {
  const DuplicateVehicleFailure(super.message);
}
class InvalidFuelDataFailure extends Failure {
  const InvalidFuelDataFailure(super.message);
}
class MaintenanceNotFoundFailure extends Failure {
  const MaintenanceNotFoundFailure(super.message);
}
class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure(super.message);
}
