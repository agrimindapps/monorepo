# ADR-001: Drift-Firestore Hybrid Sync Architecture

**Date:** 2025-11-08
**Status:** Accepted
**Decision Makers:** Flutter Architecture Team
**Category:** Data Synchronization Strategy

---

## Context

### Background

O app-gasometer-drift realizou recentemente uma migração crítica do sistema de persistência local:

- **Before:** Hive (NoSQL document store) + Firebase Firestore sync
- **After:** Drift (SQLite type-safe ORM) com campos de sync preparados mas **sincronização inativa**

### Current State

**Implemented:**
- ✅ Drift database com 6 tabelas normalizadas (Vehicles, FuelSupplies, Maintenances, Expenses, OdometerReadings, AuditTrail)
- ✅ Sync metadata fields em todas as tabelas:
  - `firebaseId` (UUID - chave no Firestore)
  - `isDirty` (flag de modificação local pendente)
  - `isDeleted` (soft delete para sync)
  - `version` (conflict resolution counter)
  - `lastSyncAt` (timestamp da última sincronização)
- ✅ Domain entities estendem `BaseSyncEntity` com metadata comum
- ✅ Repository pattern implementado (6 repositories)

**Missing:**
- ❌ `GasometerSyncConfig` vazio (linha 59-62) - sem conexão Drift ↔ Firestore
- ❌ Sync adapter layer não implementada
- ❌ Background sync service não configurado
- ❌ Conflict resolution strategy não definida
- ❌ Batch operations para eficiência de sync

### Problem Statement

A migração Hive → Drift trouxe benefícios de performance e type-safety, mas deixou o app sem capacidade de sincronização multi-device crítica para:

1. **Data Portability:** Usuários trocam de dispositivo frequentemente
2. **Data Resilience:** Proteção contra perda de dados local
3. **Multi-Device Usage:** Mesmo usuário em múltiplos dispositivos (tablet + smartphone)
4. **Premium Feature:** Sincronização é feature premium (RevenueCat gate)

### Constraints

- **Offline-First Required:** App deve funcionar 100% offline
- **Type-Safety:** Drift não pode ser comprometido por sync inseguro
- **Clean Architecture:** Manter separação Domain/Data/Presentation
- **Performance:** Sync não pode bloquear UI ou operações CRUD locais
- **Cost:** Minimizar reads/writes no Firestore (Firebase pricing)
- **Migration Effort:** 18-25h disponíveis para implementação completa

---

## Decision

### Chosen Architecture: **Hybrid 3-Layer Sync with Background Worker**

Implementar sincronização bidirecional entre Drift e Firestore usando arquitetura em 3 camadas:

1. **Local Layer (Drift/SQLite):** Fonte primária de verdade, offline-first
2. **Sync Adapter Layer:** Conversão bidirecional Drift ↔ Domain ↔ Firestore
3. **Background Sync Service:** Orquestração automática com batch operations

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Riverpod Providers (VehicleNotifier, FuelSupplyNotifier, etc.) │   │
│  └────────────────────────────┬─────────────────────────────────────┘   │
└───────────────────────────────┼─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                    │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Entities: VehicleEntity, FuelSupplyEntity (BaseSyncEntity)     │   │
│  │  Use Cases: SyncVehiclesUseCase, ResolveSyncConflictUseCase     │   │
│  └────────────────────────────┬─────────────────────────────────────┘   │
└───────────────────────────────┼─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       DATA/REPOSITORY LAYER                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Repositories: VehicleRepository, FuelSupplyRepository           │   │
│  │    - CRUD operations (Drift)                                     │   │
│  │    - Sync coordination (marks isDirty, triggers sync)            │   │
│  └──────────┬────────────────────────────────────────┬──────────────┘   │
└─────────────┼────────────────────────────────────────┼──────────────────┘
              │                                        │
              ▼                                        ▼
┌──────────────────────────────┐    ┌─────────────────────────────────────┐
│   DRIFT LOCAL DATA SOURCE    │    │    FIRESTORE REMOTE DATA SOURCE     │
│  ┌────────────────────────┐  │    │  ┌──────────────────────────────┐   │
│  │ GasometerDatabase      │  │    │  │ FirebaseFirestore.instance   │   │
│  │ (SQLite via Drift)     │  │    │  │ Collections:                 │   │
│  │ - Vehicles table       │  │    │  │  - users/{uid}/vehicles      │   │
│  │ - FuelSupplies table   │  │    │  │  - users/{uid}/fuel_supplies │   │
│  │ - Maintenances table   │  │    │  │  - users/{uid}/maintenances  │   │
│  │ - Expenses table       │  │    │  │  - users/{uid}/expenses      │   │
│  │ - OdometerReadings tbl │  │    │  │  - users/{uid}/odometer_rdgs │   │
│  │ - AuditTrail table     │  │    │  │  - users/{uid}/audit_trail   │   │
│  └────────────────────────┘  │    │  └──────────────────────────────┘   │
└──────────────┬───────────────┘    └───────────────┬─────────────────────┘
               │                                    │
               │         ┌──────────────────────────┘
               │         │
               ▼         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       SYNC ADAPTER LAYER                                 │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  Abstract: DriftSyncAdapter<TEntity, TDriftRow>                  │   │
│  │    - toDomain(TDriftRow row): TEntity                            │   │
│  │    - toDrift(TEntity entity): TDriftRow                          │   │
│  │    - toFirestore(TEntity entity): Map<String, dynamic>           │   │
│  │    - fromFirestore(Map<String, dynamic> doc): TEntity            │   │
│  ├──────────────────────────────────────────────────────────────────┤   │
│  │  Implementations:                                                │   │
│  │    - VehicleDriftSyncAdapter                                     │   │
│  │    - FuelSupplyDriftSyncAdapter                                  │   │
│  │    - MaintenanceDriftSyncAdapter                                 │   │
│  │    - ExpenseDriftSyncAdapter                                     │   │
│  │    - OdometerReadingDriftSyncAdapter                             │   │
│  │    - AuditTrailDriftSyncAdapter                                  │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    SYNC ORCHESTRATION LAYER                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  GasometerDriftSyncService (implements ISyncService)             │   │
│  │    - syncVehicles(): Either<Failure, SyncResult>                 │   │
│  │    - syncFuelSupplies(): Either<Failure, SyncResult>             │   │
│  │    - syncAll(): Either<Failure, FullSyncResult>                  │   │
│  │    - resolveConflict(entity, strategy): Either<Failure, Entity>  │   │
│  ├──────────────────────────────────────────────────────────────────┤   │
│  │  GasometerBatchSyncService (Background Worker)                   │   │
│  │    - startAutoSync(interval: Duration)                           │   │
│  │    - stopAutoSync()                                              │   │
│  │    - performBatchSync(): Either<Failure, BatchSyncResult>        │   │
│  │    - Strategies:                                                 │   │
│  │      * Push: dirty records → Firestore (incremental)             │   │
│  │      * Pull: Firestore changes → Drift (since lastSyncAt)        │   │
│  │      * Batch: max 50 items per batch (Firestore quota)           │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CONNECTIVITY LAYER                               │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  ConnectivityService (from core package)                         │   │
│  │    - isOnline(): bool                                            │   │
│  │    - connectivityStream: Stream<ConnectivityStatus>              │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Components Specification

### 1. DriftSyncAdapter<TEntity, TDriftRow> (Abstract Base)

**Location:** `lib/database/adapters/drift_sync_adapter.dart`

**Purpose:** Generic bidirectional conversion between Drift rows, Domain entities, and Firestore documents.

**Interface:**
```dart
abstract class DriftSyncAdapter<TEntity extends BaseSyncEntity, TDriftRow> {
  /// Convert Drift row to Domain entity
  TEntity toDomain(TDriftRow row);

  /// Convert Domain entity to Drift companion (for inserts/updates)
  Insertable<TDriftRow> toDrift(TEntity entity);

  /// Convert Domain entity to Firestore document
  Map<String, dynamic> toFirestore(TEntity entity);

  /// Convert Firestore document to Domain entity
  Either<Failure, TEntity> fromFirestore(Map<String, dynamic> doc);

  /// Table name for Firestore collection
  String get firestoreCollectionName;

  /// Unique identifier field name
  String get idFieldName;
}
```

**Responsibilities:**
- Type-safe conversions between 3 data representations
- Validation during Firestore → Domain conversion (Either<Failure, T>)
- Metadata handling (firebaseId, isDirty, version, etc.)

### 2. Concrete Adapters (6 implementations)

**VehicleDriftSyncAdapter:**
```dart
@injectable
class VehicleDriftSyncAdapter
    extends DriftSyncAdapter<VehicleEntity, VehicleTableData> {

  @override
  VehicleEntity toDomain(VehicleTableData row) {
    return VehicleEntity(
      id: row.id,
      name: row.name,
      plate: row.plate,
      brand: row.brand,
      model: row.model,
      year: row.year,
      color: row.color,
      fuelType: FuelType.values.firstWhere((e) => e.name == row.fuelType),
      tankCapacity: row.tankCapacity,
      purchaseDate: row.purchaseDate,
      purchaseValue: row.purchaseValue,
      currentOdometer: row.currentOdometer,
      avgConsumption: row.avgConsumption,
      notes: row.notes,
      isActive: row.isActive,
      // Sync metadata
      firebaseId: row.firebaseId,
      isDirty: row.isDirty,
      isDeleted: row.isDeleted,
      version: row.version,
      lastSyncAt: row.lastSyncAt,
    );
  }

  @override
  VehiclesCompanion toDrift(VehicleEntity entity) {
    return VehiclesCompanion.insert(
      id: Value(entity.id),
      name: entity.name,
      plate: entity.plate,
      // ... all fields
      firebaseId: Value(entity.firebaseId),
      isDirty: Value(entity.isDirty),
      isDeleted: Value(entity.isDeleted),
      version: Value(entity.version),
      lastSyncAt: Value(entity.lastSyncAt),
    );
  }

  @override
  Map<String, dynamic> toFirestore(VehicleEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'plate': entity.plate,
      'brand': entity.brand,
      'model': entity.model,
      'year': entity.year,
      'color': entity.color,
      'fuelType': entity.fuelType.name,
      'tankCapacity': entity.tankCapacity,
      'purchaseDate': entity.purchaseDate?.toIso8601String(),
      'purchaseValue': entity.purchaseValue,
      'currentOdometer': entity.currentOdometer,
      'avgConsumption': entity.avgConsumption,
      'notes': entity.notes,
      'isActive': entity.isActive,
      // Sync metadata
      'version': entity.version,
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': entity.isDeleted,
    };
  }

  @override
  Either<Failure, VehicleEntity> fromFirestore(Map<String, dynamic> doc) {
    try {
      // Validation
      if (!doc.containsKey('id') || !doc.containsKey('name')) {
        return Left(ValidationFailure('Missing required fields in Firestore document'));
      }

      return Right(VehicleEntity(
        id: doc['id'] as String,
        name: doc['name'] as String,
        plate: doc['plate'] as String? ?? '',
        // ... parse all fields with null safety
        firebaseId: doc['id'] as String, // Firebase doc ID
        isDirty: false, // From remote, not dirty
        isDeleted: doc['isDeleted'] as bool? ?? false,
        version: doc['version'] as int? ?? 1,
        lastSyncAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(DataParseFailure('Failed to parse Firestore document: $e'));
    }
  }

  @override
  String get firestoreCollectionName => 'vehicles';

  @override
  String get idFieldName => 'id';
}
```

**Similar implementations for:**
- FuelSupplyDriftSyncAdapter
- MaintenanceDriftSyncAdapter
- ExpenseDriftSyncAdapter
- OdometerReadingDriftSyncAdapter
- AuditTrailDriftSyncAdapter

### 3. GasometerDriftSyncService

**Location:** `lib/core/sync/gasometer_drift_sync_service.dart`

**Purpose:** Orchestrate incremental sync operations per entity type.

**Implementation:**
```dart
@injectable
class GasometerDriftSyncService implements ISyncService {
  const GasometerDriftSyncService({
    required this.vehicleRepository,
    required this.fuelSupplyRepository,
    required this.maintenanceRepository,
    required this.expenseRepository,
    required this.odometerReadingRepository,
    required this.auditTrailRepository,
    required this.vehicleAdapter,
    required this.fuelSupplyAdapter,
    required this.maintenanceAdapter,
    required this.expenseAdapter,
    required this.odometerReadingAdapter,
    required this.auditTrailAdapter,
    required this.firestore,
    required this.authService,
    required this.connectivityService,
  });

  final VehicleRepository vehicleRepository;
  final FuelSupplyRepository fuelSupplyRepository;
  final MaintenanceRepository maintenanceRepository;
  final ExpenseRepository expenseRepository;
  final OdometerReadingRepository odometerReadingRepository;
  final AuditTrailRepository auditTrailRepository;

  final VehicleDriftSyncAdapter vehicleAdapter;
  final FuelSupplyDriftSyncAdapter fuelSupplyAdapter;
  final MaintenanceDriftSyncAdapter maintenanceAdapter;
  final ExpenseDriftSyncAdapter expenseAdapter;
  final OdometerReadingDriftSyncAdapter odometerReadingAdapter;
  final AuditTrailDriftSyncAdapter auditTrailAdapter;

  final FirebaseFirestore firestore;
  final AuthService authService;
  final ConnectivityService connectivityService;

  /// Sync vehicles: Push dirty → Firestore, Pull remote → Drift
  @override
  Future<Either<Failure, SyncResult>> syncVehicles() async {
    // 1. Check connectivity
    if (!connectivityService.isOnline()) {
      return Left(NetworkFailure('No internet connection'));
    }

    // 2. Get current user
    final userResult = await authService.currentUser;
    if (userResult == null) {
      return Left(AuthFailure('User not authenticated'));
    }
    final userId = userResult.uid;

    // 3. PUSH: Get dirty vehicles from Drift
    final dirtyVehiclesResult = await vehicleRepository.getDirtyRecords();
    if (dirtyVehiclesResult.isLeft()) {
      return Left((dirtyVehiclesResult as Left).value);
    }
    final dirtyVehicles = (dirtyVehiclesResult as Right<Failure, List<VehicleEntity>>).value;

    int pushedCount = 0;
    int pulledCount = 0;
    int conflictsResolved = 0;

    // 4. Push each dirty vehicle to Firestore
    for (final vehicle in dirtyVehicles) {
      try {
        final firestoreDoc = vehicleAdapter.toFirestore(vehicle);

        await firestore
            .collection('users')
            .doc(userId)
            .collection('vehicles')
            .doc(vehicle.firebaseId ?? vehicle.id)
            .set(firestoreDoc, SetOptions(merge: true));

        // Mark as synced in Drift
        await vehicleRepository.markAsSynced(
          vehicle.id,
          firebaseId: vehicle.firebaseId ?? vehicle.id,
        );

        pushedCount++;
      } catch (e) {
        // Log error but continue with other records
        print('Error pushing vehicle ${vehicle.id}: $e');
      }
    }

    // 5. PULL: Get remote changes since last sync
    final lastSyncAt = await _getLastSyncTimestamp('vehicles');

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .where('updatedAt', isGreaterThan: lastSyncAt)
        .get();

    // 6. Process remote changes
    for (final doc in snapshot.docs) {
      final remoteVehicleResult = vehicleAdapter.fromFirestore(doc.data());

      if (remoteVehicleResult.isRight()) {
        final remoteVehicle = (remoteVehicleResult as Right<Failure, VehicleEntity>).value;

        // Check for conflicts
        final localVehicleResult = await vehicleRepository.getById(remoteVehicle.id);

        if (localVehicleResult.isRight()) {
          final localVehicle = (localVehicleResult as Right<Failure, VehicleEntity>).value;

          // Conflict detection: both dirty and versions differ
          if (localVehicle.isDirty && localVehicle.version != remoteVehicle.version) {
            // Conflict resolution: Last Write Wins (LWW)
            final resolvedVehicle = _resolveConflictLWW(localVehicle, remoteVehicle);
            await vehicleRepository.update(resolvedVehicle);
            conflictsResolved++;
          } else {
            // No conflict, apply remote changes
            await vehicleRepository.update(remoteVehicle);
            pulledCount++;
          }
        } else {
          // New record from remote
          await vehicleRepository.create(remoteVehicle);
          pulledCount++;
        }
      }
    }

    // 7. Update last sync timestamp
    await _updateLastSyncTimestamp('vehicles');

    return Right(SyncResult(
      entityType: 'vehicles',
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      conflictsResolved: conflictsResolved,
      syncedAt: DateTime.now(),
    ));
  }

  /// Sync all entities sequentially
  @override
  Future<Either<Failure, FullSyncResult>> syncAll() async {
    final results = <SyncResult>[];

    // Sync order: vehicles first (parent), then related entities
    final syncOperations = [
      syncVehicles,
      syncFuelSupplies,
      syncMaintenances,
      syncExpenses,
      syncOdometerReadings,
      syncAuditTrail,
    ];

    for (final syncOp in syncOperations) {
      final result = await syncOp();

      if (result.isRight()) {
        results.add((result as Right<Failure, SyncResult>).value);
      } else {
        // On first error, return failure
        return Left((result as Left<Failure, SyncResult>).value);
      }
    }

    return Right(FullSyncResult(
      results: results,
      totalPushed: results.fold(0, (sum, r) => sum + r.pushedCount),
      totalPulled: results.fold(0, (sum, r) => sum + r.pulledCount),
      totalConflictsResolved: results.fold(0, (sum, r) => sum + r.conflictsResolved),
      completedAt: DateTime.now(),
    ));
  }

  /// Conflict resolution: Last Write Wins
  VehicleEntity _resolveConflictLWW(
    VehicleEntity local,
    VehicleEntity remote,
  ) {
    // Compare versions or timestamps
    if (remote.version > local.version) {
      return remote.copyWith(
        isDirty: false,
        lastSyncAt: DateTime.now(),
      );
    } else {
      return local.copyWith(
        version: local.version + 1,
        isDirty: true, // Keep dirty to push again
      );
    }
  }

  Future<DateTime?> _getLastSyncTimestamp(String entityType) async {
    // Stored in SharedPreferences or Drift metadata table
    // Return null if never synced
    return null;
  }

  Future<void> _updateLastSyncTimestamp(String entityType) async {
    // Store current timestamp in SharedPreferences
  }

  // Similar implementations for:
  // - syncFuelSupplies()
  // - syncMaintenances()
  // - syncExpenses()
  // - syncOdometerReadings()
  // - syncAuditTrail()
}
```

### 4. GasometerBatchSyncService

**Location:** `lib/core/sync/gasometer_batch_sync_service.dart`

**Purpose:** Background worker for automatic periodic sync with batch optimizations.

**Implementation:**
```dart
@injectable
class GasometerBatchSyncService {
  const GasometerBatchSyncService({
    required this.syncService,
    required this.connectivityService,
    required this.premiumService,
  });

  final GasometerDriftSyncService syncService;
  final ConnectivityService connectivityService;
  final PremiumService premiumService;

  Timer? _syncTimer;
  final StreamController<BatchSyncResult> _syncResultController =
      StreamController<BatchSyncResult>.broadcast();

  Stream<BatchSyncResult> get syncResultStream => _syncResultController.stream;

  /// Start auto-sync with configurable interval
  void startAutoSync({
    Duration interval = const Duration(minutes: 15),
  }) {
    stopAutoSync(); // Clear existing timer

    _syncTimer = Timer.periodic(interval, (timer) async {
      await performBatchSync();
    });
  }

  /// Stop auto-sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform batch sync with optimizations
  Future<Either<Failure, BatchSyncResult>> performBatchSync() async {
    // 1. Check premium status (sync is premium feature)
    final isPremium = await premiumService.isPremiumUser();
    if (!isPremium) {
      return Left(PremiumFeatureFailure('Sync requires premium subscription'));
    }

    // 2. Check connectivity
    if (!connectivityService.isOnline()) {
      return Left(NetworkFailure('No internet connection'));
    }

    // 3. Perform full sync
    final startTime = DateTime.now();
    final syncResult = await syncService.syncAll();

    if (syncResult.isLeft()) {
      final failure = (syncResult as Left<Failure, FullSyncResult>).value;

      final batchResult = BatchSyncResult(
        success: false,
        failure: failure,
        startedAt: startTime,
        completedAt: DateTime.now(),
      );

      _syncResultController.add(batchResult);
      return Left(failure);
    }

    final fullSyncResult = (syncResult as Right<Failure, FullSyncResult>).value;

    final batchResult = BatchSyncResult(
      success: true,
      fullSyncResult: fullSyncResult,
      startedAt: startTime,
      completedAt: DateTime.now(),
    );

    _syncResultController.add(batchResult);
    return Right(batchResult);
  }

  /// Manual sync trigger (pull-to-refresh)
  Future<Either<Failure, BatchSyncResult>> manualSync() async {
    return performBatchSync();
  }

  void dispose() {
    stopAutoSync();
    _syncResultController.close();
  }
}
```

---

## Sync Strategy

### Push Strategy (Local → Firestore)

**Trigger Conditions:**
1. Record marked as `isDirty = true` (modified locally)
2. Network connectivity available
3. User is premium subscriber

**Process:**
```
1. Query Drift for records WHERE isDirty = true
2. For each dirty record:
   a. Convert to Firestore document (via adapter)
   b. Increment version number
   c. Set updatedAt = FieldValue.serverTimestamp()
   d. Firestore.set(doc, merge: true)
   e. On success: Mark as synced (isDirty = false, lastSyncAt = now)
3. Batch size: max 50 records per batch (Firestore quota)
```

**Error Handling:**
- Individual record failure: Log error, continue with next
- Batch failure: Retry with exponential backoff
- Network failure: Queue for next sync attempt

### Pull Strategy (Firestore → Local)

**Trigger Conditions:**
1. Periodic background sync (every 15 minutes)
2. Manual refresh (pull-to-refresh)
3. App startup (if premium)

**Process:**
```
1. Get lastSyncAt timestamp from local storage
2. Query Firestore WHERE updatedAt > lastSyncAt
3. For each remote document:
   a. Parse to Domain entity (via adapter with validation)
   b. Check if exists locally (by id)
   c. If exists AND isDirty = true: Conflict resolution (LWW)
   d. If exists AND isDirty = false: Update local
   e. If not exists: Insert new
4. Update lastSyncAt timestamp
```

**Optimization:**
- Incremental sync (only changes since last sync)
- Batch reads (max 50 docs per query)
- Index on `updatedAt` field (Firestore composite index)

### Conflict Resolution Strategy

**Conflict Detection:**
- Record exists locally AND remotely
- Local record has `isDirty = true` (pending push)
- Version numbers differ (local.version ≠ remote.version)

**Resolution: Last Write Wins (LWW)**
```dart
VehicleEntity resolveConflict(
  VehicleEntity local,
  VehicleEntity remote,
) {
  if (remote.version > local.version) {
    // Remote is newer, accept remote changes
    return remote.copyWith(
      isDirty: false,
      lastSyncAt: DateTime.now(),
    );
  } else if (local.version > remote.version) {
    // Local is newer, keep local changes (will push next sync)
    return local.copyWith(
      version: local.version + 1,
      isDirty: true,
    );
  } else {
    // Same version, compare timestamps (edge case)
    final remoteTimestamp = remote.lastSyncAt ?? DateTime(2000);
    final localTimestamp = local.lastSyncAt ?? DateTime(2000);

    return remoteTimestamp.isAfter(localTimestamp) ? remote : local;
  }
}
```

**Alternative Strategies (Future Enhancement):**
- **User Prompt:** Ask user to choose version (for critical data)
- **Field-Level Merge:** Merge non-conflicting fields (complex)
- **Custom Rules:** Business logic-specific resolution

### Soft Delete Strategy

**Purpose:** Sync deletions across devices without data loss.

**Process:**
```
1. User deletes record in UI
2. Repository marks record as isDeleted = true, isDirty = true
3. Record remains in Drift database
4. UI filters out records WHERE isDeleted = true
5. Next sync pushes isDeleted flag to Firestore
6. Remote devices pull and mark local records as deleted
7. Periodic cleanup job (30 days) permanently deletes isDeleted records
```

**Benefits:**
- Recoverable deletions (undo feature)
- Sync works identically to updates
- Audit trail preserved

---

## Firestore Collections Structure

### User-scoped Collections (Security)

All gasometer data is scoped under user UID for security:

```
firestore/
└── users/
    └── {userId}/
        ├── vehicles/ (collection)
        │   └── {vehicleId}/ (document)
        │       ├── id: string
        │       ├── name: string
        │       ├── plate: string
        │       ├── brand: string
        │       ├── model: string
        │       ├── year: number
        │       ├── color: string
        │       ├── fuelType: string (enum)
        │       ├── tankCapacity: number
        │       ├── purchaseDate: timestamp
        │       ├── purchaseValue: number
        │       ├── currentOdometer: number
        │       ├── avgConsumption: number
        │       ├── notes: string
        │       ├── isActive: boolean
        │       ├── version: number
        │       ├── updatedAt: timestamp (server)
        │       └── isDeleted: boolean
        │
        ├── fuel_supplies/ (collection)
        │   └── {supplyId}/ (document)
        │       ├── id: string
        │       ├── vehicleId: string (FK)
        │       ├── date: timestamp
        │       ├── odometer: number
        │       ├── liters: number
        │       ├── pricePerLiter: number
        │       ├── totalCost: number
        │       ├── fuelType: string
        │       ├── isFullTank: boolean
        │       ├── station: string
        │       ├── notes: string
        │       ├── version: number
        │       ├── updatedAt: timestamp
        │       └── isDeleted: boolean
        │
        ├── maintenances/ (collection)
        │   └── {maintenanceId}/ (document)
        │       ├── id: string
        │       ├── vehicleId: string (FK)
        │       ├── type: string (enum)
        │       ├── date: timestamp
        │       ├── odometer: number
        │       ├── cost: number
        │       ├── description: string
        │       ├── provider: string
        │       ├── nextScheduledAt: timestamp
        │       ├── nextScheduledOdometer: number
        │       ├── notes: string
        │       ├── version: number
        │       ├── updatedAt: timestamp
        │       └── isDeleted: boolean
        │
        ├── expenses/ (collection)
        │   └── {expenseId}/ (document)
        │       ├── id: string
        │       ├── vehicleId: string (FK)
        │       ├── type: string (enum)
        │       ├── date: timestamp
        │       ├── amount: number
        │       ├── description: string
        │       ├── category: string
        │       ├── notes: string
        │       ├── version: number
        │       ├── updatedAt: timestamp
        │       └── isDeleted: boolean
        │
        ├── odometer_readings/ (collection)
        │   └── {readingId}/ (document)
        │       ├── id: string
        │       ├── vehicleId: string (FK)
        │       ├── date: timestamp
        │       ├── odometer: number
        │       ├── notes: string
        │       ├── version: number
        │       ├── updatedAt: timestamp
        │       └── isDeleted: boolean
        │
        └── audit_trail/ (collection)
            └── {auditId}/ (document)
                ├── id: string
                ├── entityType: string
                ├── entityId: string
                ├── action: string (enum: create, update, delete)
                ├── userId: string
                ├── timestamp: timestamp
                ├── changes: map (before/after)
                ├── version: number
                ├── updatedAt: timestamp
                └── isDeleted: boolean
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // User data (all gasometer collections)
    match /users/{userId}/{collection}/{docId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId);
      allow delete: if isAuthenticated() && isOwner(userId);
    }
  }
}
```

### Firestore Indexes (Required)

```
Collection: users/{userId}/vehicles
Index: updatedAt (ASC)

Collection: users/{userId}/fuel_supplies
Composite Index: vehicleId (ASC), updatedAt (ASC)

Collection: users/{userId}/maintenances
Composite Index: vehicleId (ASC), updatedAt (ASC)

Collection: users/{userId}/expenses
Composite Index: vehicleId (ASC), updatedAt (ASC)

Collection: users/{userId}/odometer_readings
Composite Index: vehicleId (ASC), updatedAt (ASC)

Collection: users/{userId}/audit_trail
Composite Index: entityId (ASC), updatedAt (ASC)
```

---

## Migration Plan

### Phase 1: Foundation (4-6 hours)

**Tasks:**
1. Create `DriftSyncAdapter<TEntity, TDriftRow>` abstract class
2. Create `SyncResult` and `FullSyncResult` data classes
3. Create `ISyncService` interface
4. Add sync-related failures (NetworkFailure, SyncFailure)
5. Update repositories to support:
   - `getDirtyRecords(): Future<List<TEntity>>`
   - `markAsSynced(String id, String firebaseId): Future<void>`

**Acceptance Criteria:**
- ✅ DriftSyncAdapter compiles with generic constraints
- ✅ ISyncService interface defines contract
- ✅ Repository methods support sync operations

### Phase 2: Adapters Implementation (6-8 hours)

**Tasks:**
1. Implement `VehicleDriftSyncAdapter`
2. Implement `FuelSupplyDriftSyncAdapter`
3. Implement `MaintenanceDriftSyncAdapter`
4. Implement `ExpenseDriftSyncAdapter`
5. Implement `OdometerReadingDriftSyncAdapter`
6. Implement `AuditTrailDriftSyncAdapter`
7. Unit tests for each adapter (conversion correctness)

**Acceptance Criteria:**
- ✅ All adapters implement toDomain/toDrift/toFirestore/fromFirestore
- ✅ Firestore parsing uses Either<Failure, T> with validation
- ✅ 100% test coverage for adapter conversions

### Phase 3: Sync Service (4-6 hours)

**Tasks:**
1. Implement `GasometerDriftSyncService`
2. Implement `syncVehicles()` with push/pull logic
3. Implement sync methods for other entities
4. Implement `syncAll()` orchestration
5. Implement conflict resolution (LWW)
6. Integration tests with mock Firestore

**Acceptance Criteria:**
- ✅ Push sync marks dirty records as synced
- ✅ Pull sync retrieves incremental changes
- ✅ Conflict resolution works correctly
- ✅ Integration tests pass with 80% coverage

### Phase 4: Background Sync (2-3 hours)

**Tasks:**
1. Implement `GasometerBatchSyncService`
2. Add premium check integration (RevenueCat)
3. Add connectivity monitoring
4. Add auto-sync timer (15min interval)
5. Add sync result stream for UI notifications
6. Unit tests for batch service

**Acceptance Criteria:**
- ✅ Auto-sync triggers every 15 minutes
- ✅ Manual sync works via pull-to-refresh
- ✅ Premium gate prevents non-premium sync
- ✅ UI receives sync status updates

### Phase 5: UI Integration & Polish (2-3 hours)

**Tasks:**
1. Add sync status indicator in UI (AppBar)
2. Add pull-to-refresh for manual sync
3. Add sync settings page (interval, auto-sync toggle)
4. Add sync history log (audit trail)
5. Add error notifications for sync failures
6. Update `GasometerSyncConfig` with service initialization

**Acceptance Criteria:**
- ✅ User sees sync status (syncing/synced/error)
- ✅ Pull-to-refresh triggers manual sync
- ✅ Settings allow configuring sync behavior
- ✅ Error messages are user-friendly

### Phase 6: Firestore Setup & Testing (2-3 hours)

**Tasks:**
1. Deploy Firestore security rules
2. Create Firestore indexes (composite indexes)
3. End-to-end testing:
   - Multi-device sync (2 emulators)
   - Conflict scenarios
   - Offline → Online sync
4. Performance testing (1000+ records)
5. Documentation update (README)

**Acceptance Criteria:**
- ✅ Security rules deployed and tested
- ✅ Indexes created (no query errors)
- ✅ E2E tests pass on multiple devices
- ✅ Performance acceptable (<3s for 1000 records)
- ✅ README documents sync architecture

---

## Testing Strategy

### Unit Tests (Priority: HIGH)

**Adapter Tests (6 test files):**
```dart
// vehicle_drift_sync_adapter_test.dart
void main() {
  late VehicleDriftSyncAdapter adapter;

  setUp(() {
    adapter = VehicleDriftSyncAdapter();
  });

  group('VehicleDriftSyncAdapter', () {
    test('toDomain converts VehicleTableData to VehicleEntity', () {
      // Arrange
      final row = VehicleTableData(/* ... */);

      // Act
      final entity = adapter.toDomain(row);

      // Assert
      expect(entity.id, row.id);
      expect(entity.name, row.name);
      expect(entity.firebaseId, row.firebaseId);
    });

    test('toDrift converts VehicleEntity to VehiclesCompanion', () {
      // Arrange
      final entity = VehicleEntity(/* ... */);

      // Act
      final companion = adapter.toDrift(entity);

      // Assert
      expect(companion.id.value, entity.id);
      expect(companion.name.value, entity.name);
    });

    test('toFirestore converts VehicleEntity to Map', () {
      // Arrange
      final entity = VehicleEntity(/* ... */);

      // Act
      final doc = adapter.toFirestore(entity);

      // Assert
      expect(doc['id'], entity.id);
      expect(doc['name'], entity.name);
      expect(doc, containsPair('version', entity.version));
    });

    test('fromFirestore converts valid Map to VehicleEntity', () {
      // Arrange
      final doc = {
        'id': 'v1',
        'name': 'My Car',
        'plate': 'ABC-1234',
        // ... all fields
      };

      // Act
      final result = adapter.fromFirestore(doc);

      // Assert
      expect(result.isRight(), true);
      final entity = (result as Right<Failure, VehicleEntity>).value;
      expect(entity.id, 'v1');
      expect(entity.name, 'My Car');
    });

    test('fromFirestore returns ValidationFailure on missing fields', () {
      // Arrange
      final doc = {'id': 'v1'}; // Missing 'name'

      // Act
      final result = adapter.fromFirestore(doc);

      // Assert
      expect(result.isLeft(), true);
      final failure = (result as Left<Failure, VehicleEntity>).value;
      expect(failure, isA<ValidationFailure>());
    });

    test('fromFirestore returns DataParseFailure on invalid types', () {
      // Arrange
      final doc = {'id': 'v1', 'name': 123}; // Invalid type

      // Act
      final result = adapter.fromFirestore(doc);

      // Assert
      expect(result.isLeft(), true);
      final failure = (result as Left<Failure, VehicleEntity>).value;
      expect(failure, isA<DataParseFailure>());
    });
  });
}
```

**Sync Service Tests:**
```dart
// gasometer_drift_sync_service_test.dart
void main() {
  late GasometerDriftSyncService syncService;
  late MockVehicleRepository mockVehicleRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockAuthService mockAuthService;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    mockFirestore = MockFirebaseFirestore();
    mockAuthService = MockAuthService();
    mockConnectivityService = MockConnectivityService();

    syncService = GasometerDriftSyncService(
      vehicleRepository: mockVehicleRepository,
      // ... other dependencies
      firestore: mockFirestore,
      authService: mockAuthService,
      connectivityService: mockConnectivityService,
    );
  });

  group('syncVehicles', () {
    test('returns NetworkFailure when offline', () async {
      // Arrange
      when(() => mockConnectivityService.isOnline()).thenReturn(false);

      // Act
      final result = await syncService.syncVehicles();

      // Assert
      expect(result.isLeft(), true);
      final failure = (result as Left).value;
      expect(failure, isA<NetworkFailure>());
    });

    test('pushes dirty vehicles to Firestore', () async {
      // Arrange
      when(() => mockConnectivityService.isOnline()).thenReturn(true);
      when(() => mockAuthService.currentUser).thenAnswer((_) async => MockUser(uid: 'user1'));

      final dirtyVehicles = [VehicleEntity(/* ... isDirty: true */)];
      when(() => mockVehicleRepository.getDirtyRecords())
          .thenAnswer((_) async => Right(dirtyVehicles));

      // Act
      final result = await syncService.syncVehicles();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockFirestore.collection('users').doc('user1').collection('vehicles').doc(any()).set(any(), any())).called(1);
    });

    test('pulls remote changes and updates local', () async {
      // Arrange
      when(() => mockConnectivityService.isOnline()).thenReturn(true);
      when(() => mockAuthService.currentUser).thenAnswer((_) async => MockUser(uid: 'user1'));
      when(() => mockVehicleRepository.getDirtyRecords()).thenAnswer((_) async => Right([]));

      final remoteDoc = MockQueryDocumentSnapshot(data: {
        'id': 'v1',
        'name': 'Remote Car',
        // ... all fields
      });

      when(() => mockFirestore.collection('users').doc('user1').collection('vehicles').where(any(), any()).get())
          .thenAnswer((_) async => MockQuerySnapshot(docs: [remoteDoc]));

      // Act
      final result = await syncService.syncVehicles();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockVehicleRepository.update(any())).called(1);
    });

    test('resolves conflicts using LWW strategy', () async {
      // Arrange
      final localVehicle = VehicleEntity(id: 'v1', version: 2, isDirty: true);
      final remoteVehicle = VehicleEntity(id: 'v1', version: 3, isDirty: false);

      when(() => mockVehicleRepository.getById('v1')).thenAnswer((_) async => Right(localVehicle));

      // Act
      final resolved = syncService._resolveConflictLWW(localVehicle, remoteVehicle);

      // Assert
      expect(resolved.version, 3); // Remote wins
      expect(resolved.isDirty, false);
    });
  });
}
```

### Integration Tests (Priority: MEDIUM)

**Multi-Device Sync:**
```dart
// integration_test/sync_multi_device_test.dart
void main() {
  testWidgets('Vehicle created on Device A syncs to Device B', (tester) async {
    // Setup: 2 app instances with different user sessions
    final deviceA = await setupApp(userId: 'user1');
    final deviceB = await setupApp(userId: 'user1');

    // Device A: Create vehicle
    await deviceA.createVehicle(name: 'My Car');

    // Device A: Trigger sync
    await deviceA.syncService.syncAll();

    // Device B: Pull sync
    await deviceB.syncService.syncAll();

    // Verify: Vehicle exists on Device B
    final vehicles = await deviceB.vehicleRepository.getAll();
    expect(vehicles.length, 1);
    expect(vehicles.first.name, 'My Car');
  });
}
```

### Conflict Scenario Tests (Priority: HIGH)

```dart
test('Conflict: Both devices modify same vehicle offline', () async {
  // Device A offline: Update vehicle name to 'Car A'
  final vehicleA = vehicle.copyWith(name: 'Car A', version: 2, isDirty: true);

  // Device B offline: Update vehicle name to 'Car B'
  final vehicleB = vehicle.copyWith(name: 'Car B', version: 2, isDirty: true);

  // Device A goes online, syncs first
  await syncServiceA.syncVehicles(); // Pushes 'Car A' with version 3

  // Device B goes online, syncs second
  await syncServiceB.syncVehicles(); // Pulls 'Car A', resolves to version 3 (LWW)

  // Verify: Device B accepted remote changes
  final finalVehicle = await repositoryB.getById(vehicle.id);
  expect(finalVehicle.name, 'Car A'); // Remote won
  expect(finalVehicle.version, 3);
});
```

### Performance Tests (Priority: MEDIUM)

```dart
test('Sync 1000 vehicles completes in <3 seconds', () async {
  // Arrange
  final vehicles = List.generate(1000, (i) => VehicleEntity(/* ... */));
  await repository.createBatch(vehicles);

  // Act
  final stopwatch = Stopwatch()..start();
  await syncService.syncVehicles();
  stopwatch.stop();

  // Assert
  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});
```

---

## Consequences

### Positive Consequences

1. **Offline-First Guaranteed:**
   - App fully functional without internet
   - Drift remains source of truth
   - No UI blocking during sync

2. **Type-Safe Multi-Representation:**
   - Compile-time safety with Drift code generation
   - Domain layer clean (no Drift/Firestore dependencies)
   - Adapter pattern isolates conversion logic

3. **Conflict Resolution Built-In:**
   - Last Write Wins prevents data loss
   - Version tracking enables conflict detection
   - Extendable to user-prompt resolution

4. **Performance Optimized:**
   - Incremental sync (only changes since lastSyncAt)
   - Batch operations (max 50 items)
   - Background worker prevents UI impact

5. **Multi-Device Support:**
   - Users can switch devices seamlessly
   - Real-time sync via background worker
   - Premium feature differentiation

6. **Audit Trail:**
   - All changes tracked in AuditTrail table
   - Sync history for debugging
   - User activity monitoring

7. **Scalable Architecture:**
   - Generic `DriftSyncAdapter<TEntity, TDriftRow>`
   - Easy to add new entities
   - Repository pattern supports testing

### Negative Consequences

1. **Triple Data Representation:**
   - **Drift Row** (SQLite schema)
   - **Domain Entity** (business logic)
   - **Firestore Document** (JSON)
   - **Impact:** More conversion code, potential bugs in adapters

2. **Implementation Effort:**
   - 6 concrete adapters to implement
   - Complex sync logic (push/pull/conflict)
   - Extensive testing required (unit + integration + E2E)
   - **Estimate:** 18-25 hours total

3. **Firestore Costs:**
   - Incremental reads (1 read per changed document)
   - Background sync every 15min (96 sync operations/day)
   - **Mitigation:** Premium-only feature, batch limits

4. **Conflict Resolution Limitations:**
   - LWW may lose user changes in edge cases
   - No field-level merge (all-or-nothing)
   - **Mitigation:** Future enhancement for user-prompt resolution

5. **Testing Complexity:**
   - Multi-device scenarios hard to test
   - Firestore emulator required for integration tests
   - Network failure scenarios need mocking

6. **Maintenance Burden:**
   - Schema changes require updates in 3 places (Drift + Domain + Firestore)
   - Breaking changes need migration strategy
   - **Mitigation:** Version field enables gradual migrations

---

## Alternatives Considered

### Alternative 1: Single Representation (Firestore-First)

**Description:** Use Firestore as source of truth, Drift as cache only.

**Pros:**
- Simpler architecture (no bidirectional sync)
- No conflict resolution needed (server always wins)
- Less conversion code

**Cons:**
- ❌ Requires internet for all operations (not offline-first)
- ❌ Slower UI (network latency on every CRUD)
- ❌ Complex cache invalidation logic

**Decision:** Rejected due to offline-first requirement.

### Alternative 2: Firestore Cloud Functions Sync

**Description:** Trigger Cloud Functions on Firestore changes, push to FCM, client pulls.

**Pros:**
- Real-time sync (subsecond latency)
- Server-side conflict resolution
- Push notifications on changes

**Cons:**
- ❌ Higher cost (Cloud Functions + FCM)
- ❌ More complex backend (serverless functions)
- ❌ Overkill for current scale (single user per vehicle)

**Decision:** Rejected, can be future enhancement.

### Alternative 3: Manual Sync Only (No Background Worker)

**Description:** Implement adapters and sync service, but no auto-sync.

**Pros:**
- Lower battery consumption
- User control over sync timing
- Simpler implementation (no Timer management)

**Cons:**
- ❌ Poor UX (users forget to sync)
- ❌ Higher conflict probability (longer offline periods)
- ❌ Data loss risk if device damaged between syncs

**Decision:** Rejected, background sync critical for reliability.

---

## Implementation Checklist

### Phase 1: Foundation
- [ ] Create `lib/database/adapters/drift_sync_adapter.dart`
- [ ] Create `lib/core/sync/models/sync_result.dart`
- [ ] Create `lib/core/sync/interfaces/i_sync_service.dart`
- [ ] Add `NetworkFailure`, `SyncFailure` to `core/errors/failures.dart`
- [ ] Update repositories with `getDirtyRecords()` and `markAsSynced()`

### Phase 2: Adapters
- [ ] Implement `VehicleDriftSyncAdapter`
- [ ] Implement `FuelSupplyDriftSyncAdapter`
- [ ] Implement `MaintenanceDriftSyncAdapter`
- [ ] Implement `ExpenseDriftSyncAdapter`
- [ ] Implement `OdometerReadingDriftSyncAdapter`
- [ ] Implement `AuditTrailDriftSyncAdapter`
- [ ] Unit tests for all adapters (100% coverage)

### Phase 3: Sync Service
- [ ] Implement `GasometerDriftSyncService`
- [ ] Implement `syncVehicles()` with push/pull
- [ ] Implement sync methods for other 5 entities
- [ ] Implement `syncAll()` orchestration
- [ ] Implement LWW conflict resolution
- [ ] Integration tests with mock Firestore (80% coverage)

### Phase 4: Background Sync
- [ ] Implement `GasometerBatchSyncService`
- [ ] Add premium check (RevenueCat integration)
- [ ] Add connectivity monitoring
- [ ] Add auto-sync timer (15min interval)
- [ ] Add manual sync trigger
- [ ] Unit tests for batch service

### Phase 5: UI Integration
- [ ] Add sync status indicator (AppBar badge)
- [ ] Add pull-to-refresh for manual sync
- [ ] Add sync settings page (interval, toggle)
- [ ] Add sync history log page
- [ ] Add error notifications (SnackBar/Toast)
- [ ] Update `GasometerSyncConfig` initialization

### Phase 6: Firestore & Testing
- [ ] Deploy Firestore security rules
- [ ] Create Firestore composite indexes
- [ ] E2E test: Multi-device sync
- [ ] E2E test: Conflict scenarios
- [ ] E2E test: Offline → Online sync
- [ ] Performance test: 1000+ records
- [ ] Update README with sync architecture docs

---

## References

### Technical Documentation

- **Drift Official Docs:** https://drift.simonbinder.eu/docs/
- **Firestore Sync Best Practices:** https://firebase.google.com/docs/firestore/best-practices
- **RevenueCat Integration:** https://docs.revenuecat.com/docs/flutter

### Monorepo Standards

- **Clean Architecture:** `.claude/agents/flutter-architect.md`
- **Riverpod State Management:** `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`
- **Error Handling:** `packages/core/lib/errors/failures.dart`
- **Testing with Mocktail:** `app-plantis/test/` (Gold Standard)

### Related ADRs

- ADR-002: Hive to Drift Migration (Completed 2025-11-06)
- ADR-003: Premium Features with RevenueCat (Pending)

---

## Approval & Sign-off

**Architect Recommendation:** APPROVED
**Estimated Effort:** 18-25 hours
**Risk Level:** MEDIUM (Complex sync logic, multi-device testing required)
**Priority:** HIGH (Critical for multi-device users and data resilience)

**Next Steps:**
1. Review ADR with development team
2. Allocate 1-2 week sprint for implementation
3. Begin Phase 1 (Foundation) immediately
4. Daily standups to track progress and blockers

**Success Metrics:**
- ✅ 100% offline functionality maintained
- ✅ Sync completes in <3s for 1000 records
- ✅ 0 data loss in conflict scenarios
- ✅ 80%+ test coverage
- ✅ 0 Firestore security rule violations

---

**Document Version:** 1.0
**Last Updated:** 2025-11-08
**Author:** Flutter Architecture Team
**Reviewers:** [To be assigned]
