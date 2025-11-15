import 'package:core/core.dart';

/// Interface para serviços especializados em reconciliação de IDs
///
/// **Responsabilidades (Single Responsibility):**
/// - Reconciliar ID específico de um domínio
/// - Atualizar referências após push remoto
/// - Marcar reconciliação como completa
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas reconciliação necessária)
/// - Segregado por domínio (Vehicle, Fuel, Maintenance)
///
/// **Genérico:** Pode ser usado para qualquer tipo de reconciliação de ID
///
/// **Exemplo:**
/// ```dart
/// final result = await reconciliationService.reconcileId('local_123', 'remote_456');
/// result.fold(
///   (failure) => print('Reconciliation failed: ${failure.message}'),
///   (_) => print('ID reconciliated successfully'),
/// );
/// ```
abstract class IIdReconciliationService {
  /// Reconcilia ID local com ID remoto retornado pelo Firebase
  ///
  /// Atualiza todas as referências do localId para remoteId no banco local.
  /// Usado após push retornar novo ID criado no Firestore.
  ///
  /// Retorna:
  /// - Right(null): Reconciliação completa
  /// - Left(failure): Erro durante reconciliação
  Future<Either<Failure, void>> reconcileId(String localId, String remoteId);

  /// Verifica se há reconciliações pendentes
  ///
  /// Retorna:
  /// - Right(count): Número de reconciliações pendentes
  /// - Left(failure): Erro ao verificar
  Future<Either<Failure, int>> getPendingCount();
}
