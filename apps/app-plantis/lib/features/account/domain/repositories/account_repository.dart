import 'package:core/core.dart';

import '../entities/account_info.dart';

/// Interface do repositório de conta do usuário
/// Segue o padrão de Clean Architecture
abstract class AccountRepository {
  /// Obtém informações da conta do usuário atual
  Future<Either<Failure, AccountInfo>> getAccountInfo();

  /// Realiza logout do usuário
  Future<Either<Failure, void>> logout();

  /// Limpa dados de conteúdo do usuário (plantas, tarefas)
  /// mantendo a conta ativa
  Future<Either<Failure, int>> clearUserData();

  /// Solicita exclusão da conta do usuário
  /// Esta operação é irreversível
  Future<Either<Failure, void>> deleteAccount();

  /// Verifica se o usuário está autenticado
  Future<Either<Failure, bool>> isAuthenticated();

  /// Stream para observar mudanças no estado da conta
  Stream<AccountInfo?> watchAccountInfo();
}
