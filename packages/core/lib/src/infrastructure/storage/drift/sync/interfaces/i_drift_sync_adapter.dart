import 'package:drift/drift.dart';

import '../../../../../../core.dart';

/// Interface para adaptadores de sincronização Drift ↔ Firestore
///
/// Define o contrato que todos os adaptadores devem seguir para implementar
/// sincronização bidirecional entre tabelas Drift locais e coleções Firestore.
///
/// **Responsabilidades:**
/// - Push: Enviar registros locais dirty para Firebase
/// - Pull: Baixar mudanças remotas do Firebase para local
/// - Conflict Resolution: Resolver conflitos entre versões local e remota
/// - Validation: Validar dados antes da sincronização
///
/// **Tipo Genéricos:**
/// - TEntity: Entidade de sincronização (ex: BaseSyncEntity)
/// - TDriftRow: Tipo de dados da tabela Drift (ex: DiagnosticoData)
abstract class IDriftSyncAdapter<TEntity, TDriftRow> {
  /// Nome da coleção no Firestore
  String get collectionName;

  /// Tabela Drift correspondente
  TableInfo<Table, dynamic> get table;

  // ==========================================================================
  // PUSH: Local → Firestore
  // ==========================================================================

  /// Envia registros dirty (não sincronizados) para o Firestore
  ///
  /// [userId] - ID do usuário (para coleção users/{userId}/{collection})
  ///
  /// Retorna resultado com quantidade de registros enviados e falhas
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(String userId);

  /// Busca registros dirty (isDirty = true) que precisam ser sincronizados
  Future<Either<Failure, List<TEntity>>> getDirtyRecords(String userId);

  /// Marca registros como sincronizados (isDirty = false)
  ///
  /// [localId] - ID local do registro no Drift
  /// [firebaseId] - ID do documento no Firestore (opcional, para novos registros)
  Future<Either<Failure, void>> markAsSynced(
    String localId, {
    String? firebaseId,
  });

  // ==========================================================================
  // PULL: Firestore → Local
  // ==========================================================================

  /// Baixa mudanças remotas do Firestore para o banco local
  ///
  /// [userId] - ID do usuário
  /// [since] - Timestamp da última sincronização (null = full sync)
  ///
  /// Retorna resultado com quantidade de registros baixados e falhas
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId, {
    DateTime? since,
  });

  // ==========================================================================
  // CONVERSÃO: Drift ↔ Firestore
  // ==========================================================================

  /// Converte um registro Drift para entidade de sincronização
  TEntity driftToEntity(TDriftRow driftRow);

  /// Converte uma entidade para companion Drift (para insert/update)
  Insertable<TDriftRow> entityToCompanion(TEntity entity);

  /// Converte uma entidade para Map Firestore
  Map<String, dynamic> toFirestoreMap(TEntity entity);

  /// Converte um documento Firestore para entidade
  TEntity fromFirestoreDoc(Map<String, dynamic> doc);

  // ==========================================================================
  // VALIDAÇÃO E CONFLITOS
  // ==========================================================================

  /// Valida se a entidade está pronta para sincronização
  Either<Failure, void> validateForSync(TEntity entity);

  /// Resolve conflito entre versão local e remota
  ///
  /// Estratégia padrão: Last Write Wins (LWW) baseado em updatedAt
  Future<Either<Failure, TEntity>> resolveConflict(
    TEntity local,
    TEntity remote,
  );
}
