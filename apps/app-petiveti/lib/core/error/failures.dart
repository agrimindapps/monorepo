import 'package:core/core.dart' show Equatable;

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({required this.message, this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];
}
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.details});
}
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code, super.details});
}
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.details});
}
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code, super.details});
}
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.details});
}
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code, super.details});
}
