# Drift-Firestore Sync Foundation Layer

Foundation layer para sincronização bidirecional entre Drift (SQLite local) e Firestore (cloud storage) seguindo ADR-001.

## 📦 Componentes Implementados

### 1. Interface: `IDriftSyncAdapter<TEntity, TDriftRow>`

**Arquivo:** `adapters/i_drift_sync_adapter.dart`

Interface que define o contrato para adapters de sincronização:

**Conversões:**
- `toDomainEntity()`: Drift Row → Domain Entity
- `toCompanion()`: Domain Entity → Drift Companion
- `toFirestoreMap()`: Domain Entity → Firestore Map
- `fromFirestoreMap()`: Firestore Map → Domain Entity (com validação)

**Operações de Sync:**
- `pushDirtyRecords()`: Upload local → Firestore (batch 50 items)
- `pullRemoteChanges()`: Download Firestore → local (incremental)
- `validateForSync()`: Validação pré-sincronização
- `resolveConflict()`: Resolução de conflitos (Last Write Wins)

### 2. Classes de Resultado: `SyncPushResult` e `SyncPullResult`

**Arquivo:** `models/sync_results.dart`

#### SyncPushResult (Push local → Firestore)

```dart
class SyncPushResult {
  final int recordsPushed;      // Registros enviados com sucesso
  final int recordsFailed;       // Registros que falharam
  final List<String> errors;     // Mensagens de erro
  final Duration duration;       // Tempo da operação

  bool get isSuccess;            // 100% sucesso?
  bool get isPartialSuccess;     // Sucesso parcial?
  double get successRate;        // Taxa de sucesso (0.0 a 1.0)
  String get summary;            // Mensagem resumo
}
```

#### SyncPullResult (Pull Firestore → local)

```dart
class SyncPullResult {
  final int recordsPulled;       // Novos registros baixados
  final int recordsUpdated;      // Registros existentes atualizados
  final int conflictsResolved;   // Conflitos resolvidos
  final List<String> warnings;   // Avisos não-críticos
  final Duration duration;       // Tempo da operação

  int get totalRecords;          // Total afetado
  bool get hasChanges;           // Houve mudanças?
  bool get hasConflicts;         // Houve conflitos?
  String get summary;            // Mensagem resumo
}
```

### 3. Classe Base: `DriftSyncAdapterBase<TEntity, TDriftRow>`

**Arquivo:** `adapters/drift_sync_adapter_base.dart`

Classe abstrata que fornece implementação comum de sincronização.

**Responsabilidades:**
- ✅ Push incremental com batch operations (max 50 items)
- ✅ Pull incremental com query `WHERE updatedAt > since`
- ✅ Conflict resolution: Last Write Wins (version > timestamp)
- ✅ Error handling com Either<Failure, T>
- ✅ Retry logic (implementado via batch processing)
- ✅ Logging detalhado para debug

**Dependências:**
- `GasometerDatabase`: Operações Drift locais
- `FirebaseFirestore`: Operações remotas
- `ConnectivityService`: Verificação de conectividade

**Métodos Abstratos (Subclasses devem implementar):**

```dart
// Configuração
String get collectionName;              // Ex: 'vehicles'
TableInfo<Table, dynamic> get table;    // Ex: db.vehicles

// Conversões (da interface IDriftSyncAdapter)
TEntity toDomainEntity(TDriftRow row);
Insertable<TDriftRow> toCompanion(TEntity entity);
Map<String, dynamic> toFirestoreMap(TEntity entity);
Either<Failure, TEntity> fromFirestoreMap(Map<String, dynamic> map);

// Operações Drift específicas
Future<Either<Failure, List<TEntity>>> _getDirtyRecords(String userId);
Future<Either<Failure, TEntity?>> _getLocalEntity(String id);
Future<Either<Failure, void>> _insertLocal(TEntity entity);
Future<Either<Failure, void>> _updateLocal(TEntity entity);
Future<Either<Failure, void>> _markAsSynced(String id);
```

## 🚀 Como Usar

### 1. Criar Adapter Concreto

```dart

class VehicleDriftSyncAdapter extends DriftSyncAdapterBase<VehicleEntity, VehicleTableData> {
  VehicleDriftSyncAdapter(
    GasometerDatabase db,
    FirebaseFirestore firestore,
    ConnectivityService connectivityService,
  ) : super(db, firestore, connectivityService);

  @override
  String get collectionName => 'vehicles';

  @override
  TableInfo<Table, dynamic> get table => db.vehicles;

  // Implementar conversões...
  @override
  VehicleEntity toDomainEntity(VehicleTableData row) {
    // Drift Row → Domain Entity
  }

  @override
  VehiclesCompanion toCompanion(VehicleEntity entity) {
    // Domain Entity → Drift Companion
  }

  @override
  Map<String, dynamic> toFirestoreMap(VehicleEntity entity) {
    // Domain Entity → Firestore Map
  }

  @override
  Either<Failure, VehicleEntity> fromFirestoreMap(Map<String, dynamic> map) {
    // Firestore Map → Domain Entity (com validação)
  }

  // Implementar operações Drift específicas...
  @override
  Future<Either<Failure, List<VehicleEntity>>> _getDirtyRecords(String userId) async {
    try {
      final query = db.select(db.vehicles)
        ..where((t) => t.userId.equals(userId) & t.isDirty.equals(true));
      final rows = await query.get();
      return Right(rows.map(toDomainEntity).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get dirty records: $e'));
    }
  }

  // ... outras operações Drift
}
```

### 2. Push Registros Dirty

```dart
final adapter = VehicleDriftSyncAdapter(db, firestore, connectivityService);

final result = await adapter.pushDirtyRecords('user-123');

result.fold(
  (failure) {
    print('Push failed: ${failure.message}');
    if (failure is NetworkFailure) {
      // Sem conectividade
    } else if (failure is SyncFailure) {
      // Erro de sincronização
    }
  },
  (syncResult) {
    print(syncResult.summary);
    // "Push successful: 5 records in 1250ms"

    if (syncResult.isPartialSuccess) {
      print('Some records failed:');
      syncResult.errors.forEach(print);
    }
  },
);
```

### 3. Pull Mudanças Remotas

```dart
// Pull incremental (apenas mudanças desde última sync)
final lastSync = DateTime.now().subtract(Duration(hours: 1));
final result = await adapter.pullRemoteChanges('user-123', since: lastSync);

result.fold(
  (failure) => print('Pull failed: ${failure.message}'),
  (syncResult) {
    print(syncResult.summary);
    // "Pull complete: 3 new, 2 updated, 1 conflict (850ms)"

    if (syncResult.hasConflicts) {
      print('Conflicts resolved: ${syncResult.conflictsResolved}');
    }
  },
);

// Pull completo (todos os registros)
final fullResult = await adapter.pullRemoteChanges('user-123');
```

## 🔄 Fluxo de Sincronização

### Push Strategy (Local → Firestore)

```
1. Verificar conectividade (ConnectivityService.isOnline())
2. Query Drift: SELECT * WHERE isDirty = true AND userId = userId
3. Validar cada entidade (validateForSync)
4. Converter para Firestore map (toFirestoreMap)
5. Batch upload (max 50 items por batch)
   - Incrementar version
   - Set updatedAt = FieldValue.serverTimestamp()
   - Firestore.batch.set(merge: true)
6. Marcar como synced localmente:
   - isDirty = false
   - lastSyncAt = DateTime.now()
7. Retornar SyncPushResult
```

### Pull Strategy (Firestore → Local)

```
1. Verificar conectividade
2. Query Firestore: WHERE updatedAt > since (ou todos se since = null)
3. Para cada documento remoto:
   a. Parse Firestore → Entity (fromFirestoreMap com validação)
   b. Verificar se existe localmente (_getLocalEntity)
   c. Se NÃO existe → Insert local (_insertLocal)
   d. Se existe E está dirty → CONFLITO
      - Resolver com resolveConflict (LWW)
      - Update local (_updateLocal)
   e. Se existe E NÃO está dirty → Update local
4. Retornar SyncPullResult
```

### Conflict Resolution (Last Write Wins)

```
1. Comparar version numbers:
   - remote.version > local.version → Remote vence
   - local.version > remote.version → Local vence

2. Se versions iguais, comparar timestamps:
   - updatedAt mais recente vence
   - Se timestamps iguais/nulos → Remote vence (tiebreaker)

3. Versão vencedora:
   - Se remote vence: isDirty = false, lastSyncAt = now
   - Se local vence: isDirty = true (push novamente)
```

## 🧪 Testing

```dart
void main() {
  late VehicleDriftSyncAdapter adapter;
  late GasometerDatabase mockDb;
  late FirebaseFirestore mockFirestore;
  late ConnectivityService mockConnectivity;

  setUp(() {
    mockDb = MockGasometerDatabase();
    mockFirestore = MockFirebaseFirestore();
    mockConnectivity = MockConnectivityService();

    adapter = VehicleDriftSyncAdapter(
      mockDb,
      mockFirestore,
      mockConnectivity,
    );
  });

  test('should push dirty records to Firestore', () async {
    // Arrange
    when(() => mockConnectivity.isOnline()).thenAnswer((_) async => Right(true));
    when(() => mockDb.select(any()).get()).thenAnswer(
      (_) async => [VehicleTableData(isDirty: true)],
    );

    // Act
    final result = await adapter.pushDirtyRecords('user-123');

    // Assert
    expect(result.isRight(), true);
    final syncResult = (result as Right<Failure, SyncPushResult>).value;
    expect(syncResult.recordsPushed, 1);
    verify(() => mockFirestore.batch().commit()).called(1);
  });
}
```

## 📊 Métricas de Performance

**Batch Size:** 50 items (limite Firestore)
**Target Performance:**
- Push 1000 records: < 3s
- Pull 1000 records: < 3s
- Conflict resolution: O(n) linear

**Network Efficiency:**
- Incremental sync (apenas mudanças desde lastSyncAt)
- Batch operations (reduz round-trips)
- Merge writes (evita overwrites)

## ⚠️ Limitações Conhecidas

1. **Conflict Resolution:**
   - Apenas Last Write Wins (LWW) implementado
   - Field-level merge: não implementado (future)
   - User prompt: não implementado (future)

2. **Error Recovery:**
   - Retry automático: limitado (batch-level)
   - Dead letter queue: não implementado
   - Partial failure handling: logs apenas

3. **Performance:**
   - Full sync pode ser lento para 1000+ records
   - Sem paginação em pull (carrega todos documentos)
   - Sem background processing (implementar em Phase 4)

## 🔜 Próximos Passos (Fora do Escopo Atual)

**Phase 2:** Implementações Concretas
- VehicleDriftSyncAdapter
- FuelSupplyDriftSyncAdapter
- MaintenanceDriftSyncAdapter
- ExpenseDriftSyncAdapter
- OdometerReadingDriftSyncAdapter
- AuditTrailDriftSyncAdapter

**Phase 3:** Sync Service Orchestrator
- GasometerDriftSyncService (coordena múltiplos adapters)

**Phase 4:** Background Sync
- GasometerBatchSyncService (periodic auto-sync)

## 📚 Referências

- **ADR-001:** `apps/app-gasometer-drift/docs/architecture/ADR-001-drift-firestore-sync.md`
- **Clean Architecture:** Separação Domain/Data/Presentation
- **Error Handling:** Either<Failure, T> pattern (dartz)
- **Drift Docs:** https://drift.simonbinder.eu/docs/
- **Firestore Best Practices:** https://firebase.google.com/docs/firestore/best-practices
