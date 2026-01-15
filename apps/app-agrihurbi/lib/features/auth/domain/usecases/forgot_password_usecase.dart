import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:core/core.dart' hide Failure, ValidationFailure;

import '../repositories/auth_repository.dart';

/// Use case para solicitar recuperação de senha
///
/// Envia email de recuperação para o endereço fornecido
class ForgotPasswordUseCase implements UseCase<void, ForgotPasswordParams> {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    // Validação do email
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(message: 'Email inválido'));
    }

    return _repository.forgotPassword(email: params.email.trim().toLowerCase());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Parâmetros para recuperação de senha
class ForgotPasswordParams {
  final String email;

  const ForgotPasswordParams({required this.email});
}
