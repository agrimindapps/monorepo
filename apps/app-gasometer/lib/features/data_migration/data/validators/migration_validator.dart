import 'package:core/core.dart';

/// Validador de operações de migração
///
/// Responsabilidade: Validar pré-condições e regras de negócio de migração
/// Aplica SRP (Single Responsibility Principle)
@injectable
class MigrationValidator {
  /// Valida IDs de usuário
  Either<Failure, Unit> validateUserIds({
    required String anonymousUserId,
    required String accountUserId,
  }) {
    if (anonymousUserId.isEmpty) {
      return const Left(ValidationFailure('ID de usuário anônimo inválido'));
    }

    if (accountUserId.isEmpty) {
      return const Left(ValidationFailure('ID de conta de usuário inválido'));
    }

    if (anonymousUserId == accountUserId) {
      return const Left(
        ValidationFailure('IDs de usuário não podem ser iguais'),
      );
    }

    return const Right(unit);
  }

  /// Valida se usuário anônimo é válido para migração
  Either<Failure, Unit> validateAnonymousUser(bool isValid) {
    if (!isValid) {
      return const Left(
        ValidationFailure('Usuário anônimo inválido ou não encontrado'),
      );
    }
    return const Right(unit);
  }

  /// Valida se conta de usuário é válida para migração
  Either<Failure, Unit> validateAccountUser(bool isValid) {
    if (!isValid) {
      return const Left(
        ValidationFailure('Conta de usuário inválida ou não encontrada'),
      );
    }
    return const Right(unit);
  }

  /// Valida conectividade de rede
  Either<Failure, Unit> validateNetworkConnectivity(bool hasConnection) {
    if (!hasConnection) {
      return const Left(
        NetworkFailure('Conectividade necessária para migração'),
      );
    }
    return const Right(unit);
  }

  /// Valida pré-condições completas de migração
  Future<Either<Failure, Unit>> validateMigrationPreconditions({
    required String anonymousUserId,
    required String accountUserId,
    required bool hasNetworkConnection,
    required bool isAnonymousUserValid,
    required bool isAccountUserValid,
  }) async {
    // Valida IDs
    final idsValidation = validateUserIds(
      anonymousUserId: anonymousUserId,
      accountUserId: accountUserId,
    );
    if (idsValidation.isLeft()) return idsValidation;

    // Valida conectividade
    final networkValidation = validateNetworkConnectivity(hasNetworkConnection);
    if (networkValidation.isLeft()) return networkValidation;

    // Valida usuário anônimo
    final anonymousValidation = validateAnonymousUser(isAnonymousUserValid);
    if (anonymousValidation.isLeft()) return anonymousValidation;

    // Valida conta de usuário
    final accountValidation = validateAccountUser(isAccountUserValid);
    if (accountValidation.isLeft()) return accountValidation;

    return const Right(unit);
  }
}
