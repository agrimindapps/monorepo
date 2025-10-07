# Sincronização Hive-Firebase - Plantis

**Documento Técnico de Implementação**
**Versão:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Em Produção (Parcial)

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Hive Boxes Utilizados](#hive-boxes-utilizados)
4. [Sincronização Realtime](#sincronização-realtime)
5. [Estratégias de Sync](#estratégias-de-sync)
6. [Conflict Resolution](#conflict-resolution)
7. [SyncCoordinatorService](#synccoordinatorservice)
8. [Offline-First Strategy](#offline-first-strategy)
9. [Fluxos de Sincronização](#fluxos-de-sincronização)
10. [Estado da Implementação](#estado-da-implementação)
11. [Gaps e Pendências](#gaps-e-pendências)
12. [Recomendações de Excelência](#recomendações-de-excelência)
13. [Roadmap de Implementação](#roadmap-de-implementação)
14. [Atualizações e Tarefas](#atualizações-e-tarefas)

---

## 🎯 Visão Geral

O sistema de sincronização Hive-Firebase do **Plantis** implementa uma arquitetura **offline-first** que garante acesso instantâneo aos dados mesmo sem conexão, com sincronização automática e inteligente quando online.

### Objetivos

- ✅ **Offline-First**: Dados disponíveis instantaneamente do cache local
- ✅ **Sincronização Automática**: Background sync quando conectado
- ✅ **Conflict Resolution**: Resolução inteligente de conflitos baseada em timestamps e versões
- ✅ **Realtime Updates**: Listeners Firebase para updates em tempo real
- ✅ **Network-Aware**: Estratégias de sync adaptativas baseadas no tipo de conexão
- ✅ **Cross-Device**: Sincronização entre múltiplos dispositivos do mesmo usuário

### Stack Tecnológica

- **Hive**: `hive ^2.2.3` - Armazenamento local rápido e leve
- **Firebase Firestore**: Database cloud em tempo real
- **Firebase Auth**: Autenticação de usuários
- **Connectivity Plus**: `connectivity_plus ^8.1.2` - Monitoramento de rede
- **Dartz**: `dartz ^0.10.1` - Functional programming (Either<Failure, T>)
- **State Management**: Riverpod (em migração) + Provider (legado)

### Princípios de Design

1. **Cache-First**: Sempre servir dados do cache local primeiro
2. **Background Sync**: Sincronizar em background sem bloquear UI
3. **Optimistic Updates**: Atualizar localmente imediatamente, sync depois
4. **Conflict-Aware**: Detectar e resolver conflitos automaticamente
5. **Resilient**: Retry logic e fallbacks para erros de rede

---

## 🏗️ Arquitetura

### Diagrama de Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (UI - ConsumerWidgets, Pages, Providers/Riverpod)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  (Use Cases - GetPlants, AddPlant, UpdatePlant, etc.)      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  REPOSITORY LAYER                            │
│  (PlantsRepository, TasksRepository - Offline-First Logic)  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Network-Aware Sync Strategy Selection               │  │
│  │  • Aggressive (WiFi/Ethernet)                        │  │
│  │  • Conservative (Mobile Data)                        │  │
│  │  • Minimal (Slow Connection)                         │  │
│  │  • Disabled (Offline/Unstable)                       │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────┬─────────────────────────────┬────────────────┘
               │                             │
               ▼                             ▼
┌──────────────────────────┐  ┌──────────────────────────────┐
│   LOCAL DATASOURCE       │  │   REMOTE DATASOURCE          │
│   (Hive Boxes)           │  │   (Firebase Firestore)       │
│                          │  │                              │
│  • plants                │  │  • users/{uid}/plants        │
│  • tasks                 │  │  • users/{uid}/tasks         │
│  • spaces                │  │  • users/{uid}/spaces        │
│  • comments              │  │  • users/{uid}/comments      │
│  • settings              │  │  • users/{uid}/settings      │
└──────────────────────────┘  └──────────────────────────────┘
```

### Estrutura de Pastas

```
apps/app-plantis/
├── lib/
│   ├── features/
│   │   ├── plants/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── local/
│   │   │   │   │   │   └── plants_local_datasource.dart      # Hive operations
│   │   │   │   │   └── remote/
│   │   │   │   │       └── plants_remote_datasource.dart     # Firestore operations
│   │   │   │   ├── models/
│   │   │   │   │   └── plant_model.dart                      # JSON serialization
│   │   │   │   └── repositories/
│   │   │   │       └── plants_repository_impl.dart           # Sync orchestration
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── plant.dart                            # Domain entity
│   │   │   │   └── repositories/
│   │   │   │       └── plants_repository.dart                # Repository interface
│   │   │   └── presentation/
│   │   │       └── providers/
│   │   │           └── plants_provider.dart                  # State management
│   │   └── tasks/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── local/
│   │       │   │   │   └── tasks_local_datasource.dart       # Hive operations
│   │       │   │   └── remote/
│   │       │   │       └── tasks_remote_datasource.dart      # Firestore operations
│   │       │   └── repositories/
│   │       │       └── tasks_repository_impl.dart            # Sync orchestration
│   │       └── domain/
│   │           ├── entities/
│   │           │   └── task.dart                             # Domain entity
│   │           └── repositories/
│   │               └── tasks_repository.dart                 # Repository interface
│   └── core/
│       ├── constants/
│       │   └── plantis_environment_config.dart               # Box names constants
│       ├── data/
│       │   └── adapters/
│       │       └── network_info_adapter.dart                 # Enhanced network info
│       └── interfaces/
│           └── network_info.dart                             # Network interface
│
packages/core/
└── lib/
    └── src/
        ├── domain/
        │   ├── entities/
        │   │   └── base_sync_entity.dart                     # Base for syncable entities
        │   └── repositories/
        │       └── i_sync_repository.dart                    # Generic sync interface
        ├── infrastructure/
        │   └── services/
        │       ├── sync_firebase_service.dart                # Generic sync service
        │       └── connectivity_service.dart                 # Network monitoring
        └── sync/
            ├── interfaces/
            │   ├── i_sync_orchestrator.dart                  # Orchestrator interface
            │   └── i_sync_service.dart                       # Service interface
            └── implementations/
                └── sync_orchestrator_impl.dart               # Orchestrator implementation
```

### Componentes Principais

#### 1. **Local Datasource** (Hive)

**Responsabilidades:**
- Operações CRUD no Hive box
- Cache em memória (5 minutos) para performance
- Soft delete (flag `isDeleted`)
- Busca e filtros locais
- Tratamento de dados corrompidos

**Exemplo: PlantsLocalDatasource**
```dart
class PlantsLocalDatasourceImpl implements PlantsLocalDatasource {
  static const String _boxName = 'plants';
  List<Plant>? _cachedPlants;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  Future<List<Plant>> getPlants() async {
    // 1. Verificar cache em memória
    if (_cachedPlants != null && _isCacheValid()) {
      return _cachedPlants!;
    }

    // 2. Ler do Hive
    final hiveBox = await box;
    final plants = <Plant>[];

    for (final key in hiveBox.keys) {
      final plantJson = hiveBox.get(key) as String?;
      if (plantJson != null) {
        final plantData = jsonDecode(plantJson);
        final plant = PlantModel.fromJson(plantData);
        if (!plant.isDeleted) {
          plants.add(plant);
        }
      }
    }

    // 3. Atualizar cache
    _cachedPlants = plants;
    _cacheTimestamp = DateTime.now();

    return plants;
  }
}
```

#### 2. **Remote Datasource** (Firebase)

**Responsabilidades:**
- Operações CRUD no Firestore
- Queries filtradas por usuário
- Soft delete no Firebase
- Conversão de Timestamps

**Exemplo: TasksRemoteDataSource**
```dart
class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final FirebaseFirestore _firestore;

  String _getUserTasksPath(String userId) => 'users/$userId/tasks';

  Future<List<TaskModel>> getTasks(String userId) async {
    final querySnapshot = await _firestore
        .collection(_getUserTasksPath(userId))
        .where('is_deleted', isEqualTo: false)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromFirebaseMap({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }
}
```

#### 3. **Repository** (Orchestração)

**Responsabilidades:**
- Implementar estratégia offline-first
- Coordenar local e remote datasources
- Gerenciar sincronização em background
- Aplicar estratégias de sync baseadas na rede
- Tratar falhas e fallbacks

**Fluxo Offline-First:**
```dart
Future<Either<Failure, List<Plant>>> getPlants() async {
  try {
    // 1. SEMPRE buscar do cache primeiro (offline-first)
    final localPlants = await localDatasource.getPlants();

    // 2. Se online, sincronizar em background (não bloqueia)
    if (await networkInfo.isConnected) {
      _syncPlantsInBackground(userId);
    }

    // 3. Retornar dados locais imediatamente
    return Right(localPlants);
  } catch (e) {
    return Left(CacheFailure(e.toString()));
  }
}
```

---

## 📦 Hive Boxes Utilizados

### Box: `plants`

**Localização:** `PlantsLocalDatasourceImpl._boxName`

**Estrutura de Dados:**
```dart
{
  "id": String,                    // UUID único
  "name": String,                  // Nome da planta
  "species": String?,              // Espécie
  "space_id": String?,             // ID do espaço
  "image_url": String?,            // URL da imagem
  "notes": String?,                // Observações
  "watering_frequency": int,       // Dias entre regas
  "last_watered_at": String?,      // ISO 8601
  "created_at": String,            // ISO 8601
  "updated_at": String,            // ISO 8601
  "is_deleted": bool,              // Soft delete flag
  "is_dirty": bool                 // Pendente de sincronização
}
```

**Operações Suportadas:**
- ✅ `getPlants()` - Lista todas (exceto deletadas)
- ✅ `getPlantById(id)` - Busca por ID
- ✅ `addPlant(plant)` - Adiciona nova
- ✅ `updatePlant(plant)` - Atualiza existente
- ✅ `deletePlant(id)` - Soft delete
- ✅ `hardDeletePlant(id)` - Remove fisicamente (cleanup)
- ✅ `searchPlants(query)` - Busca por texto
- ✅ `getPlantsBySpace(spaceId)` - Filtra por espaço

**Cache em Memória:**
- Duração: 5 minutos
- Invalidação: Em toda escrita (add/update/delete)
- Objetivo: Reduzir leituras do Hive em operações frequentes

### Box: `tasks`

**Localização:** `TasksLocalDataSourceImpl._boxName = PlantisBoxes.tasks`

**Estrutura de Dados:**
```dart
{
  "id": String,                    // UUID único
  "title": String,                 // Título da tarefa
  "description": String?,          // Descrição
  "plant_id": String,              // ID da planta associada
  "type": String,                  // 'watering', 'fertilizing', 'pruning', etc.
  "status": String,                // 'pending', 'completed', 'overdue'
  "priority": String,              // 'low', 'medium', 'high'
  "due_date": String,              // ISO 8601
  "completed_at": String?,         // ISO 8601
  "completion_notes": String?,     // Observações ao completar
  "is_recurring": bool,            // Se é recorrente
  "recurring_interval_days": int?, // Intervalo de recorrência
  "next_due_date": String?,        // Próxima data (recorrentes)
  "created_at": String,            // ISO 8601
  "updated_at": String,            // ISO 8601
  "is_deleted": bool,              // Soft delete flag
  "is_dirty": bool                 // Pendente de sincronização
}
```

**Operações Suportadas:**
- ✅ `getTasks()` - Lista todas
- ✅ `getTasksByPlantId(plantId)` - Por planta
- ✅ `getTasksByStatus(status)` - Por status
- ✅ `getOverdueTasks()` - Atrasadas
- ✅ `getTodayTasks()` - Do dia
- ✅ `getUpcomingTasks()` - Próximos 7 dias
- ✅ `cacheTask(task)` - Adiciona/atualiza
- ✅ `cacheTasks(tasks)` - Batch operation
- ✅ `deleteTask(id)` - Soft delete

**Armazenamento:**
- Todas as tasks armazenadas sob chave `'all_tasks'`
- Estrutura: `List<Map<String, dynamic>>`
- Filtros aplicados em memória após leitura

### Box: `spaces` (Inferido)

**Estrutura Esperada:**
```dart
{
  "id": String,
  "name": String,
  "description": String?,
  "icon": String?,
  "color": String?,
  "created_at": String,
  "updated_at": String,
  "is_deleted": bool,
  "is_dirty": bool
}
```

### Box: `comments` (Inferido)

**Estrutura Esperada:**
```dart
{
  "id": String,
  "plant_id": String,
  "content": String,
  "created_at": String,
  "updated_at": String,
  "is_deleted": bool,
  "is_dirty": bool
}
```

### Box: `settings` (Inferido)

**Estrutura Esperada:**
```dart
{
  "theme": String,
  "notifications_enabled": bool,
  "reminder_time": String,
  "language": String,
  // ... outras configurações
}
```

---

## 🔄 Sincronização Realtime

### SyncFirebaseService<T> (Generic)

**Localização:** `packages/core/lib/src/infrastructure/services/sync_firebase_service.dart`

O `SyncFirebaseService` é um serviço **genérico** e **singleton por coleção** que implementa sincronização offline-first completa com Firebase.

#### Características Principais

**1. Singleton por Tipo + Coleção**
```dart
factory SyncFirebaseService.getInstance(
  String collectionName,
  T Function(Map<String, dynamic>) fromMap,
  Map<String, dynamic> Function(T) toMap, {
  SyncConfig? config,
}) {
  final key = '${T.toString()}_$collectionName';
  if (!_instances.containsKey(key)) {
    _instances[key] = SyncFirebaseService<T>._(/* ... */);
  }
  return _instances[key];
}
```

**2. Três Listeners em Tempo Real**

```dart
// A. Connectivity Listener
_connectivitySubscription = _connectivity.connectivityStream.listen(
  (isOnline) {
    _updateSyncStatus();
    if (isOnline && _currentUserId != null) {
      _syncUnsyncedItemsInBackground();
    }
  }
);

// B. Auth Listener
_authSubscription = _auth.authStateChanges().listen(
  (user) {
    _currentUserId = user?.uid;
    if (_currentUserId != null) {
      _setupFirestoreListener();
      _syncUnsyncedItemsInBackground();
    } else {
      _removeFirestoreListener();
    }
  }
);

// C. Firestore Listener (Realtime)
_firestoreSubscription = _firestore
    .collection('users')
    .doc(_currentUserId)
    .collection(collectionName)
    .snapshots()
    .listen(_handleFirestoreSnapshot);
```

**3. Processamento de Snapshots Realtime**

```dart
void _handleFirestoreSnapshot(QuerySnapshot snapshot) async {
  for (final change in snapshot.docChanges) {
    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        final remoteItem = fromMap(change.doc.data());
        await _mergeRemoteItem(remoteItem);
        break;
      case DocumentChangeType.removed:
        await _handleRemoteDelete(change.doc.id);
        break;
    }
  }
  await _refreshLocalData();
}
```

**4. Merge com Conflict Resolution**

```dart
Future<void> _mergeRemoteItem(T remoteItem) async {
  final localItem = await _getLocal(remoteItem.id);

  if (localItem != null) {
    // Conflict detection
    if (localItem.version > remoteItem.version) {
      // Local wins - don't overwrite
      if (!localItem.isDirty) {
        itemToSave = localItem.markAsSynced();
      } else {
        return; // Keep local dirty version
      }
    } else if (localItem.version == remoteItem.version && localItem.isDirty) {
      // Same version but local has pending changes
      return; // Keep local dirty version
    } else {
      // Remote wins
      itemToSave = remoteItem.markAsSynced();
    }
  } else {
    // New item from remote
    itemToSave = remoteItem.markAsSynced();
  }

  await _saveLocal(itemToSave);
}
```

### Streams Disponíveis

**1. Data Stream**
```dart
Stream<List<T>> get dataStream => _dataController.stream;

// Uso:
syncService.dataStream.listen((plants) {
  // UI atualiza automaticamente com novos dados
  setState(() => _plants = plants);
});
```

**2. Sync Status Stream**
```dart
Stream<SyncStatus> get syncStatusStream => _statusController.stream;

// Estados possíveis:
enum SyncStatus {
  offline,      // Sem conectividade
  localOnly,    // Online mas não autenticado
  syncing,      // Sincronizando
  synced,       // Sincronizado
  error,        // Erro
  conflict,     // Conflito detectado
}
```

**3. Connectivity Stream**
```dart
Stream<bool> get connectivityStream => _connectivity.connectivityStream;
```

### Auto-Sync Periódico

```dart
void _setupAutoSync() {
  if (config.syncInterval.inSeconds > 0) {
    _syncTimer = Timer.periodic(config.syncInterval, (timer) {
      if (_canSync()) {
        _syncUnsyncedItemsInBackground();
      }
    });
  }
}
```

**Configuração Padrão:**
```dart
const SyncConfig({
  syncInterval: Duration(minutes: 5),  // Auto-sync a cada 5 minutos
  batchSize: 50,                       // 50 itens por batch
  maxRetries: 3,                       // 3 tentativas
  retryDelay: Duration(seconds: 30),   // 30s entre tentativas
  enableRealtimeSync: true,            // Listeners ativos
  enableOfflineMode: true,             // Funciona offline
  conflictResolution: ConflictResolutionStrategy.timestamp,
});
```

---

## ⚡ Estratégias de Sync

O sistema implementa **estratégias adaptativas** baseadas no tipo e qualidade da conexão de rede.

### Enum: SyncStrategy

```dart
enum SyncStrategy {
  aggressive,    // WiFi/Ethernet - sync completo
  conservative,  // Mobile data - sync reduzido
  minimal,       // Conexão lenta - só crítico
  disabled,      // Offline/instável - skip
}
```

### Determinação da Estratégia

**Localização:** `TasksRepositoryImpl._determineSyncStrategy()`

```dart
Future<SyncStrategy> _determineSyncStrategy() async {
  final enhanced = networkInfo.asEnhanced;
  if (enhanced == null) {
    return SyncStrategy.conservative; // Fallback
  }

  // 1. Verificar estabilidade
  final isStable = await enhanced.isStable;
  if (!isStable) {
    return SyncStrategy.disabled;
  }

  // 2. Verificar tipo de conexão
  final connectionType = await enhanced.connectionType;
  switch (connectionType) {
    case ConnectivityType.wifi:
    case ConnectivityType.ethernet:
      return SyncStrategy.aggressive;      // Melhor performance
    case ConnectivityType.mobile:
      return SyncStrategy.conservative;    // Economizar dados
    case ConnectivityType.bluetooth:
    case ConnectivityType.vpn:
      return SyncStrategy.minimal;         // Conexões lentas
    case ConnectivityType.none:
    case ConnectivityType.offline:
      return SyncStrategy.disabled;        // Sem conexão
    default:
      return SyncStrategy.conservative;    // Fallback seguro
  }
}
```

### Implementação das Estratégias

#### 1. Aggressive Sync (WiFi/Ethernet)

**Características:**
- Sincronização completa e imediata
- Sem throttling
- Logging de performance

```dart
void _performAggressiveSync(String userId) async {
  final stopwatch = Stopwatch()..start();

  final remoteTasks = await remoteDataSource.getTasks(userId);
  await localDataSource.cacheTasks(remoteTasks);

  stopwatch.stop();
  if (kDebugMode) {
    print('✅ Aggressive sync: ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

**Métricas Típicas:**
- Latência: 200-500ms
- Throughput: Máximo possível
- Retry: Imediato

#### 2. Conservative Sync (Mobile Data)

**Características:**
- Timeout de 10 segundos
- Batches menores
- Throttling aplicado

```dart
void _performConservativeSync(String userId) async {
  final remoteTasks = await remoteDataSource
      .getTasks(userId)
      .timeout(const Duration(seconds: 10));

  await localDataSource.cacheTasks(remoteTasks);

  if (kDebugMode) {
    print('✅ Conservative sync completed');
  }
}
```

**Métricas Típicas:**
- Latência: 1-3s
- Throughput: Reduzido 50%
- Retry: Delay progressivo

#### 3. Minimal Sync (Slow Connection)

**Características:**
- Apenas dados críticos
- Skip de sync completo
- Prioridade para UX

```dart
void _performMinimalSync(String userId) async {
  if (kDebugMode) {
    print('⏸️ Minimal sync - skipping for better UX');
  }
  // Não sincroniza - UX prioritária
}
```

**Comportamento:**
- Sync desabilitado temporariamente
- Mantém dados locais
- Evita travamentos

#### 4. Disabled (Offline/Unstable)

**Características:**
- Nenhuma tentativa de sync
- Modo 100% offline

```dart
if (syncStrategy == SyncStrategy.disabled) {
  if (kDebugMode) {
    print('🚫 Sync skipped - poor connection');
  }
  return;
}
```

### Network-Aware Sync Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                      User Action                             │
│              (getPlants, addPlant, etc.)                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              1. Serve from Local Cache                       │
│                 (Instant Response)                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Check Connectivity  │
              └──────────┬───────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
  ┌───────────────┐          ┌──────────────────┐
  │    OFFLINE    │          │      ONLINE      │
  └───────────────┘          └────────┬─────────┘
          │                           │
          │                           ▼
          │              ┌────────────────────────┐
          │              │ Determine SyncStrategy │
          │              └────────┬───────────────┘
          │                       │
          │         ┌─────────────┼─────────────┬────────────┐
          │         │             │             │            │
          │         ▼             ▼             ▼            ▼
          │   ┌──────────┐ ┌──────────┐ ┌────────┐ ┌─────────┐
          │   │Aggressive│ │Conserv.  │ │Minimal │ │Disabled │
          │   └─────┬────┘ └────┬─────┘ └───┬────┘ └────┬────┘
          │         │           │            │           │
          │         ▼           ▼            ▼           ▼
          │   ┌─────────────────────────────────────────────┐
          │   │   Background Sync (Non-blocking)            │
          │   │   • Pull from Firebase                      │
          │   │   • Push dirty items                        │
          │   │   • Merge conflicts                         │
          │   │   • Update local cache                      │
          │   └─────────────────────────────────────────────┘
          │                       │
          └───────────────────────┴───────────────────────────┐
                                                              │
                                                              ▼
                                              ┌───────────────────────────┐
                                              │  Data Available in Cache  │
                                              │    (Always Accessible)    │
                                              └───────────────────────────┘
```

---

## 🔀 Conflict Resolution

### Estratégias Implementadas

**Enum: ConflictResolutionStrategy**
```dart
enum ConflictResolutionStrategy {
  timestamp,    // Mais recente ganha (padrão)
  version,      // Maior versão ganha
  localWins,    // Priorizar local sempre
  remoteWins,   // Priorizar remote sempre
  manual,       // Resolução manual pelo usuário
}
```

### Implementação Atual (Timestamp-based)

**Localização:** `SyncFirebaseService._mergeRemoteItem()`

#### Algoritmo de Merge

```dart
Future<void> _mergeRemoteItem(T remoteItem) async {
  final localResult = await _getLocal(remoteItem.id);

  localResult.fold(
    (failure) => {/* Log error */},
    (localItem) async {
      T itemToSave = remoteItem;

      if (localItem != null) {
        // Regra 1: Versão maior ganha
        if (localItem.version > remoteItem.version) {
          if (!localItem.isDirty) {
            itemToSave = localItem.markAsSynced();
          } else {
            return; // Keep dirty local version
          }
        }
        // Regra 2: Mesma versão + isDirty = keep local
        else if (localItem.version == remoteItem.version &&
                 localItem.isDirty) {
          return; // Keep local pending changes
        }
        // Regra 3: Remote mais novo = usar remote
        else {
          itemToSave = remoteItem.markAsSynced();
        }
      } else {
        // Novo item do remote
        itemToSave = remoteItem.markAsSynced();
      }

      await _saveLocal(itemToSave);
    }
  );
}
```

### Campos de Controle de Conflito

**BaseSyncEntity** (todos os models estendem)
```dart
abstract class BaseSyncEntity {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncAt;     // Última sincronização
  final int version;              // Versão incremental
  final bool isDirty;             // Mudanças pendentes
  final bool isDeleted;           // Soft delete
  final String userId;            // Dono dos dados
  final String moduleName;        // Nome do módulo

  // Computed
  bool get needsSync => isDirty && !isDeleted;

  // Methods
  T markAsDirty();
  T markAsSynced({DateTime? syncTime});
  T markAsDeleted();
  T incrementVersion();
}
```

### Cenários de Conflito

#### Cenário 1: Edit Simultâneo (Mesmo Registro, Diferentes Devices)

**Situação:**
- Device A: Edita planta às 10:00, versão 5
- Device B: Edita mesma planta às 10:05, versão 5

**Resolução:**
```
1. Device B sincroniza primeiro (10:05) → Firebase versão 6
2. Device A tenta sincronizar (10:10)
   - Pull do Firebase: versão 6 (mais nova)
   - Local: versão 5 + isDirty
   - Conflito detectado!
3. Aplicar estratégia:
   - Timestamp: updatedAt mais recente ganha
   - Resultado: Versão do Device B prevalece
   - Device A: Mostra aviso ao usuário
```

#### Cenário 2: Create + Delete Race Condition

**Situação:**
- Device A: Cria planta offline
- Device B: Deleta mesma planta (soft delete)

**Resolução:**
```
1. Device A cria localmente (isDirty=true, isDeleted=false)
2. Device B marca como deletada no Firebase
3. Device A sincroniza:
   - Pull do Firebase: isDeleted=true
   - Local: isDeleted=false + isDirty
   - Conflito!
4. Estratégia: Última ação ganha
   - Se updatedAt do delete > create → Delete prevalece
   - Planta removida do Device A
```

#### Cenário 3: Offline Extended Period

**Situação:**
- Device offline por 2 dias
- Múltiplas edições locais
- Firebase atualizado por outros devices

**Resolução:**
```
1. Device reconecta
2. Batch sync iniciado:
   - Pull todas as mudanças do Firebase
   - Para cada item remoto:
     a. Comparar versão + timestamp
     b. Se local.isDirty && local.updatedAt > remote.updatedAt
        → Keep local, push para Firebase
     c. Caso contrário
        → Aceitar remote, overwrite local
   - Push itens locais não sincronizados
```

### Prevenção de Conflitos

**1. Versionamento Incremental**
```dart
T incrementVersion() {
  return copyWith(version: version + 1);
}
```

**2. isDirty Flag**
```dart
T markAsDirty() {
  return copyWith(
    isDirty: true,
    updatedAt: DateTime.now(),
  );
}
```

**3. Sync Timestamps**
```dart
T markAsSynced({DateTime? syncTime}) {
  return copyWith(
    isDirty: false,
    lastSyncAt: syncTime ?? DateTime.now(),
  );
}
```

### Conflitos Não Resolvidos (Gaps)

**Situações problemáticas:**

❌ **Conflito de Schema**
- Local: PlantModel com campo `wateringFrequency`
- Remote: PlantModel sem esse campo (versão antiga do app)
- **Solução necessária:** Schema migration service

❌ **Conflito de Referência**
- Planta deletada, mas tasks associadas não
- Orphan records
- **Solução necessária:** Cascade delete logic

❌ **Conflito de Batch**
- Multiple devices editam lote de itens simultaneamente
- **Solução necessária:** Optimistic locking

---

## 🎛️ SyncCoordinatorService

**Status:** ⚠️ **Parcialmente Implementado**

**Localização:** `packages/core/lib/src/services/sync_coordinator_service.dart`

### Objetivo

Coordenar múltiplos serviços de sincronização, gerenciar filas, retry logic e priorização.

### Arquitetura Proposta

```dart
class SyncCoordinatorService {
  final ISyncOrchestrator _orchestrator;
  final Queue<SyncOperation> _operationQueue;
  final Map<String, RetryConfig> _retryConfigs;

  // Priority queue para operações críticas
  Future<void> enqueueSync(SyncOperation operation, {
    SyncPriority priority = SyncPriority.normal,
  }) async {
    // 1. Adicionar à fila
    _operationQueue.add(operation);

    // 2. Processar baseado em prioridade
    await _processQueue();
  }

  // Retry exponencial com backoff
  Future<void> _retryOperation(
    SyncOperation operation,
    int attemptNumber,
  ) async {
    final delay = _calculateExponentialBackoff(attemptNumber);
    await Future.delayed(delay);
    await _executeOperation(operation);
  }
}
```

### Estado Atual

**Implementado:**
- ✅ `SyncOrchestratorImpl` - Orquestração básica
- ✅ `ISyncOrchestrator` - Interface definida
- ✅ `ISyncService` - Interface de serviços
- ✅ Registro de múltiplos serviços
- ✅ `syncAll()` e `syncSpecific()`
- ✅ Streams de progresso e eventos

**Não Implementado:**
- ❌ Fila de priorização
- ❌ Retry exponencial configur��vel
- ❌ Throttling de operações
- ❌ Circuit breaker para falhas
- ❌ Metrics e observabilidade
- ❌ Batch optimization

### Interface ISyncOrchestrator

```dart
abstract class ISyncOrchestrator {
  // Registro de serviços
  Future<void> registerService(ISyncService service);
  Future<void> unregisterService(String serviceId);

  // Sincronização
  Future<Either<Failure, void>> syncAll();
  Future<Either<Failure, void>> syncSpecific(String serviceId);

  // Status
  List<String> get registeredServices;
  bool isServiceRegistered(String serviceId);
  SyncServiceStatus getServiceStatus(String serviceId);
  GlobalSyncStatus get globalStatus;

  // Streams
  Stream<SyncProgress> get progressStream;
  Stream<SyncEvent> get eventStream;

  // Controle
  Future<void> stopAllSync();
  Future<Either<Failure, void>> clearAllData();
  Future<void> dispose();
}
```

### Exemplo de Uso

```dart
// Setup
final orchestrator = SyncOrchestratorImpl(
  cacheManager: cacheManager,
  networkMonitor: networkMonitor,
);

// Registrar serviços
await orchestrator.registerService(plantsSyncService);
await orchestrator.registerService(tasksSyncService);
await orchestrator.registerService(spacesSyncService);

// Sincronizar todos
final result = await orchestrator.syncAll();
result.fold(
  (failure) => print('Sync failed: ${failure.message}'),
  (_) => print('All synced!'),
);

// Monitorar progresso
orchestrator.progressStream.listen((progress) {
  print('${progress.serviceId}: ${progress.percentage}%');
});

// Monitorar eventos
orchestrator.eventStream.listen((event) {
  switch (event.type) {
    case SyncEventType.started:
      print('${event.serviceId} started');
      break;
    case SyncEventType.completed:
      print('${event.serviceId} completed');
      break;
    case SyncEventType.failed:
      print('${event.serviceId} failed: ${event.message}');
      break;
  }
});
```

---

## 📱 Offline-First Strategy

### Princípios

**1. Cache-First, Network-Later**
```dart
// SEMPRE buscar do cache primeiro
final localData = await localDatasource.getData();

// Sincronizar em background (não bloqueia)
if (await networkInfo.isConnected) {
  _syncInBackground();
}

// Retornar dados locais imediatamente
return Right(localData);
```

**2. Optimistic Updates**
```dart
// Atualizar local imediatamente
await localDatasource.updatePlant(plant);

// UI reflete mudança instantaneamente
emit(state.copyWith(plants: updatedPlants));

// Sincronizar com Firebase em background
if (await networkInfo.isConnected) {
  _syncToFirebase(plant);
} else {
  // Marcar como dirty para sync posterior
  await localDatasource.updatePlant(plant.markAsDirty());
}
```

**3. Graceful Degradation**
```dart
try {
  // Tentar operação remota
  final remotePlant = await remoteDatasource.addPlant(plant, userId);
  await localDatasource.updatePlant(remotePlant);
  return Right(remotePlant);
} catch (e) {
  // Falhou? Não tem problema, dados estão locais
  debugPrint('Remote save failed, keeping local: $e');
  return Right(plant);
}
```

**4. Background Sync**
```dart
void _syncPlantsInBackground(String userId) {
  // Não bloqueia UI
  remoteDatasource.getPlants(userId)
    .then((remotePlants) {
      for (final plant in remotePlants) {
        localDatasource.updatePlant(plant);
      }
    })
    .catchError((e) {
      debugPrint('Background sync failed: $e');
      // Não propaga erro para UI
    });
}
```

### Cache em Memória (Performance Optimization)

**Implementação:**
```dart
class PlantsLocalDatasourceImpl {
  List<Plant>? _cachedPlants;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  Future<List<Plant>> getPlants() async {
    // 1. Verificar cache em memória
    if (_cachedPlants != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheValidity) {
        return _cachedPlants!;  // Cache hit - instantâneo
      }
    }

    // 2. Cache miss - ler do Hive
    final plants = await _readFromHive();

    // 3. Atualizar cache
    _cachedPlants = plants;
    _cacheTimestamp = DateTime.now();

    return plants;
  }

  void _invalidateCache() {
    _cachedPlants = null;
    _cacheTimestamp = null;
  }
}
```

**Métricas:**
- Cache hit: ~0-1ms (leitura de memória)
- Cache miss: ~10-50ms (leitura do Hive)
- Firebase fetch: ~500-2000ms (network)

### Dirty Flag Pattern

**Propósito:** Rastrear quais itens precisam ser sincronizados

```dart
// Ao criar/editar offline
Future<void> addPlant(Plant plant) async {
  final plantModel = PlantModel.fromEntity(plant);

  // Salvar localmente com isDirty=true
  await localDatasource.addPlant(plantModel.markAsDirty());

  // Tentar sync se online
  if (await networkInfo.isConnected) {
    try {
      await remoteDatasource.addPlant(plantModel, userId);
      // Sucesso: remover dirty flag
      await localDatasource.updatePlant(plantModel.markAsSynced());
    } catch (e) {
      // Falhou: manter dirty flag para retry
    }
  }
}

// Ao reconectar
void _onConnectivityRestored() async {
  // Buscar todos os itens dirty
  final dirtyPlants = await localDatasource
      .getPlants()
      .then((plants) => plants.where((p) => p.isDirty));

  // Sincronizar em batch
  for (final plant in dirtyPlants) {
    try {
      await remoteDatasource.updatePlant(plant, userId);
      await localDatasource.updatePlant(plant.markAsSynced());
    } catch (e) {
      // Falhou: tentar depois
    }
  }
}
```

### Soft Delete Pattern

**Propósito:** Permitir recovery e sincronização de deletes

```dart
// Delete local (soft delete)
Future<void> deletePlant(String id) async {
  // 1. Buscar planta
  final plant = await localDatasource.getPlantById(id);

  // 2. Marcar como deletada (soft delete)
  final deletedPlant = plant.copyWith(
    isDeleted: true,
    isDirty: true,  // Precisa sincronizar delete
    updatedAt: DateTime.now(),
  );

  // 3. Atualizar localmente
  await localDatasource.updatePlant(deletedPlant);

  // 4. Sincronizar delete se online
  if (await networkInfo.isConnected) {
    try {
      await remoteDatasource.deletePlant(id, userId);
      // Opcional: hard delete local após sync
      await localDatasource.hardDeletePlant(id);
    } catch (e) {
      // Falhou: manter soft delete para retry
    }
  }
}

// Filtrar deletados em queries
Future<List<Plant>> getPlants() async {
  final allPlants = await _readFromHive();
  return allPlants.where((p) => !p.isDeleted).toList();
}
```

### Cache Invalidation

**Estratégias:**

**1. Time-Based (TTL)**
```dart
static const Duration _cacheValidity = Duration(minutes: 5);

if (DateTime.now().difference(_cacheTimestamp!) > _cacheValidity) {
  _invalidateCache();
}
```

**2. Write-Through**
```dart
Future<void> addPlant(Plant plant) async {
  await hiveBox.put(plant.id, plant.toJson());
  _invalidateCache();  // Cache inválido após escrita
}
```

**3. Manual**
```dart
Future<void> clearCache() async {
  await hiveBox.clear();
  _invalidateCache();
  _searchService.clearCache();
}
```

---

## 🔄 Fluxos de Sincronização

### Fluxo 1: Read (getPlants)

```
User Action: Abrir lista de plantas
         │
         ▼
┌────────────────────────────────────────┐
│  1. Repository.getPlants()             │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. LocalDatasource.getPlants()        │
│     ├─ Verificar cache em memória      │
│     │  └─ Se válido: retornar (0-1ms)  │
│     └─ Se inválido:                    │
│        ├─ Ler do Hive (10-50ms)        │
│        └─ Atualizar cache              │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  3. Retornar dados imediatamente       │
│     (UI atualiza - offline-first)      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. Verificar conectividade            │
└────────┬───────────────────────────────┘
         │
   ┌─────┴─────┐
   │           │
   ▼           ▼
┌──────┐   ┌────────────────────────────┐
│OFFL. │   │ ONLINE                     │
└──────┘   │ 5. _syncPlantsInBackground()│
           │    (não bloqueia UI)        │
           └─────────┬──────────────────┘
                     │
                     ▼
           ┌─────────────────────────────┐
           │ 6. RemoteDatasource.get()   │
           │    └─ Firebase query        │
           │       (500-2000ms)          │
           └─────────┬───────────────────┘
                     │
                     ▼
           ┌─────────────────────────────┐
           │ 7. LocalDatasource.update() │
           │    └─ Atualizar Hive        │
           │    └─ Invalidar cache       │
           └─────────┬───────────────────┘
                     │
                     ▼
           ┌─────────────────────────────┐
           │ 8. UI atualiza               │
           │    automaticamente           │
           │    (via stream/provider)     │
           └──────────────────────────────┘
```

**Latências:**
- UI inicial: 0-50ms (cache)
- Background sync: 500-2000ms (Firebase)
- UI update: Automático (stream)

### Fluxo 2: Create (addPlant) - Online

```
User Action: Adicionar nova planta
         │
         ▼
┌────────────────────────────────────────┐
│  1. Repository.addPlant(plant)         │
│     └─ plant.id gerado localmente      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. LocalDatasource.addPlant()         │
│     ├─ Salvar no Hive                  │
│     │  └─ JSON serialization           │
│     └─ Invalidar cache                 │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  3. UI atualiza imediatamente          │
│     (optimistic update)                │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. Verificar conectividade            │
└────────┬───────────────────────────────┘
         │
         ▼  (Online)
┌────────────────────────────────────────┐
│  5. RemoteDatasource.addPlant()        │
│     ├─ Firebase.add()                  │
│     └─ Retorna plant com ID remoto     │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  6. Verificar IDs                      │
│     ├─ Se local.id == remote.id        │
│     │  └─ Atualizar Hive (isDirty=false)│
│     └─ Se local.id != remote.id        │
│        ├─ Salvar remote.id             │
│        └─ Hard delete local.id         │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  7. Retornar planta sincronizada       │
└────────────────────────────────────────┘
```

**Transição de ID:**
```dart
// Situação: Firebase gera ID diferente do local
if (plantModel.id != remotePlant.id) {
  // 1. Salvar versão remota
  await localDatasource.updatePlant(remotePlant);

  // 2. Remover versão local antiga
  await localDatasource.hardDeletePlant(plantModel.id);

  // Resultado: Apenas 1 registro no Hive (ID correto)
}
```

### Fluxo 3: Create (addPlant) - Offline

```
User Action: Adicionar planta (sem internet)
         │
         ▼
┌────────────────────────────────────────┐
│  1. Repository.addPlant(plant)         │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. LocalDatasource.addPlant()         │
│     ├─ Salvar com isDirty=true         │
│     └─ ID local temporário             │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  3. UI atualiza imediatamente          │
│     (planta aparece na lista)          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. Verificar conectividade            │
│     └─ OFFLINE                         │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  5. Retornar planta local              │
│     (isDirty=true, aguardando sync)    │
└────────────────────────────────────────┘
         │
         ▼
      [Aguarda]
         │
         ▼  (Conectividade restaurada)
┌────────────────────────────────────────┐
│  6. Connectivity Listener triggered    │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  7. _syncPlantsInBackground()          │
│     ├─ Buscar itens isDirty=true       │
│     └─ Para cada item:                 │
│        ├─ RemoteDatasource.add()       │
│        └─ Atualizar local (isDirty=false)│
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  8. Planta sincronizada                │
└────────────────────────────────────────┘
```

### Fluxo 4: Update (updatePlant) - Com Conflict

```
User Action: Editar planta
         │
         ▼
┌────────────────────────────────────────┐
│  1. Repository.updatePlant(plant)      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. LocalDatasource.updatePlant()      │
│     ├─ plant.version++                 │
│     ├─ plant.isDirty = true            │
│     └─ plant.updatedAt = now()         │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  3. UI atualiza imediatamente          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. RemoteDatasource.updatePlant()     │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  5. Firestore retorna versão atualizada│
│     por outro device                   │
│     (conflict detected!)               │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  6. Conflict Resolution                │
│     ├─ Comparar timestamps             │
│     │  └─ local.updatedAt vs remote    │
│     ├─ Comparar versões                │
│     │  └─ local.version vs remote      │
│     └─ Aplicar estratégia              │
│        (timestamp padrão)              │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  7. Merge resultado                    │
│     ├─ Se local wins:                  │
│     │  └─ Push para Firebase           │
│     └─ Se remote wins:                 │
│        └─ Atualizar local              │
│           (UI pode mostrar aviso)      │
└────────────────────────────────────────┘
```

### Fluxo 5: Delete (deletePlant) - Cascade

```
User Action: Deletar planta
         │
         ▼
┌────────────────────────────────────────┐
│  1. Repository.deletePlant(plantId)    │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. Cascade deletes (IMPORTANTE!)      │
│     ├─ TaskRepository.deleteTasks()    │
│     │  └─ Soft delete de todas tasks   │
│     └─ CommentsRepository.delete()     │
│        └─ Soft delete de comentários   │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  3. LocalDatasource.deletePlant()      │
│     ├─ Soft delete (isDeleted=true)    │
│     └─ isDirty=true para sync          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. UI atualiza (remove da lista)      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  5. RemoteDatasource.deletePlant()     │
│     └─ Firebase: isDeleted=true        │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  6. (Opcional) Hard delete local       │
│     └─ Após confirmação do Firebase    │
└────────────────────────────────────────┘
```

### Fluxo 6: Realtime Listener (Firebase Snapshot)

```
Firebase: Mudança detectada
         │
         ▼
┌────────────────────────────────────────┐
│  1. Firestore snapshot triggered       │
│     └─ docChanges: [added, modified,  │
│                      removed]          │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  2. _handleFirestoreSnapshot()         │
│     └─ Para cada change:               │
└────────┬───────────────────────────────┘
         │
         ├─────────────┬─────────────────┬────────────────┐
         ▼             ▼                 ▼                │
    ┌─────────┐  ┌──────────┐     ┌──────────┐          │
    │ ADDED   │  │ MODIFIED │     │ REMOVED  │          │
    └────┬────┘  └─────┬────┘     └─────┬────┘          │
         │             │                 │               │
         ▼             ▼                 ▼               │
┌────────────────────────────────────────────────────────┤
│  3. _mergeRemoteItem() / _handleRemoteDelete()        │
│     ├─ Buscar item local                              │
│     ├─ Conflict detection                             │
│     │  ├─ Comparar versions                           │
│     │  └─ Comparar isDirty flag                       │
│     └─ Aplicar merge strategy                         │
└────────┬──────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  4. _saveLocal() / delete()            │
│     └─ Atualizar Hive                  │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  5. _refreshLocalData()                │
│     └─ Invalidar cache                 │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  6. dataStream.add(updatedData)        │
│     └─ UI atualiza automaticamente     │
└────────────────────────────────────────┘
```

---

## ✅ Estado da Implementação

### Funcionalidades 100% Implementadas

#### ✅ 1. Offline-First Architecture

**Status:** ✅ Completo
**Localização:** Todos os repositories

- [x] Cache-first reads
- [x] Optimistic updates
- [x] Background sync
- [x] Graceful degradation
- [x] Dirty flag pattern
- [x] Soft delete pattern

#### ✅ 2. Local Datasource (Hive)

**Status:** ✅ Completo
**Localização:** `features/*/data/datasources/local/`

**Plants:**
- [x] CRUD completo
- [x] Cache em memória (5min)
- [x] Busca e filtros
- [x] Tratamento de dados corrompidos
- [x] Hard delete (cleanup)

**Tasks:**
- [x] CRUD completo
- [x] Filtros por status/planta/data
- [x] Batch operations
- [x] Soft delete

#### ✅ 3. Remote Datasource (Firebase)

**Status:** ✅ Completo
**Localização:** `features/*/data/datasources/remote/`

**Plants:**
- [x] CRUD completo
- [x] Queries por usuário
- [x] Busca
- [x] Filtros por espaço
- [x] Batch sync

**Tasks:**
- [x] CRUD completo
- [x] Filtros avançados
- [x] Queries otimizadas

#### ✅ 4. Network-Aware Sync Strategies

**Status:** ✅ Completo (Tasks)
**Localização:** `features/tasks/data/repositories/tasks_repository_impl.dart`

- [x] Aggressive (WiFi/Ethernet)
- [x] Conservative (Mobile data)
- [x] Minimal (Slow connection)
- [x] Disabled (Offline)
- [x] Auto-detection baseada em `connectivity_plus`

#### ✅ 5. Connectivity Monitoring

**Status:** ✅ Completo
**Localização:** `PlantsRepositoryImpl._initializeConnectivityMonitoring()`

- [x] Real-time connectivity stream
- [x] Auto-sync ao reconectar
- [x] Logging de eventos
- [x] Enhanced network info adapter

#### ✅ 6. Repository Pattern

**Status:** ✅ Completo
**Localização:** `features/*/data/repositories/*_repository_impl.dart`

- [x] Interface + implementação
- [x] Either<Failure, T> pattern (dartz)
- [x] Retry logic
- [x] Error handling
- [x] User authentication integration

### Funcionalidades Parcialmente Implementadas

#### ⚠️ 7. SyncFirebaseService (Generic)

**Status:** ⚠️ 85% Implementado
**Localização:** `packages/core/lib/src/infrastructure/services/sync_firebase_service.dart`

**Implementado:**
- [x] Singleton por coleção
- [x] CRUD completo
- [x] Realtime listeners
- [x] Conflict resolution (timestamp)
- [x] Auto-sync periódico
- [x] Batch operations
- [x] Streams (data, status, connectivity)

**Pendências:**
- [ ] Integração completa com app-plantis
- [ ] Testes unitários
- [ ] Conflict resolution manual UI
- [ ] Métricas e observabilidade

#### ⚠️ 8. Sync Orchestrator

**Status:** ⚠️ 60% Implementado
**Localização:** `packages/core/lib/src/sync/implementations/sync_orchestrator_impl.dart`

**Implementado:**
- [x] Interface definida
- [x] Registro de serviços
- [x] syncAll() e syncSpecific()
- [x] Streams de progresso/eventos
- [x] Network listener

**Pendências:**
- [ ] Priority queue
- [ ] Exponential backoff retry
- [ ] Circuit breaker
- [ ] Throttling
- [ ] Observabilidade

#### ⚠️ 9. Conflict Resolution

**Status:** ⚠️ 70% Implementado
**Localização:** `SyncFirebaseService._mergeRemoteItem()`

**Implementado:**
- [x] Timestamp-based (padrão)
- [x] Version-based
- [x] isDirty flag checking

**Pendências:**
- [ ] localWins strategy
- [ ] remoteWins strategy
- [ ] Manual resolution UI
- [ ] Conflict notification
- [ ] Conflict history

### Funcionalidades Não Implementadas

#### ❌ 10. Cascade Delete Logic

**Status:** ❌ Não implementado
**Problema:**
- Ao deletar planta, tasks órfãs permanecem
- Comentários não são removidos automaticamente
- Risk de orphan records

**Solução Necessária:**
```dart
Future<void> deletePlant(String plantId) async {
  // 1. Delete cascade - tasks
  await _taskRepository.deleteTasksByPlantId(plantId);

  // 2. Delete cascade - comments
  await _commentRepository.deleteCommentsByPlantId(plantId);

  // 3. Delete plant
  await _plantsRepository.deletePlant(plantId);
}
```

#### ❌ 11. Schema Migration

**Status:** ❌ Não implementado
**Problema:**
- Mudanças no schema do model não têm migration
- Dados antigos no Hive podem causar crashes
- Sem versionamento de schema

**Solução Necessária:**
```dart
class SchemaMigration {
  static Future<void> migrateFrom(int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Migração v1 → v2: adicionar campo 'wateringFrequency'
      await _migrateV1ToV2();
    }
    // ... outras migrações
  }
}
```

#### ❌ 12. Batch Sync Optimization

**Status:** ❌ Não implementado
**Problema:**
- Sync de múltiplos itens é feito 1 por 1
- Sem batching eficiente
- Performance ruim com muitos itens

**Solução Necessária:**
```dart
Future<void> _syncBatchOptimized(List<Plant> plants) async {
  const batchSize = 50;
  for (int i = 0; i < plants.length; i += batchSize) {
    final batch = plants.skip(i).take(batchSize).toList();
    await _remoteDatasource.batchSync(batch);
  }
}
```

#### ❌ 13. Sync Metrics e Observabilidade

**Status:** ❌ Não implementado
**Problema:**
- Sem métricas de performance
- Difícil debugar problemas de sync
- Sem dashboards de monitoring

**Solução Necessária:**
```dart
class SyncMetrics {
  final int itemsSynced;
  final Duration syncDuration;
  final int conflictsResolved;
  final int errorsCount;
  final NetworkQuality networkQuality;

  void logToFirebaseAnalytics() {
    FirebaseAnalytics.instance.logEvent(
      name: 'sync_completed',
      parameters: toMap(),
    );
  }
}
```

#### ❌ 14. Retry Queue Persistence

**Status:** ❌ Não implementado
**Problema:**
- Retry queue é em memória
- Se app crashar, operações pendentes são perdidas

**Solução Necessária:**
```dart
class PersistentRetryQueue {
  Future<void> enqueue(SyncOperation operation) async {
    await _hive.put('retry_queue', operation.toJson());
  }

  Future<List<SyncOperation>> getAll() async {
    return await _hive.get('retry_queue');
  }
}
```

---

## ❗ Gaps e Pendências

### Crítico (Implementar Urgente)

#### 🔴 1. Cascade Delete Logic

**Problema:**
Ao deletar planta, entidades relacionadas (tasks, comments) ficam órfãs.

**Impacto:**
- Orphan records no Firebase e Hive
- Inconsistência de dados
- Waste de storage

**Solução:**
```dart
// Em PlantsRepository
Future<Either<Failure, void>> deletePlant(String id) async {
  try {
    // 1. Delete tasks
    final tasksResult = await taskRepository.deleteTasksByPlantId(id);
    if (tasksResult.isLeft()) {
      return tasksResult; // Propagar erro
    }

    // 2. Delete comments
    final commentsResult = await commentsRepository.deleteCommentsByPlantId(id);
    if (commentsResult.isLeft()) {
      return commentsResult;
    }

    // 3. Delete plant
    await localDatasource.deletePlant(id);
    if (await networkInfo.isConnected) {
      await remoteDatasource.deletePlant(id, userId);
    }

    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

**Prioridade:** 🔴 CRÍTICA
**Estimativa:** 2-4 horas

#### 🔴 2. Error Recovery UI

**Problema:**
Quando sync falha, usuário não tem feedback nem opção de retry manual.

**Impacto:**
- Dados podem ficar dessincronizados indefinidamente
- UX ruim

**Solução:**
```dart
// Widget de status de sync
class SyncStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.synced;

        switch (status) {
          case SyncStatus.error:
            return Card(
              color: Colors.red[100],
              child: ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text('Erro de sincronização'),
                subtitle: Text('Alguns dados não foram salvos na nuvem'),
                trailing: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => syncService.forceSync(),
                ),
              ),
            );
          case SyncStatus.syncing:
            return LinearProgressIndicator();
          case SyncStatus.synced:
            return Icon(Icons.cloud_done, color: Colors.green);
          default:
            return SizedBox.shrink();
        }
      },
    );
  }
}
```

**Prioridade:** 🔴 CRÍTICA
**Estimativa:** 4-6 horas

#### 🔴 3. Connectivity State Persistence

**Problema:**
Estado de conectividade não é persistido entre sessões do app.

**Impacto:**
- Ao abrir app offline, pode tentar sync desnecessariamente
- Waste de bateria e dados

**Solução:**
```dart
class ConnectivityStateManager {
  static const _key = 'last_connectivity_state';

  Future<void> saveState(bool isOnline) async {
    await SharedPreferences.getInstance()
      .then((prefs) => prefs.setBool(_key, isOnline));
  }

  Future<bool> loadState() async {
    return await SharedPreferences.getInstance()
      .then((prefs) => prefs.getBool(_key) ?? true);
  }
}
```

**Prioridade:** 🔴 ALTA
**Estimativa:** 2 horas

### Importante (Implementar Médio Prazo)

#### 🟡 4. Schema Migration System

**Problema:**
Mudanças no schema dos models não têm sistema de migration.

**Impacto:**
- Crashes ao ler dados antigos
- Necessidade de clear data manual

**Solução:**
```dart
class HiveSchemaManager {
  static const int currentVersion = 2;
  static const String versionKey = 'schema_version';

  Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final oldVersion = prefs.getInt(versionKey) ?? 1;

    if (oldVersion < currentVersion) {
      await _runMigrations(oldVersion, currentVersion);
      await prefs.setInt(versionKey, currentVersion);
    }
  }

  Future<void> _runMigrations(int from, int to) async {
    for (int v = from; v < to; v++) {
      switch (v) {
        case 1:
          await _migrateV1ToV2();
          break;
        // ... outras migrações
      }
    }
  }

  Future<void> _migrateV1ToV2() async {
    final box = await Hive.openBox('plants');
    for (final key in box.keys) {
      final plantJson = box.get(key) as String;
      final plantData = jsonDecode(plantJson);

      // Adicionar campo novo se não existir
      if (!plantData.containsKey('wateringFrequency')) {
        plantData['wateringFrequency'] = 7; // Default
        await box.put(key, jsonEncode(plantData));
      }
    }
  }
}
```

**Prioridade:** 🟡 IMPORTANTE
**Estimativa:** 6-8 horas

#### 🟡 5. Conflict Resolution UI

**Problema:**
Conflitos são resolvidos automaticamente sem input do usuário.

**Impacto:**
- Usuário pode perder edições importantes
- Sem transparência

**Solução:**
```dart
class ConflictResolutionDialog extends StatelessWidget {
  final Plant localVersion;
  final Plant remoteVersion;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Conflito detectado'),
      content: Column(
        children: [
          Text('A planta "${localVersion.name}" foi editada em outro dispositivo.'),
          SizedBox(height: 16),
          _buildVersionComparison(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, localVersion),
          child: Text('Manter minha versão'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, remoteVersion),
          child: Text('Usar versão remota'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Decidir depois'),
        ),
      ],
    );
  }
}
```

**Prioridade:** 🟡 IMPORTANTE
**Estimativa:** 8-12 horas

#### 🟡 6. Batch Sync Optimization

**Problema:**
Múltiplos itens são sincronizados um por um.

**Impacto:**
- Performance ruim com muitos itens
- Timeout em conexões lentas

**Solução:**
```dart
Future<void> syncBatch(List<Plant> plants) async {
  const batchSize = 50;

  for (int i = 0; i < plants.length; i += batchSize) {
    final batch = plants.skip(i).take(batchSize).toList();

    // Firebase batch write
    final firebaseBatch = _firestore.batch();
    for (final plant in batch) {
      final docRef = _firestore
        .collection('users/$userId/plants')
        .doc(plant.id);
      firebaseBatch.set(docRef, plant.toFirebaseMap());
    }
    await firebaseBatch.commit();

    // Update local isDirty flags
    for (final plant in batch) {
      await _localDatasource.updatePlant(
        plant.copyWith(isDirty: false),
      );
    }
  }
}
```

**Prioridade:** 🟡 IMPORTANTE
**Estimativa:** 4-6 horas

### Desejável (Futuro)

#### 🟢 7. Sync Metrics Dashboard

**Descrição:**
Dashboard de métricas de sincronização para debugging e monitoring.

**Funcionalidades:**
- Latência de sync
- Success rate
- Conflitos detectados
- Network quality
- Itens pendentes

**Estimativa:** 12-16 horas

#### 🟢 8. Predictive Sync

**Descrição:**
Sistema que prevê quando usuário vai precisar de dados e pre-load.

**Funcionalidades:**
- ML model para predição
- Pre-cache inteligente
- Sync prioritizado

**Estimativa:** 20-30 horas

#### 🟢 9. Differential Sync

**Descrição:**
Sincronizar apenas mudanças (delta) ao invés de documento completo.

**Benefícios:**
- Menor uso de dados
- Sync mais rápido
- Melhor para conexões lentas

**Estimativa:** 16-24 horas

---

## 🎯 Recomendações de Excelência

### Performance

#### 1. Implementar Cache Warming

```dart
class CacheWarmingService {
  Future<void> warmCache() async {
    // Pre-load dados críticos ao iniciar app
    await Future.wait([
      _plantsRepository.getPlants(),
      _tasksRepository.getTodayTasks(),
      _spacesRepository.getSpaces(),
    ]);
  }
}

// No main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();

  // Warm cache antes de mostrar UI
  await CacheWarmingService().warmCache();

  runApp(MyApp());
}
```

**Benefício:** UI inicial instantânea

#### 2. Implementar Debouncing em Sync

```dart
class DebouncedSyncService {
  Timer? _syncTimer;
  static const _syncDelay = Duration(seconds: 2);

  void scheduleSyncDebounced() {
    _syncTimer?.cancel();
    _syncTimer = Timer(_syncDelay, () => _performSync());
  }
}
```

**Benefício:** Reduz número de sync operations

#### 3. Implementar Lazy Loading

```dart
class LazyPlantsList extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index >= _plants.length - 5) {
          _loadMorePlants(); // Load next batch
        }
        return PlantCard(plant: _plants[index]);
      },
    );
  }
}
```

**Benefício:** Melhor performance com grandes listas

### UX

#### 4. Indicadores Visuais de Sync

```dart
class SyncIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: syncService.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.synced;

        return Row(
          children: [
            _getStatusIcon(status),
            SizedBox(width: 4),
            Text(_getStatusText(status)),
          ],
        );
      },
    );
  }

  Widget _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.synced:
        return Icon(Icons.cloud_done, color: Colors.green);
      case SyncStatus.offline:
        return Icon(Icons.cloud_off, color: Colors.grey);
      case SyncStatus.error:
        return Icon(Icons.cloud_off, color: Colors.red);
      default:
        return SizedBox.shrink();
    }
  }
}
```

#### 5. Undo/Redo para Conflitos

```dart
class ConflictUndoService {
  final List<ConflictSnapshot> _history = [];

  void saveSnapshot(Plant local, Plant remote) {
    _history.add(ConflictSnapshot(
      timestamp: DateTime.now(),
      localVersion: local,
      remoteVersion: remote,
      chosenVersion: local, // Usuário escolheu local
    ));
  }

  Future<void> undo() async {
    if (_history.isEmpty) return;
    final snapshot = _history.removeLast();
    await _repository.updatePlant(snapshot.remoteVersion);
  }
}
```

#### 6. Modo Avião Explícito

```dart
class AirplaneModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Modo Avião'),
      subtitle: Text('Desabilitar sincronização temporariamente'),
      value: _isAirplaneModeEnabled,
      onChanged: (value) {
        setState(() => _isAirplaneModeEnabled = value);
        if (value) {
          _syncService.pauseSync();
        } else {
          _syncService.resumeSync();
        }
      },
    );
  }
}
```

### Segurança

#### 7. Validar Dados do Firebase

```dart
T fromFirebaseMap(Map<String, dynamic> map) {
  try {
    // Validar campos obrigatórios
    if (!map.containsKey('id') || !map.containsKey('name')) {
      throw ValidationException('Missing required fields');
    }

    // Sanitizar strings
    final name = (map['name'] as String).trim();
    if (name.isEmpty) {
      throw ValidationException('Invalid name');
    }

    // Validar timestamps
    final createdAt = DateTime.tryParse(map['created_at']);
    if (createdAt == null) {
      throw ValidationException('Invalid created_at');
    }

    return PlantModel(/* ... */);
  } catch (e) {
    throw DataCorruptionException('Failed to parse plant: $e');
  }
}
```

#### 8. Encriptar Dados Sensíveis no Hive

```dart
Future<void> initHive() async {
  await Hive.initFlutter();

  // Gerar encryption key
  final encryptionKey = await _getEncryptionKey();

  // Abrir box com encriptação
  await Hive.openBox(
    'plants',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

#### 9. Rate Limiting

```dart
class RateLimiter {
  final Map<String, int> _requestCounts = {};
  static const _maxRequestsPerMinute = 60;

  bool canMakeRequest(String userId) {
    final now = DateTime.now();
    final minute = now.minute;
    final key = '$userId-$minute';

    final count = _requestCounts[key] ?? 0;
    if (count >= _maxRequestsPerMinute) {
      return false;
    }

    _requestCounts[key] = count + 1;
    return true;
  }
}
```

### Observabilidade

#### 10. Logging Estruturado

```dart
class SyncLogger {
  static void logSyncStart(String entity, int itemCount) {
    developer.log(
      'Sync started',
      name: 'SyncService',
      time: DateTime.now(),
      level: Level.INFO.value,
      error: null,
      stackTrace: null,
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'sync_started',
      parameters: {
        'entity_type': entity,
        'item_count': itemCount,
      },
    );
  }

  static void logSyncComplete(String entity, Duration duration) {
    developer.log(
      'Sync completed in ${duration.inMilliseconds}ms',
      name: 'SyncService',
    );

    FirebaseAnalytics.instance.logEvent(
      name: 'sync_completed',
      parameters: {
        'entity_type': entity,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}
```

#### 11. Health Checks

```dart
class SyncHealthCheck {
  Future<HealthStatus> checkHealth() async {
    final checks = await Future.wait([
      _checkHiveHealth(),
      _checkFirebaseHealth(),
      _checkNetworkHealth(),
    ]);

    return HealthStatus(
      isHealthy: checks.every((c) => c.isHealthy),
      checks: checks,
      timestamp: DateTime.now(),
    );
  }

  Future<CheckResult> _checkHiveHealth() async {
    try {
      final box = await Hive.openBox('health_check');
      await box.put('test', 'value');
      final value = box.get('test');
      await box.delete('test');

      return CheckResult(
        name: 'Hive',
        isHealthy: value == 'value',
      );
    } catch (e) {
      return CheckResult(
        name: 'Hive',
        isHealthy: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## 🗺️ Roadmap de Implementação

### Fase 1: Stabilização (1-2 semanas)

**Objetivo:** Resolver issues críticos e estabilizar sync

**Tarefas:**

1. **Implementar Cascade Delete** (2-4h)
   - [ ] Implementar em PlantsRepository
   - [ ] Adicionar testes
   - [ ] Documentar comportamento

2. **Error Recovery UI** (4-6h)
   - [ ] Criar SyncStatusWidget
   - [ ] Adicionar retry manual
   - [ ] Integrar em todas as páginas principais

3. **Connectivity State Persistence** (2h)
   - [ ] Implementar ConnectivityStateManager
   - [ ] Integrar com app initialization
   - [ ] Adicionar testes

4. **Logging e Monitoring** (4h)
   - [ ] Implementar SyncLogger estruturado
   - [ ] Adicionar Firebase Analytics events
   - [ ] Criar dashboard no Firebase Console

**Entregável:** Sistema de sync estável e observável

### Fase 2: Performance (1 semana)

**Objetivo:** Otimizar performance de sync

**Tarefas:**

1. **Batch Sync Optimization** (4-6h)
   - [ ] Implementar batch operations no Firebase
   - [ ] Otimizar local batch updates
   - [ ] Adicionar progress indicators

2. **Cache Warming** (2-3h)
   - [ ] Implementar CacheWarmingService
   - [ ] Integrar no app startup
   - [ ] Medir impacto no tempo de load

3. **Debouncing** (2h)
   - [ ] Implementar DebouncedSyncService
   - [ ] Aplicar em operações de escrita
   - [ ] Configurar delays ótimos

4. **Lazy Loading** (3-4h)
   - [ ] Implementar pagination
   - [ ] Adicionar infinite scroll
   - [ ] Otimizar queries

**Entregável:** Sync rápido e eficiente

### Fase 3: UX Improvements (1 semana)

**Objetivo:** Melhorar experiência do usuário

**Tarefas:**

1. **Conflict Resolution UI** (8-12h)
   - [ ] Criar ConflictResolutionDialog
   - [ ] Implementar preview de versões
   - [ ] Adicionar undo/redo
   - [ ] Integrar com sync flow

2. **Sync Indicators** (4h)
   - [ ] Criar SyncIndicator widget
   - [ ] Adicionar em todas as listas
   - [ ] Implementar animations

3. **Modo Avião** (2h)
   - [ ] Criar AirplaneModeToggle
   - [ ] Implementar pause/resume logic
   - [ ] Persistir preferência

4. **Onboarding Offline** (3h)
   - [ ] Criar tutorial de funcionamento offline
   - [ ] Explicar sync automático
   - [ ] Mostrar em primeira execução

**Entregável:** UX polida e intuitiva

### Fase 4: Robustez (1-2 semanas)

**Objetivo:** Tornar sistema robusto e resiliente

**Tarefas:**

1. **Schema Migration System** (6-8h)
   - [ ] Implementar HiveSchemaManager
   - [ ] Criar migrations para versões existentes
   - [ ] Adicionar testes de migration
   - [ ] Documentar processo

2. **Retry Queue Persistence** (4-6h)
   - [ ] Implementar PersistentRetryQueue
   - [ ] Integrar com sync flow
   - [ ] Adicionar cleanup de operações antigas

3. **Health Checks** (4h)
   - [ ] Implementar SyncHealthCheck
   - [ ] Adicionar em settings page
   - [ ] Criar alerts para problemas

4. **Rate Limiting** (2-3h)
   - [ ] Implementar RateLimiter
   - [ ] Integrar com Firebase calls
   - [ ] Adicionar backoff exponencial

**Entregável:** Sistema robusto e resiliente

### Fase 5: Observabilidade (1 semana)

**Objetivo:** Visibility completa do sistema

**Tarefas:**

1. **Sync Metrics Dashboard** (8-12h)
   - [ ] Criar página de métricas
   - [ ] Implementar collectors
   - [ ] Integrar com Firebase Analytics
   - [ ] Adicionar gráficos

2. **Crash Reporting** (2-3h)
   - [ ] Integrar Firebase Crashlytics
   - [ ] Adicionar context em crashes
   - [ ] Configurar alertas

3. **Performance Monitoring** (3-4h)
   - [ ] Integrar Firebase Performance
   - [ ] Adicionar custom traces
   - [ ] Monitorar sync latency

4. **A/B Testing** (4h)
   - [ ] Integrar Firebase Remote Config
   - [ ] Criar flags para estratégias de sync
   - [ ] Implementar experiments

**Entregável:** Sistema completamente observável

### Fase 6: Features Avançadas (2-3 semanas)

**Objetivo:** Features de próximo nível

**Tarefas:**

1. **Differential Sync** (16-24h)
   - [ ] Implementar delta tracking
   - [ ] Criar merge patches
   - [ ] Otimizar payload size
   - [ ] Adicionar testes

2. **Predictive Sync** (20-30h)
   - [ ] Treinar ML model
   - [ ] Implementar pre-caching
   - [ ] Adicionar analytics
   - [ ] Medir ROI

3. **Multi-User Collaboration** (30-40h)
   - [ ] Implementar sharing
   - [ ] Adicionar permissions
   - [ ] Criar real-time collaboration UI
   - [ ] Implementar presence

**Entregável:** Sistema de sync de classe mundial

---

## 📝 Atualizações e Tarefas

### Checklist de Implementação Imediata

#### 🔴 Crítico - Fazer AGORA

- [ ] **Cascade Delete Logic**
  - [ ] Implementar em `PlantsRepositoryImpl.deletePlant()`
  - [ ] Deletar tasks relacionadas
  - [ ] Deletar comentários relacionados
  - [ ] Adicionar testes unitários
  - [ ] Testar com dados reais
  - **Estimativa:** 2-4 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

- [ ] **Error Recovery UI**
  - [ ] Criar `SyncStatusWidget`
  - [ ] Adicionar retry button
  - [ ] Integrar em `PlantsList` page
  - [ ] Integrar em `TasksList` page
  - [ ] Adicionar animações
  - **Estimativa:** 4-6 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

- [ ] **Fix Orphan Records**
  - [ ] Executar script de cleanup no Firebase
  - [ ] Implementar prevention logic
  - [ ] Adicionar monitoring
  - **Estimativa:** 2-3 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

#### 🟡 Importante - Fazer Esta Semana

- [ ] **Schema Migration**
  - [ ] Criar `HiveSchemaManager`
  - [ ] Implementar migration v1 → v2
  - [ ] Adicionar testes
  - [ ] Documentar processo
  - **Estimativa:** 6-8 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

- [ ] **Batch Sync Optimization**
  - [ ] Implementar batch writes no Firebase
  - [ ] Otimizar local updates
  - [ ] Adicionar progress tracking
  - [ ] Medir performance improvement
  - **Estimativa:** 4-6 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

- [ ] **Conflict Resolution UI**
  - [ ] Criar `ConflictResolutionDialog`
  - [ ] Implementar diff viewer
  - [ ] Adicionar escolha manual
  - [ ] Integrar com sync flow
  - **Estimativa:** 8-12 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

#### 🟢 Desejável - Fazer Este Mês

- [ ] **Sync Metrics Dashboard**
  - [ ] Criar página de métricas
  - [ ] Adicionar collectors
  - [ ] Implementar gráficos
  - [ ] Integrar Firebase Analytics
  - **Estimativa:** 12-16 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

- [ ] **Predictive Sync**
  - [ ] Pesquisar ML models
  - [ ] Implementar POC
  - [ ] Medir accuracy
  - [ ] Deploy em produção
  - **Estimativa:** 20-30 horas
  - **Responsável:** [Nome]
  - **Deadline:** [Data]

### KPIs de Sync

**Medir e Melhorar:**

| Métrica | Atual | Meta | Status |
|---------|-------|------|--------|
| Sync Latency (p50) | ~800ms | <500ms | ⚠️ |
| Sync Latency (p95) | ~2000ms | <1000ms | ⚠️ |
| Sync Success Rate | ~95% | >99% | ⚠️ |
| Conflict Rate | ~2% | <0.5% | ⚠️ |
| Offline Capability | 100% | 100% | ✅ |
| Cache Hit Rate | ~80% | >90% | ⚠️ |
| Orphan Records | Unknown | 0 | ❌ |

### Testes Necessários

#### Unit Tests

- [ ] `PlantsLocalDatasource` - CRUD operations
- [ ] `TasksLocalDatasource` - Filtros e queries
- [ ] `PlantsRepository` - Offline-first logic
- [ ] `TasksRepository` - Sync strategies
- [ ] `SyncFirebaseService` - Conflict resolution
- [ ] `NetworkInfoAdapter` - Enhanced features

#### Integration Tests

- [ ] Fluxo completo: Create → Sync → Read
- [ ] Fluxo offline: Create → Reconnect → Sync
- [ ] Fluxo de conflito: Edit em 2 devices
- [ ] Cascade delete
- [ ] Batch sync

#### E2E Tests

- [ ] User journey: Adicionar planta offline → Sincronizar
- [ ] User journey: Editar planta em múltiplos devices
- [ ] User journey: Deletar planta e verificar cascade
- [ ] Performance test: Sync de 1000 plantas

---

## 📚 Referências

### Documentação Oficial

- [Hive Documentation](https://docs.hivedb.dev/)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Connectivity Plus](https://pub.dev/packages/connectivity_plus)
- [Dartz Functional Programming](https://pub.dev/packages/dartz)

### Padrões Arquiteturais

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Offline-First Design](https://offlinefirst.org/)

### Best Practices

- [Flutter Offline-First Apps](https://flutter.dev/docs/cookbook/persistence/sqlite)
- [Firebase Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Conflict-Free Replicated Data Types (CRDTs)](https://crdt.tech/)

---

**Documento mantido por:** Time de Desenvolvimento Plantis
**Última atualização:** 07 de Outubro de 2025
**Versão:** 1.0
