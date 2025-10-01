import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List<dynamic> properties = const <dynamic>[]]);

  String get message;

  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  final String _message;
  
  const ServerFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class CacheFailure extends Failure {
  final String _message;
  
  const CacheFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class NetworkFailure extends Failure {
  final String _message;
  
  const NetworkFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class ValidationFailure extends Failure {
  final String _message;
  
  const ValidationFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class AuthenticationFailure extends Failure {
  final String _message;
  
  const AuthenticationFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class PermissionFailure extends Failure {
  final String _message;
  
  const PermissionFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class UnexpectedFailure extends Failure {
  final String _message;
  
  const UnexpectedFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}

class AuthFailure extends Failure {
  final String _message;
  
  const AuthFailure(this._message);
  
  @override
  String get message => _message;
  
  @override
  List<Object> get props => [_message];
}