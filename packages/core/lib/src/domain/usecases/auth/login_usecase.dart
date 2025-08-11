import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../base_usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_analytics_repository.dart';
import '../../../shared/utils/failure.dart';

/// Use case para fazer login com email e senha
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;

  LoginUseCase(this._authRepository, this._analyticsRepository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // Validações básicas
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Fazer login
    final loginResult = await _authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    // Log analytics em caso de sucesso
    return loginResult.fold(
      (failure) => Left(failure),
      (user) async {
        // Registrar evento de login
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

/// Parâmetros para o LoginUseCase
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}