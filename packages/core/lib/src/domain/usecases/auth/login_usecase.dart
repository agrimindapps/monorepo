import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/utils/failure.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_analytics_repository.dart';
import '../../repositories/i_auth_repository.dart';
import '../base_usecase.dart';

/// A use case for logging in a user with an email and password.
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;

  /// Creates a new instance of [LoginUseCase].
  ///
  /// [_authRepository] The repository for handling authentication tasks.
  /// [_analyticsRepository] The repository for logging analytics events.
  LoginUseCase(this._authRepository, this._analyticsRepository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    final loginResult = await _authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
    return loginResult.fold(
      (failure) => Left(failure),
      (user) async {
        await _analyticsRepository.logLogin(method: 'email');
        
        return Right(user);
      },
    );
  }

  /// Valida os parâmetros de entrada
  ValidationFailure? _validateParams(LoginParams params) {
    if (params.email.trim().isEmpty) {
      return const ValidationFailure('Email é obrigatório');
    }

    if (!_isValidEmail(params.email)) {
      return const ValidationFailure('Email inválido');
    }

    if (params.password.trim().isEmpty) {
      return const ValidationFailure('Senha é obrigatória');
    }

    if (params.password.length < 6) {
      return const ValidationFailure('Senha deve ter pelo menos 6 caracteres');
    }

    return null;
  }

  /// Valida formato do email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}

/// Parameters for the [LoginUseCase].
class LoginParams extends Equatable {
  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Creates a new instance of [LoginParams].
  ///
  /// [email] The user's email address.
  /// [password] The user's password.
  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
