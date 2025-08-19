import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

// General failures
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

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message);
}

// Vehicle specific failures
class VehicleNotFoundFailure extends Failure {
  const VehicleNotFoundFailure(super.message);
}

class DuplicateVehicleFailure extends Failure {
  const DuplicateVehicleFailure(super.message);
}

// Fuel specific failures
class InvalidFuelDataFailure extends Failure {
  const InvalidFuelDataFailure(super.message);
}

// Maintenance specific failures
class MaintenanceNotFoundFailure extends Failure {
  const MaintenanceNotFoundFailure(super.message);
}

// Sync failures
class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class OfflineFailure extends Failure {
  const OfflineFailure(super.message);
}