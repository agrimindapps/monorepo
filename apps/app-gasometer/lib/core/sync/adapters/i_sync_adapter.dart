import 'package:core/core.dart';
import '../models/sync_results.dart';

/// Interface abstrata para adapters de sincronização Drift ↔ Firestore
///
/// **Responsabilidades:**
/// - Operação de push (envio para Firestore)
/// - Operação de pull (recebimento do Firestore)
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas sync necessários)
/// - Segregado de validações complexas
/// - Genérico para uso em registry pattern
///
/// **Exemplo de Implementação:**
/// ```dart
/// class VehicleSyncAdapter implements ISyncAdapter {
///   @override
///   Future<Either<Failure, SyncPushResult>> pushDirtyRecords(String userId) {
///     // implementação específica
///   }
///
///   @override
///   Future<Either<Failure, SyncPullResult>> pullRemoteChanges(String userId) {
///     // implementação específica
///   }
/// }
/// ```
abstract class ISyncAdapter {
  /// Identificador único do adapter para logging e diagnostics
  String get name;

  /// Push: Sincroniza registros dirty locais → Firestore
  ///
  /// Encontra registros marcados como isDirty = true e
  /// faz upload para Firestore. Atualiza metadata após sucesso.
  ///
  /// Retorna:
  /// - Right(SyncPushResult): Sucesso com estatísticas
  /// - Left(failure): Erro durante sincronização
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(String userId);

  /// Pull: Busca mudanças remotas → Drift (incremental)
  ///
  /// Baixa alterações do Firestore desde a última sincronização e
  /// atualiza banco local.
  ///
  /// Retorna:
  /// - Right(SyncPullResult): Sucesso com estatísticas
  /// - Left(failure): Erro durante sincronização
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId, {
    DateTime? since,
  });
}
