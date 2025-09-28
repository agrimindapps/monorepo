import 'package:core/core.dart';

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
    // Validação do email antes de enviar
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }

    final cleanEmail = email.trim().toLowerCase();

    // Validação de formato usando o validador existente
    if (!_isValidEmailFormat(cleanEmail)) {
      return const Left(ValidationFailure('Formato de email inválido'));
    }

    // Enviar email de reset via repository
    return await _authRepository.sendPasswordResetEmail(email: cleanEmail);
  }

  /// Validação básica de formato de email
  /// Usando regex simplificado para o use case
  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email) &&
        email.length <= 320 &&
        !email.contains('..');
  }
}
