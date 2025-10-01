import 'package:equatable/equatable.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'auth_repository.dart';
import 'user_entity.dart';

class SignIn extends UseCaseWithParams<UserEntity, SignInParams> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity> call(SignInParams params) async {
    return _repository.signInWithEmailPassword(
      params.email,
      params.password,
    );
  }
}

class SignInParams extends Equatable {
  const SignInParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}