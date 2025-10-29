import 'package:core/core.dart';

import '../../utils/auth_validators.dart';

/// Use case para solicitar reset de senha via email
///
/// Implementa a lógica de negócio para:
/// - Validação de email
/// - Envio de email de reset
/// - Tratamento de erros específicos
class ResetPasswordUseCase {
  final IAuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  /// Executa o reset de senha
  ///
  /// [email] - Email do usuário para receber o link de reset
  ///
  /// Returns:
  /// - Right(void) - Sucesso no envio do email
  /// - Left(Failure) - Erro na operação
  Future<Either<Failure, void>> call(String email) async {
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    final cleanEmail = email.trim().toLowerCase();
    if (!AuthValidators.isValidEmail(cleanEmail)) {
      return const Left(ValidationFailure('Formato de email inválido'));
    }
    return await _authRepository.sendPasswordResetEmail(email: cleanEmail);
  }
}
