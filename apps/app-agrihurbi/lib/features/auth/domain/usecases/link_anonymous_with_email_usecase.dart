import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:core/core.dart' hide Failure, ValidationFailure, NetworkFailure;

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case para vincular conta anônima com email/senha
///
/// Converte usuário anônimo em usuário registrado permanente,
/// preservando dados do período anônimo
class LinkAnonymousWithEmailUseCase
    implements UseCase<UserEntity, LinkAnonymousParams> {
  final AuthRepository _repository;

  const LinkAnonymousWithEmailUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(LinkAnonymousParams params) async {
    // Validações
    if (params.name.trim().length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'),
      );
    }

    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(message: 'Email inválido'));
    }

    if (params.password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Senha deve ter pelo menos 6 caracteres'),
      );
    }

    return _repository.linkAnonymousWithEmail(
      name: params.name.trim(),
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Parâmetros para vincular conta anônima
class LinkAnonymousParams {
  final String name;
  final String email;
  final String password;

  const LinkAnonymousParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
