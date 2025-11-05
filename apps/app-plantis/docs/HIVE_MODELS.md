# Documentação dos Modelos Hive - APP PLANTIS

> Documentação gerada automaticamente em /private/tmp
> Data de geração: $(date +"%d/%m/%Y %H:%M:%S")

## Índice

- [ComentarioModel](#comentariomodel)
- [ConflictHistoryModel](#conflicthistorymodel)
- [EspacoModel](#espacomodel)
- [PlantaConfigModel](#plantaconfigmodel)
- [SyncQueueItem](#syncqueueitem)

---

## ComentarioModel

**TypeId**: `0`  
**Arquivo**: `app-plantis/lib/core/data/models/comentario_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `conteudo` | `String` | ✗ |
| 11 | `dataAtualizacao` | `DateTime` | ✓ |
| 12 | `dataCriacao` | `DateTime` | ✓ |
| 13 | `plantId` | `String` | ✓ |

---

## ConflictHistoryModel

**TypeId**: `10`  
**Arquivo**: `app-plantis/lib/core/data/models/conflict_history_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `modelType` | `String` | ✗ |
| 4 | `modelId` | `String` | ✗ |
| 5 | `resolutionStrategy` | `String` | ✗ |
| 6 | `localData` | `Map<String, dynamic>` | ✗ |
| 7 | `remoteData` | `Map<String, dynamic>` | ✗ |
| 8 | `resolvedData` | `Map<String, dynamic>` | ✗ |
| 9 | `autoResolved` | `bool` | ✗ |

---

## EspacoModel

**TypeId**: `1`  
**Arquivo**: `app-plantis/lib/core/data/models/espaco_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `nome` | `String` | ✗ |
| 11 | `descricao` | `String` | ✓ |
| 12 | `ativo` | `bool` | ✗ |
| 13 | `dataCriacao` | `DateTime` | ✓ |

---

## PlantaConfigModel

**TypeId**: `4`  
**Arquivo**: `app-plantis/lib/core/data/models/planta_config_model.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `createdAtMs` | `int` | ✓ |
| 2 | `updatedAtMs` | `int` | ✓ |
| 3 | `lastSyncAtMs` | `int` | ✓ |
| 4 | `isDirty` | `bool` | ✗ |
| 5 | `isDeleted` | `bool` | ✗ |
| 6 | `version` | `int` | ✗ |
| 7 | `userId` | `String` | ✓ |
| 8 | `moduleName` | `String` | ✓ |
| 10 | `plantaId` | `String` | ✗ |
| 11 | `aguaAtiva` | `bool` | ✗ |
| 12 | `intervaloRegaDias` | `int` | ✗ |
| 13 | `aduboAtivo` | `bool` | ✗ |
| 14 | `intervaloAdubacaoDias` | `int` | ✗ |
| 15 | `banhoSolAtivo` | `bool` | ✗ |
| 16 | `intervaloBanhoSolDias` | `int` | ✗ |
| 17 | `inspecaoPragasAtiva` | `bool` | ✗ |
| 18 | `intervaloInspecaoPragasDias` | `int` | ✗ |
| 19 | `podaAtiva` | `bool` | ✗ |
| 20 | `intervaloPodaDias` | `int` | ✗ |
| 21 | `replantarAtivo` | `bool` | ✗ |
| 22 | `intervaloReplantarDias` | `int` | ✗ |

---

## SyncQueueItem

**TypeId**: `100`  
**Arquivo**: `app-plantis/lib/core/data/models/sync_queue_item.dart`

### Campos (HiveFields)

| ID | Nome do Campo | Tipo | Nullable |
|----|---------------|------|----------|
| 0 | `id` | `String` | ✗ |
| 1 | `modelType` | `String` | ✗ |
| 2 | `operation` | `String` | ✗ |
| 3 | `data` | `Map<String, dynamic>` | ✗ |
| 4 | `timestamp` | `DateTime` | ✗ |
| 5 | `retryCount` | `int` | ✗ |
| 6 | `isSynced` | `bool` | ✗ |

---

