import 'package:core/core.dart';

/// Failures específicos do domínio Livestock
class LivestockFailure extends Failure {
  const LivestockFailure({required super.message});
}

class BovineNotFoundFailure extends LivestockFailure {
  const BovineNotFoundFailure() : super(message: 'Bovino não encontrado');
}

class EquineNotFoundFailure extends LivestockFailure {
  const EquineNotFoundFailure() : super(message: 'Equino não encontrado');
}

class CacheFailure extends LivestockFailure {
  const CacheFailure(String message) : super(message: message);
}

class ServerFailure extends LivestockFailure {
  const ServerFailure(String message) : super(message: message);
}

class NetworkFailure extends LivestockFailure {
  const NetworkFailure(String message) : super(message: message);
}