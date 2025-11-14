import 'package:drift/drift.dart';
import 'package:core/core.dart';

import '../models/sync_results.dart';

/// Interface base para adapters que sincronizam Drift ↔ Firestore
///
/// Define o contrato para conversão bidirecional entre 3 representações:
/// - **Drift Row** (TDriftRow): Dados do SQLite via Drift ORM
/// - **Domain Entity** (TEntity): Entidades de negócio (Clean Architecture)
/// - **Firestore Document** (Map\<String, dynamic\>): JSON para Firebase
///
/// Responsabilidades:
/// - Conversões type-safe entre representações
/// - Validação de dados durante parsing
/// - Sincronização incremental (push/pull)
/// - Resolução de conflitos
///
/// Type Parameters:
/// - TEntity: Domain entity (extends BaseSyncEntity)
/// - TDriftRow: Drift table row type
abstract class IDriftSyncAdapter<TEntity extends BaseSyncEntity, TDriftRow> {
  /// Converte Drift Row → Domain Entity
  ///
  /// Transforma dados do SQLite em entidade de domínio type-safe.
  /// Não pode falhar - assume que dados no Drift são sempre válidos.
  ///
  /// Example:
  /// ```dart
  /// final row = VehicleTableData(...);
  /// final entity = adapter.toDomainEntity(row);
  /// ```
  TEntity toDomainEntity(TDriftRow driftRow);

  /// Converte Domain Entity → Drift Companion (para update/insert)
  ///
  /// Prepara dados da entidade para operações CRUD no Drift.
  /// Retorna Insertable\<TDriftRow\> para compatibilidade com Drift API.
  ///
  /// Example:
  /// ```dart
  /// final entity = VehicleEntity(...);
  /// final companion = adapter.toCompanion(entity);
  /// await db.update(db.vehicles).replace(companion);
  /// ```
  Insertable<TDriftRow> toCompanion(TEntity entity);

  /// Converte Domain Entity → Firestore Map
  ///
  /// Serializa entidade para JSON compatível com Firestore.
  /// Campos de metadata (version, updatedAt) devem ser incluídos.
  ///
  /// Example:
  /// ```dart
  /// final entity = VehicleEntity(...);
  /// final firestoreDoc = adapter.toFirestoreMap(entity);
  /// await firestore.collection('vehicles').doc(entity.id).set(firestoreDoc);
  /// ```
  Map<String, dynamic> toFirestoreMap(TEntity entity);

  /// Converte Firestore Map → Domain Entity
  ///
  /// Deserializa documento Firestore em entidade de domínio.
  /// **DEVE validar campos obrigatórios** e retornar Either\<Failure, TEntity\>.
  ///
  /// Retorna:
  /// - Right(entity): Parsing bem-sucedido
  /// - Left(ValidationFailure): Campos obrigatórios faltando
  /// - Left(ParseFailure): Tipos de dados inválidos
  ///
  /// Example:
  /// ```dart
  /// final doc = await firestore.collection('vehicles').doc(id).get();
  /// final result = adapter.fromFirestoreMap(doc.data()!);
  /// result.fold(
  ///   (failure) => print('Parse error: ${failure.message}'),
  ///   (entity) => repository.save(entity),
  /// );
  /// ```
  Either<Failure, TEntity> fromFirestoreMap(Map<String, dynamic> map);

  /// Valida entity antes de sincronizar
  ///
  /// Verifica se a entidade está em estado consistente para sync:
  /// - ID não vazio
  /// - userId definido
  /// - Campos obrigatórios preenchidos
  /// - Regras de negócio específicas da entidade
  ///
  /// Retorna:
  /// - Right(void): Validação passou
  /// - Left(ValidationFailure): Validação falhou com detalhes
  ///
  /// Example:
  /// ```dart
  /// final result = adapter.validateForSync(entity);
  /// if (result.isLeft()) {
  ///   print('Validation failed: ${(result as Left).value.message}');
  /// }
  /// ```
  Either<Failure, void> validateForSync(TEntity entity);

  /// Push: Sincroniza registros dirty locais → Firestore
  ///
  /// Encontra todos os registros marcados como isDirty = true e
  /// faz upload para Firestore. Atualiza metadata após sucesso.
  ///
  /// Processo:
  /// 1. Query Drift WHERE isDirty = true AND userId = userId
  /// 2. Batch upload (max 50 items) para Firestore
  /// 3. Marca registros como synced (isDirty = false, lastSyncAt = now)
  /// 4. Retry automático em caso de falha
  ///
  /// Parameters:
  /// - userId: ID do usuário (para filtrar registros)
  ///
  /// Retorna:
  /// - Right(SyncPushResult): Sucesso com estatísticas
  /// - Left(NetworkFailure): Sem conectividade
  /// - Left(AuthFailure): Usuário não autenticado
  /// - Left(SyncFailure): Erro durante sincronização
  ///
  /// Example:
  /// ```dart
  /// final result = await adapter.pushDirtyRecords('user-123');
  /// result.fold(
  ///   (failure) => print('Push failed: ${failure.message}'),
  ///   (syncResult) => print('Pushed ${syncResult.recordsPushed} records'),
  /// );
  /// ```
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(String userId);

  /// Pull: Busca mudanças remotas → Drift (incremental)
  ///
  /// Baixa alterações do Firestore desde a última sincronização e
  /// atualiza banco local. Implementa sync incremental eficiente.
  ///
  /// Processo:
  /// 1. Query Firestore WHERE updatedAt > since (ou todos se since = null)
  /// 2. Para cada documento remoto:
  ///    - Parse para entidade (validação)
  ///    - Verifica conflito com versão local
  ///    - Resolve conflito se necessário
  ///    - Atualiza Drift
  /// 3. Atualiza timestamp da última sincronização
  ///
  /// Parameters:
  /// - userId: ID do usuário (para filtrar registros)
  /// - since: Timestamp da última sincronização (null = full sync)
  ///
  /// Retorna:
  /// - Right(SyncPullResult): Sucesso com estatísticas
  /// - Left(NetworkFailure): Sem conectividade
  /// - Left(ParseFailure): Erro ao deserializar documentos
  /// - Left(SyncFailure): Erro durante sincronização
  ///
  /// Example:
  /// ```dart
  /// final lastSync = DateTime.now().subtract(Duration(hours: 1));
  /// final result = await adapter.pullRemoteChanges('user-123', since: lastSync);
  /// result.fold(
  ///   (failure) => print('Pull failed: ${failure.message}'),
  ///   (syncResult) => print('Pulled ${syncResult.recordsPulled} records'),
  /// );
  /// ```
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId, {
    DateTime? since,
  });

  /// Resolve conflitos entre versões local e remota
  ///
  /// Implementa estratégia de resolução quando:
  /// - Registro existe local E remotamente
  /// - Versão local isDirty = true (pendente de push)
  /// - Versões diferem (local.version ≠ remote.version)
  ///
  /// Estratégia padrão: **Last Write Wins (LWW)**
  /// - Compara version number
  /// - Se versions iguais, compara updatedAt timestamp
  /// - Versão mais recente vence
  ///
  /// Pode ser sobrescrito por subclasses para estratégias customizadas:
  /// - User prompt (perguntar ao usuário)
  /// - Field-level merge (mesclar campos não conflitantes)
  /// - Business rule specific (regras de negócio)
  ///
  /// Parameters:
  /// - local: Entidade local (dirty)
  /// - remote: Entidade remota (do Firestore)
  ///
  /// Retorna: Entidade resolvida (pode ser local, remote, ou merge)
  ///
  /// Example:
  /// ```dart
  /// final resolved = adapter.resolveConflict(localVehicle, remoteVehicle);
  /// await repository.update(resolved);
  /// ```
  TEntity resolveConflict(TEntity local, TEntity remote);
}
