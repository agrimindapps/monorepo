import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Use case for password reset
class ResetPasswordUseCase {
  final IAuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    // Validate email
    final trimmedEmail = params.email.trim();
    if (trimmedEmail.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    if (!_isValidEmail(trimmedEmail)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    // Delegate to repository
    return await _authRepository.sendPasswordResetEmail(
      email: trimmedEmail,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Parameters for ResetPasswordUseCase
class ResetPasswordParams extends Equatable {
  final String email;

  const ResetPasswordParams({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}
