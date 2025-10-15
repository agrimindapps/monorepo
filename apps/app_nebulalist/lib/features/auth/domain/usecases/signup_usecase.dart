import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Use case for user registration with email and password
class SignUpUseCase {
  final IAuthRepository _authRepository;
  final IAnalyticsRepository _analyticsRepository;

  SignUpUseCase(this._authRepository, this._analyticsRepository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    // Validate display name
    final trimmedName = params.displayName.trim();
    if (trimmedName.isEmpty) {
      return const Left(ValidationFailure('Nome é obrigatório'));
    }

    if (trimmedName.length < 2) {
      return const Left(
        ValidationFailure('Nome deve ter pelo menos 2 caracteres'),
      );
    }

    // Validate email
    final trimmedEmail = params.email.trim();
    if (trimmedEmail.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (!_isValidEmail(trimmedEmail)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    // Validate password
    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Senha é obrigatória'));
    }

    if (params.password.length < 6) {
      return const Left(
        ValidationFailure('Senha deve ter pelo menos 6 caracteres'),
      );
    }

    // Delegate to repository
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: trimmedEmail,
      password: params.password,
      displayName: trimmedName,
    );

    return result.fold(
      (failure) => Left(failure),
      (user) async {
        await _analyticsRepository.logSignUp(method: 'email');
        return Right(user);
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Parameters for SignUpUseCase
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}
