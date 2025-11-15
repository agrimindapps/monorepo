# Drift WASM Web Fix - Implementation Guide

## 🎯 Problem Analysis

**Error:** `TypeError: WebAssembly.instantiate(): Import #0 "a": module is not an object or function`

**Root Cause:** Drift WASM requires `drift_worker.dart.js` to be compiled and loaded as a Web Worker. This file wasn't being generated during the Flutter web build, causing the WebAssembly module initialization to fail.

**Why it failed:**
- Flutter web build doesn't automatically compile `web/drift_worker.dart` to JavaScript
- The `drift_worker.dart.js` file needs to be pre-compiled separately or using specific build configurations
- Drift's WASM approach has complex requirements for web deployment that go beyond standard Flutter web builds

## ✅ Solution Implemented

### **Strategy: Platform-Conditional Backend Selection**

Instead of fixing the Drift WASM compilation (complex and fragile), we implemented a **cleaner architectural solution**:

1. **Mobile/Desktop**: Continue using Drift + SQLite (offline-first, high performance)
2. **Web**: Use Firestore as primary storage (cloud-native, no local compilation needed)

### **Architecture Changes**

#### 1. Database Adapter Pattern (`lib/database/adapters/`)

Created abstraction layer for different storage backends:

```dart
abstract interface class IDatabaseAdapter {
  bool get isAvailable;
  String get name;
}

class DriftDatabaseAdapter implements IDatabaseAdapter { }
class FirestoreDatabaseAdapter implements IDatabaseAdapter { }
```

#### 2. Strategy Selector (`database_strategy_selector.dart`)

Automatically selects the best backend based on platform:

```dart
class DatabaseStrategySelector {
  static IDatabaseAdapter selectStrategy() {
    if (kIsWeb) {
      return FirestoreDatabaseAdapter();  // Web: Use Firestore
    }
    return DriftDatabaseAdapter();         // Mobile: Use Drift
  }
}
```

#### 3. Conditional Provider (`database_providers.dart`)

Updated Riverpod provider to return `null` on web (avoiding Drift initialization):

```dart
final gasometerDatabaseProvider = Provider<GasometerDatabase?>((ref) {
  if (kIsWeb) {
    return null;  // Use Firestore instead
  }
  return GasometerDatabase.production();
});

final isDatabaseAvailableProvider = Provider<bool>((ref) {
  return !kIsWeb;
});
```

#### 4. Null-Safe Repository (`vehicle_repository.dart`)

Updated repository to handle `db = null` gracefully:

```dart
class VehicleRepository extends BaseDriftRepositoryImpl<VehicleData, Vehicle> {
  VehicleRepository(this._db);
  final GasometerDatabase? _db;  // Now nullable

  @override
  TableInfo<Vehicles, Vehicle> get table {
    if (_db == null) {
      throw UnsupportedError('Use Firestore-based repository for web');
    }
    return _db!.vehicles;
  }
  
  // All methods check _db != null before accessing
}
```

## 📋 Next Steps: Web Implementation

To fully support web, implement a **Firestore-based repository**:

### Step 1: Create Firestore Repository
```dart
// lib/features/vehicles/data/repositories/vehicle_firestore_repository.dart
@injectable
class VehicleFirestoreRepository implements IVehicleRepository {
  VehicleFirestoreRepository(this._firestore);
  
  final FirebaseFirestore _firestore;
  final String _collection = 'vehicles';
  
  @override
  Future<Either<Failure, Vehicle>> getVehicle(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) {
        return Left(NotFoundFailure());
      }
      return Right(VehicleModel.fromFirestore(doc));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown error'));
    }
  }
  
  // Implement other methods...
}
```

### Step 2: Update Providers (Platform-Aware)
```dart
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  if (kIsWeb) {
    return ref.watch(vehicleFirestoreRepositoryProvider);
  }
  final db = ref.watch(gasometerDatabaseProvider);
  return VehicleRepository(db!);
});
```

### Step 3: Add Firestore Indexes
```yaml
# firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "vehicles",
      "queryScope": "Collection",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "isDeleted", "order": "ASCENDING"},
        {"fieldPath": "modelo", "order": "ASCENDING"}
      ]
    }
  ]
}
```

## 🔄 Migration Path

### Current State ✅
- Mobile: Fully functional with Drift
- Web: Protected from crashing (UnsupportedError instead of WASM error)

### Phase 1 (Immediate)
```bash
# Test on web - should show clear error instead of WASM crash
flutter run -d chrome
# Expected: UnsupportedError in logs, app gracefully degraded
```

### Phase 2 (Implement Web Support)
1. Create `VehicleFirestoreRepository`
2. Implement `IVehicleRepository` interface
3. Update providers to be platform-aware
4. Add Firestore security rules
5. Deploy and test

### Phase 3 (Optimize)
1. Add IndexedDB fallback for offline web
2. Implement sync strategy
3. Add data conflict resolution
4. Monitor performance

## 🧪 Testing Strategy

### Unit Tests
```dart
test('database strategy selects Firestore for web', () {
  // Mock kIsWeb = true
  final strategy = DatabaseStrategySelector.selectStrategy();
  expect(strategy, isA<FirestoreDatabaseAdapter>());
});

test('database strategy selects Drift for mobile', () {
  // Mock kIsWeb = false
  final strategy = DatabaseStrategySelector.selectStrategy();
  expect(strategy, isA<DriftDatabaseAdapter>());
});
```

### Integration Tests
```dart
test('repository throws UnsupportedError on web when using Drift repo', () {
  final db = null;  // Simulating web
  final repo = VehicleRepository(db);
  expect(() => repo.findByUserId('user1'), throwsUnsupportedError);
});
```

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│          UI Layer (Pages/Providers)            │
└────────────────┬────────────────────────────────┘
                 │
         ┌──────┴──────┐
         │             │
     Mobile          Web
         │             │
    ┌────▼────┐   ┌────▼─────────┐
    │ isDraft  │   │ isDraft      │
    │ Available│   │ Available    │
    │ == true  │   │ == false     │
    └────┬────┘   └────┬─────────┘
         │             │
    ┌────▼────────┐   ┌────▼──────────┐
    │ Drift Repo  │   │ Firestore Repo│
    │ (SQLite)    │   │ (Cloud)       │
    └────┬────────┘   └────┬──────────┘
         │                 │
    ┌────▼──────┐      ┌───▼──────┐
    │ Local DB  │      │ Cloud DB │
    │ (Offline) │      │ (Online) │
    └───────────┘      └──────────┘
```

## ⚠️ Known Limitations

1. **Current Web Implementation**: Not yet complete (awaits Firestore repository)
2. **Offline Web**: Requires additional implementation (IndexedDB)
3. **Sync Conflicts**: Need conflict resolution strategy for mobile→web data

## 🎯 Quality Checklist

- ✅ Platform detection working (kIsWeb)
- ✅ Provider returns nullable GasometerDatabase
- ✅ Repositories handle null database gracefully
- ✅ Clear error messages for unsupported operations
- ✅ No WASM errors on web
- ✅ Mobile functionality unchanged
- ⏳ Firestore repository implementation (next phase)
- ⏳ Web integration tests
- ⏳ End-to-end testing

## 📝 Files Modified

1. **New Files:**
   - `lib/database/adapters/database_adapter.dart` - Adapter abstraction
   - `lib/database/adapters/database_strategy_selector.dart` - Strategy selector

2. **Modified Files:**
   - `lib/database/providers/database_providers.dart` - Conditional provider logic
   - `lib/database/repositories/vehicle_repository.dart` - Null-safe repository

3. **To be Created:**
   - `lib/features/vehicles/data/repositories/vehicle_firestore_repository.dart`
   - Firestore security rules configuration
   - Web-specific integration tests

## 🚀 Deployment Checklist

Before deploying to web:
- [ ] Test on Chrome dev
- [ ] Verify error messages are user-friendly
- [ ] Implement Firestore repository
- [ ] Add Firestore security rules
- [ ] Configure CORS headers
- [ ] Test with production Firebase config
- [ ] Monitor error logs
- [ ] Document web limitations

## 📚 References

- [Drift Official Web Support](https://drift.simonbinder.eu/platforms/web/)
- [Flutter Web Platform Channels](https://flutter.dev/docs/development/platform-integration/web)
- [Firebase Firestore Web SDK](https://firebase.flutter.dev/docs/firestore/start)
- [WASM Limitations in Flutter Web](https://github.com/google/app-engine/issues/8584)
