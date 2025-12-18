# Análise de Arquitetura de Sincronização

**Data:** 2025-12-18
**Apps Comparados:** app-plantis (referência) vs app-nebulalist (atual)
**Objetivo:** Avaliar estado atual do sync e planejar implementação robusta

---

## 📊 Resumo Executivo

| Aspecto | app-plantis (Gold Standard) | app-nebulalist (Atual) | Gap |
|---------|---------------------------|----------------------|-----|
| **ISyncService Implementation** | ✅ Implementado | ❌ Não implementado | 🔴 Crítico |
| **UnifiedSyncManager Integration** | ✅ Integrado | ❌ Não integrado | 🔴 Crítico |
| **Sync Queue (Offline Support)** | ✅ Drift persistence | ❌ Fire-and-forget | 🔴 Crítico |
| **Retry Logic** | ✅ SyncQueueDriftService | ❌ Nenhum | 🔴 Crítico |
| **Conflict Resolution** | ✅ Implementado | ❌ Nenhum | 🟡 Importante |
| **Progress Reporting** | ✅ Streams + UI | ❌ Nenhum | 🟡 Importante |
| **Background Sync** | ✅ BackgroundSyncService | ❌ Nenhum | 🟡 Importante |
| **Sync Status UI** | ✅ Widgets + feedback | ❌ Nenhum | 🟢 Desejável |

**Status Geral:** app-nebulalist está em **stub mode** com sync básico fire-and-forget (não confiável).

---

## 🏗️ Arquitetura app-plantis (Referência Gold Standard)

### **1. Camadas de Sync**

```
┌─────────────────────────────────────────────────────────┐
│              UI Layer (Riverpod Providers)              │
│  - SyncState (freezed)                                  │
│  - triggerManualSync()                                  │
│  - Sync status widgets                                  │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│            Service Layer (Sync Orchestration)           │
│  - PlantisSyncService (implements ISyncService)         │
│  - BackgroundSyncService                                │
│  - UnifiedSyncManager integration                       │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│          Queue & Persistence Layer (Offline)            │
│  - SyncQueue (adapter pattern)                          │
│  - SyncQueueDriftService (Drift persistence)            │
│  - SyncQueueDriftRepository                             │
│  - Retry logic & error handling                         │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│            Data Layer (Sync Adapters)                   │
│  - SubscriptionDriftSyncAdapter                         │
│  - Push dirty records (local → remote)                  │
│  - Pull remote changes (remote → local)                 │
│  - Conflict resolution                                  │
└─────────────────────────────────────────────────────────┘
```

### **2. Componentes-Chave**

#### **PlantisSyncService** (`lib/core/services/plantis_sync_service.dart`)
```dart
class PlantisSyncService implements ISyncService {
  @override
  String get serviceId => 'plantis';

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    // 1. Push local changes
    // 2. Pull remote changes
    // 3. Resolve conflicts
    // 4. Report progress via streams
  }
}
```

**Características:**
- ✅ Implementa `ISyncService` (interface do core)
- ✅ Streams de status e progresso
- ✅ Sync por etapas (subscriptions, plants, spaces, tasks, comments)
- ✅ Either<Failure, T> error handling
- ✅ Progress reporting (current/total)

#### **SyncQueueDriftService** (`lib/core/sync/sync_queue_drift_service.dart`)
```dart
class SyncQueueDriftService {
  /// Enfileira operação para sincronização offline
  Future<void> enqueue({
    required String modelType,
    required String modelId,
    required String operation,  // create/update/delete
    required Map<String, dynamic> data,
  });

  /// Processa fila com retry logic
  Future<int> processQueue({
    required Future<void> Function(PlantsSyncQueueData) syncCallback,
    int maxRetries = 3,
  });
}
```

**Características:**
- ✅ Persiste operações offline no Drift
- ✅ Retry automático (até 3 tentativas)
- ✅ Stream reativo de items pendentes
- ✅ Estatísticas (pending/synced/failed)
- ✅ Limpeza de items sincronizados

#### **Sync Adapters** (Pattern: Push + Pull)
```dart
class SubscriptionDriftSyncAdapter {
  /// Push local changes to remote
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(String userId);

  /// Pull remote changes to local
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(String userId);
}
```

**Características:**
- ✅ Two-way sync (push + pull)
- ✅ Dirty tracking (sabe quais records mudaram)
- ✅ Conflict detection e resolution
- ✅ Batch operations

#### **Riverpod Integration** (`lib/core/providers/sync_providers.dart`)
```dart
@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    String? error,
  }) = _SyncState;
}

@riverpod
class Sync extends _$Sync {
  Future<void> triggerManualSync() async {
    final result = await UnifiedSyncManager.instance.forceSyncApp('plantis');
    // Update state
  }
}
```

**Características:**
- ✅ Freezed immutability
- ✅ User-friendly status messages
- ✅ Error state management
- ✅ Manual sync trigger

---

## ⚠️ Estado Atual app-nebulalist

### **1. BasicSyncService** (Stub Mode)

**Localização:** `lib/core/sync/basic_sync_service.dart`

```dart
class BasicSyncService {
  Future<bool> syncAll() async {
    // TODO: Implement actual sync when repositories have sync methods
    // await _listRepository.syncLists();
    // await _itemRepository.syncItems();

    _lastSyncTime = DateTime.now();
    debugPrint('✅ Full sync completed (stub mode)');
    return true;
  }
}
```

**Problemas:**
- ❌ Não implementa ISyncService
- ❌ Todos métodos são stubs (retornam sucesso sem fazer nada)
- ❌ Não integrado com UnifiedSyncManager
- ❌ Sem persistência de operações

### **2. Repositories** (Fire-and-Forget Pattern)

**Exemplo:** `lib/features/items/data/repositories/item_master_repository.dart`

```dart
Future<Either<Failure, ItemMasterEntity>> createItemMaster(
  ItemMasterEntity itemMaster,
) async {
  // Save to local storage
  await _localDataSource.saveItemMaster(model);

  // Optional: Sync to remote (fire and forget)
  _remoteDataSource.saveItemMaster(model).ignore();  // ⚠️ PROBLEMA

  return Right(newItem);
}
```

**Problemas Críticos:**
- ❌ `.ignore()` descarta falhas silenciosamente
- ❌ Sem retry se falhar
- ❌ Sem queue para operações offline
- ❌ Perda de dados se sync falhar

**Cenário de Falha:**
```
1. Usuário cria item offline
2. Local save: ✅ Success
3. Remote sync: ❌ Falha (sem internet)
4. .ignore() → Erro descartado silenciosamente
5. Item existe localmente mas NUNCA vai para Firebase
6. ❌ PERDA DE DADOS
```

### **3. Sem Infraestrutura de Sync**

**Ausências:**
- ❌ Nenhum sync queue
- ❌ Nenhum sync adapter
- ❌ Nenhum conflict resolver
- ❌ Nenhum progress reporting
- ❌ Nenhuma UI de sync status

---

## 🎯 Plano de Implementação Recomendado

### **Fase 1: Infraestrutura Core** (Prioridade: 🔴 Crítica)

#### **1.1 Criar NebulalistSyncService** (2-3 horas)

**Localização:** `lib/core/services/nebulalist_sync_service.dart`

```dart
import 'package:core/core.dart';

/// Implementação do serviço de sincronização para o Nebulalist
class NebulalistSyncService implements ISyncService {
  final ListRepository _listRepository;
  final ItemMasterRepository _itemMasterRepository;
  final ListItemRepository _listItemRepository;
  final IAuthRepository _authRepository;

  final _statusController = StreamController<SyncServiceStatus>.broadcast();
  final _progressController = StreamController<ServiceProgress>.broadcast();

  @override
  String get serviceId => 'nebulalist';

  @override
  String get displayName => 'Nebulalist Sync Service';

  @override
  Future<Either<Failure, ServiceSyncResult>> sync() async {
    _updateStatus(SyncServiceStatus.syncing);

    try {
      int totalSynced = 0;

      // 1. Sync Lists
      _progressController.add(ServiceProgress(
        serviceId: serviceId,
        operation: 'syncing_lists',
        current: 1,
        total: 3,
        currentItem: 'Sincronizando listas...',
      ));

      final listsResult = await _syncLists();
      listsResult.fold(
        (failure) => throw Exception(failure.message),
        (count) => totalSynced += count,
      );

      // 2. Sync ItemMasters
      // 3. Sync ListItems

      return Right(ServiceSyncResult.success(
        itemsSynced: totalSynced,
        duration: Duration.zero,
      ));
    } catch (e) {
      _updateStatus(SyncServiceStatus.failed);
      return Left(ServerFailure('Sync failed: $e'));
    }
  }

  Future<Either<Failure, int>> _syncLists() async {
    // TODO: Implement using sync adapter pattern
  }
}
```

**Tarefas:**
- [ ] Implementar ISyncService interface
- [ ] Adicionar streams de status e progresso
- [ ] Implementar sync() para Lists, ItemMasters, ListItems
- [ ] Error handling com Either<Failure, T>
- [ ] Registrar no UnifiedSyncManager

#### **1.2 Criar Sync Queue com Drift** (3-4 horas)

**Tabela Drift:** `lib/core/database/tables/sync_queue_table.dart`

```dart
@DataClassName('NebulalistSyncQueueData')
class NebulalistSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelType => text()();  // 'List', 'ItemMaster', 'ListItem'
  TextColumn get modelId => text()();
  TextColumn get operation => text()();  // 'create', 'update', 'delete'
  TextColumn get data => text()();  // JSON serialized
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();
}
```

**Service:** `lib/core/sync/nebulalist_sync_queue_service.dart`

```dart
class NebulalistSyncQueueService {
  final NebulalistDatabase _database;

  /// Enfileira operação para sync offline
  Future<void> enqueue({
    required String modelType,
    required String modelId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _database.syncQueueDao.insertItem(
      modelType: modelType,
      modelId: modelId,
      operation: operation,
      data: jsonEncode(data),
    );
  }

  /// Processa fila com retry logic
  Future<int> processQueue({
    required Future<void> Function(NebulalistSyncQueueData) syncCallback,
    int maxRetries = 3,
  }) async {
    final pending = await _database.syncQueueDao.getPendingItems();
    int successCount = 0;

    for (final item in pending) {
      if (item.attempts >= maxRetries) continue;

      try {
        await syncCallback(item);
        await _database.syncQueueDao.markAsSynced(item.id);
        successCount++;
      } catch (e) {
        await _database.syncQueueDao.recordFailedAttempt(
          item.id,
          e.toString(),
        );
      }
    }

    return successCount;
  }
}
```

**Tarefas:**
- [ ] Adicionar tabela NebulalistSyncQueue ao database
- [ ] Criar DAO para sync queue
- [ ] Implementar NebulalistSyncQueueService
- [ ] Integrar com repositories (substituir `.ignore()`)

### **Fase 2: Sync Adapters** (Prioridade: 🔴 Crítica)

#### **2.1 List Sync Adapter** (2 horas)

**Localização:** `lib/features/lists/data/adapters/list_drift_sync_adapter.dart`

```dart
class ListDriftSyncAdapter {
  final ListLocalDataSource _localDataSource;
  final ListRemoteDataSource _remoteDataSource;

  /// Push dirty records (local → remote)
  Future<Either<Failure, SyncPushResult>> pushDirtyRecords(
    String userId,
  ) async {
    try {
      // 1. Get lists modified locally (dirty flag ou timestamp)
      final dirtyLists = await _localDataSource.getDirtyLists(userId);

      int pushed = 0;
      for (final list in dirtyLists) {
        // 2. Push to Firebase
        await _remoteDataSource.saveList(list);

        // 3. Mark as synced locally
        await _localDataSource.markAsSynced(list.id);
        pushed++;
      }

      return Right(SyncPushResult(recordsPushed: pushed));
    } catch (e) {
      return Left(ServerFailure('Push failed: $e'));
    }
  }

  /// Pull remote changes (remote → local)
  Future<Either<Failure, SyncPullResult>> pullRemoteChanges(
    String userId,
  ) async {
    try {
      // 1. Get remote lists
      final remoteLists = await _remoteDataSource.getLists(userId);

      int pulled = 0;
      for (final remoteList in remoteLists) {
        // 2. Check if exists locally
        final localList = await _localDataSource.getListById(remoteList.id);

        if (localList == null) {
          // New remote list → save locally
          await _localDataSource.saveList(remoteList);
          pulled++;
        } else {
          // Conflict detection
          if (remoteList.updatedAt.isAfter(localList.updatedAt)) {
            // Remote is newer → update local
            await _localDataSource.saveList(remoteList);
            pulled++;
          }
        }
      }

      return Right(SyncPullResult(recordsPulled: pulled));
    } catch (e) {
      return Left(ServerFailure('Pull failed: $e'));
    }
  }
}
```

**Tarefas:**
- [ ] Implementar ListDriftSyncAdapter (push + pull)
- [ ] Implementar ItemMasterDriftSyncAdapter
- [ ] Implementar ListItemDriftSyncAdapter
- [ ] Adicionar dirty tracking nos datasources
- [ ] Conflict resolution (last-write-wins para v1)

### **Fase 3: Repository Refactoring** (Prioridade: 🟡 Importante)

#### **3.1 Substituir Fire-and-Forget por Queue**

**Antes:**
```dart
// ❌ Fire-and-forget (não confiável)
_remoteDataSource.saveItemMaster(model).ignore();
```

**Depois:**
```dart
// ✅ Enfileira para sync (confiável)
await _syncQueueService.enqueue(
  modelType: 'ItemMaster',
  modelId: model.id,
  operation: 'create',
  data: model.toJson(),
);
```

**Tarefas:**
- [ ] Refatorar ItemMasterRepository
- [ ] Refatorar ListItemRepository
- [ ] Refatorar ListRepository
- [ ] Remover todos `.ignore()`
- [ ] Adicionar queue em todas operações CUD

### **Fase 4: UI & UX** (Prioridade: 🟢 Desejável)

#### **4.1 Riverpod Sync Providers**

**Localização:** `lib/core/providers/sync_providers.dart`

```dart
@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState({
    @Default(false) bool isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    String? error,
    @Default(0) int pendingItems,
  }) = _SyncState;
}

@riverpod
class Sync extends _$Sync {
  @override
  SyncState build() => const SyncState();

  Future<void> triggerManualSync() async {
    state = state.copyWith(isSyncing: true);

    final result = await UnifiedSyncManager.instance.forceSyncApp('nebulalist');

    result.fold(
      (failure) => state = state.copyWith(
        isSyncing: false,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      ),
    );
  }
}
```

#### **4.2 Sync Status Widget**

**Localização:** `lib/shared/widgets/sync_status_widget.dart`

```dart
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    if (syncState.isSyncing) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Sincronizando...'),
        ],
      );
    }

    if (syncState.error != null) {
      return const Icon(Icons.cloud_off, color: Colors.red);
    }

    return const Icon(Icons.cloud_done, color: Colors.green);
  }
}
```

**Tarefas:**
- [ ] Criar SyncState com freezed
- [ ] Implementar Sync provider (Riverpod)
- [ ] Criar SyncStatusWidget
- [ ] Adicionar pull-to-refresh em lists
- [ ] Status indicator na AppBar

---

## 📈 Estimativas

| Fase | Esforço | Prioridade | Risk |
|------|---------|-----------|------|
| **Fase 1: Infraestrutura Core** | 6-8h | 🔴 Crítica | Médio |
| **Fase 2: Sync Adapters** | 6-8h | 🔴 Crítica | Médio |
| **Fase 3: Repository Refactoring** | 4-6h | 🟡 Importante | Baixo |
| **Fase 4: UI & UX** | 3-4h | 🟢 Desejável | Baixo |
| **Total** | **19-26h** | - | - |

**Recomendação:** Implementar Fases 1-2 primeiro (sync confiável), depois Fase 3 (refactoring), depois Fase 4 (polish).

---

## ✅ Checklist de Implementação

### **Fase 1: Core**
- [ ] Criar NebulalistSyncService (implements ISyncService)
- [ ] Adicionar tabela NebulalistSyncQueue (Drift)
- [ ] Criar NebulalistSyncQueueService
- [ ] Registrar no UnifiedSyncManager
- [ ] Testes unitários (NebulalistSyncService)

### **Fase 2: Adapters**
- [ ] ListDriftSyncAdapter (push + pull)
- [ ] ItemMasterDriftSyncAdapter
- [ ] ListItemDriftSyncAdapter
- [ ] Dirty tracking em datasources
- [ ] Conflict resolution (last-write-wins)
- [ ] Testes unitários (adapters)

### **Fase 3: Refactoring**
- [ ] Remover `.ignore()` de todos repositories
- [ ] Adicionar enqueue em todas operações CUD
- [ ] Background sync automático
- [ ] Testes de integração (sync flow completo)

### **Fase 4: UI**
- [ ] SyncState + Sync provider (Riverpod)
- [ ] SyncStatusWidget
- [ ] Pull-to-refresh integration
- [ ] Error handling UI
- [ ] Manual sync button

---

## 🔍 Referências Técnicas

### **Arquivos app-plantis (copiar como base):**

1. **Service Implementation:**
   - `app-plantis/lib/core/services/plantis_sync_service.dart`
   - `app-plantis/lib/core/sync/sync_queue_drift_service.dart`

2. **Drift Setup:**
   - `app-plantis/lib/database/sync/tables/sync_queue_table.dart`
   - `app-plantis/lib/database/repositories/sync_queue_drift_repository.dart`

3. **Sync Adapters:**
   - `app-plantis/lib/database/sync/adapters/subscription_drift_sync_adapter.dart`

4. **Riverpod Providers:**
   - `app-plantis/lib/core/providers/sync_providers.dart`
   - `app-plantis/lib/core/providers/sync_status_notifier.dart`

5. **UI Widgets:**
   - `app-plantis/lib/core/widgets/sync_status_widget.dart`

### **Core Interfaces:**
- `packages/core/lib/src/sync/interfaces/i_sync_service.dart`
- `packages/core/lib/src/sync/unified_sync_manager.dart`

---

## 🎯 Próximos Passos Imediatos

1. **Criar branch:** `feature/sync-infrastructure`
2. **Implementar Fase 1** (NebulalistSyncService + SyncQueue)
3. **Testar offline-first behavior**
4. **Code review** antes de Fase 2
5. **Documentar padrões de uso** no README

---

**Status:** Aguardando aprovação para início da implementação.
