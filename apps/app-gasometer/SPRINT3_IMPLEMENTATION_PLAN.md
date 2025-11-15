# 🚀 SPRINT 3 - PLANO DE IMPLEMENTAÇÃO E TESTES

## 📋 Objetivos Sprint 3

1. **Implementar as 10 interfaces** nos serviços criados em Sprint 1
2. **Refatorar SyncPushService/SyncPullService** para usar SyncAdapterRegistry
3. **Criar Firebase providers concretos** (IAuthProvider, IAnalyticsProvider)
4. **Adicionar testes unitários** para cada novo serviço
5. **Executar performance testing** e validar impacto
6. **Atualizar DI Module** para injetar interfaces

---

## 📝 Tarefas Detalhadas

### Tarefa 1: Implementar IFuelCrudService em FuelCrudService
**Duração**: 30 min
**Arquivo**: `lib/core/services/fuel_crud_service.dart`

```dart
import 'contracts/i_fuel_crud_service.dart';

class FuelCrudService implements IFuelCrudService {
  @override
  Future<Either<Failure, void>> addFuel(FuelRecordEntity record) async {
    // implementação existente
  }
  
  @override
  Future<Either<Failure, void>> updateFuel(FuelRecordEntity record) async {
    // implementação existente
  }
  
  // ... outros métodos
}
```

---

### Tarefa 2: Implementar ISyncAdapter nos DriftSyncAdapters
**Duração**: 1 hora
**Arquivos**: 
- `lib/core/sync/adapters/vehicle_drift_sync_adapter.dart`
- `lib/core/sync/adapters/fuel_supply_drift_sync_adapter.dart`
- `lib/core/sync/adapters/maintenance_drift_sync_adapter.dart`
- `lib/core/sync/adapters/expense_drift_sync_adapter.dart`
- `lib/core/sync/adapters/odometer_drift_sync_adapter.dart`

```dart
import 'package:gasometer_drift/core/services/contracts/i_sync_adapter.dart';

class VehicleDriftSyncAdapter implements ISyncAdapter {
  @override
  String get entityType => 'vehicle';
  
  @override
  Future<Either<Failure, int>> push(String userId) async {
    // implementação existente
  }
  
  @override
  Future<Either<Failure, int>> pull(String userId) async {
    // implementação existente
  }
  
  @override
  Future<bool> hasPendingData(String userId) async {
    // implementação existente
  }
}
```

---

### Tarefa 3: Refatorar SyncPushService com Registry
**Duração**: 1.5 hora
**Arquivo**: `lib/core/services/sync_push_service.dart`

**Antes** (hard-coded):
```dart
class SyncPushService {
  final VehicleDriftSyncAdapter _vehicleAdapter;
  final FuelSupplyDriftSyncAdapter _fuelAdapter;
  final MaintenanceDriftSyncAdapter _maintenanceAdapter;
  final ExpenseDriftSyncAdapter _expenseAdapter;
  final OdometerDriftSyncAdapter _odometerAdapter;

  Future<SyncPhaseResult> executePush(String userId) async {
    // 5 adaptadores específicos + lógica duplicada
  }
}
```

**Depois** (com registry):
```dart
class SyncPushService implements ISyncPushService {
  final SyncAdapterRegistry _registry;
  
  Future<Either<Failure, SyncPhaseResult>> pushAll(String userId) async {
    final adapters = _registry.getAll();
    int totalSuccess = 0;
    int totalFailure = 0;
    final errors = <String>[];
    
    for (final adapter in adapters) {
      final result = await adapter.push(userId);
      result.fold(
        (failure) => errors.add(failure.message),
        (count) => totalSuccess += count,
      );
    }
    
    return Right(SyncPhaseResult(
      successCount: totalSuccess,
      failureCount: totalFailure,
      errors: errors,
      duration: duration,
    ));
  }
  
  Future<Either<Failure, SyncPhaseResult>> pushByType(
    String userId, 
    String entityType,
  ) async {
    final adapter = _registry.getAdapter(entityType);
    if (adapter == null) {
      return Left(Failure('Adapter not found: $entityType'));
    }
    // push apenas este tipo
  }
}
```

---

### Tarefa 4: Criar Firebase Providers
**Duração**: 1.5 hora
**Novos Arquivos**:

#### `lib/core/services/providers/firebase_auth_provider.dart`
```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../contracts/i_auth_provider.dart';

class FirebaseAuthProvider implements IAuthProvider {
  final FirebaseAuth _firebaseAuth;
  
  FirebaseAuthProvider(this._firebaseAuth);
  
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      return Right(user != null ? _toUserEntity(user) : null);
    } catch (e) {
      return Left(Failure('Auth error: $e'));
    }
  }
  
  // ... outros métodos
}
```

#### `lib/core/services/providers/firebase_analytics_provider.dart`
```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import '../contracts/i_analytics_provider.dart';

class FirebaseAnalyticsProvider implements IAnalyticsProvider {
  final FirebaseAnalytics _analytics;
  
  FirebaseAnalyticsProvider(this._analytics);
  
  @override
  Future<Either<Failure, void>> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure('Analytics error: $e'));
    }
  }
  
  // ... outros métodos
}
```

---

### Tarefa 5: Criar Testes Unitários
**Duração**: 2 horas
**Novos Arquivos**:

#### `test/core/services/fuel_crud_service_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gasometer_drift/core/services/fuel_crud_service.dart';

void main() {
  group('FuelCrudService', () {
    late FuelCrudService service;
    late MockFuelRepository mockRepository;
    
    setUp(() {
      mockRepository = MockFuelRepository();
      service = FuelCrudService(mockRepository);
    });
    
    test('addFuel should return Right(void) on success', () async {
      // arrange
      final record = FuelRecordEntity(...);
      when(mockRepository.addFuel(record))
        .thenAnswer((_) async => const Right(null));
      
      // act
      final result = await service.addFuel(record);
      
      // assert
      expect(result, const Right(null));
      verify(mockRepository.addFuel(record)).called(1);
    });
    
    test('addFuel should return Left(Failure) on error', () async {
      // arrange
      final record = FuelRecordEntity(...);
      when(mockRepository.addFuel(record))
        .thenAnswer((_) async => Left(Failure('Error')));
      
      // act
      final result = await service.addFuel(record);
      
      // assert
      expect(result.isLeft(), true);
    });
  });
}
```

---

### Tarefa 6: Atualizar DI Modules
**Duração**: 45 min
**Arquivo**: `lib/core/di/modules/sync_module.dart`

```dart
// Antes
@Module()
abstract class SyncDIModule {
  @lazySingleton
  GasometerSyncService gasometerSyncService(
    VehicleDriftSyncAdapter vehicleAdapter,
    FuelSupplyDriftSyncAdapter fuelAdapter,
    MaintenanceDriftSyncAdapter maintenanceAdapter,
    ExpenseDriftSyncAdapter expenseAdapter,
    OdometerDriftSyncAdapter odometerAdapter,
  ) => GasometerSyncService(
    vehicleAdapter,
    fuelAdapter,
    maintenanceAdapter,
    expenseAdapter,
    odometerAdapter,
  );
}

// Depois
@Module()
abstract class SyncDIModule {
  @lazySingleton
  SyncAdapterRegistry adapterRegistry(
    VehicleDriftSyncAdapter vehicleAdapter,
    FuelSupplyDriftSyncAdapter fuelAdapter,
    MaintenanceDriftSyncAdapter maintenanceAdapter,
    ExpenseDriftSyncAdapter expenseAdapter,
    OdometerDriftSyncAdapter odometerAdapter,
  ) {
    final registry = SyncAdapterRegistry();
    registry.register(vehicleAdapter);
    registry.register(fuelAdapter);
    registry.register(maintenanceAdapter);
    registry.register(expenseAdapter);
    registry.register(odometerAdapter);
    return registry;
  }
  
  @lazySingleton
  ISyncPushService syncPushService(SyncAdapterRegistry registry) =>
    SyncPushService(registry);
  
  @lazySingleton
  ISyncPullService syncPullService(SyncAdapterRegistry registry) =>
    SyncPullService(registry);
  
  @lazySingleton
  IFuelCrudService fuelCrudService(ILocalStorageRepository storage) =>
    FuelCrudService(storage);
  
  @lazySingleton
  IAuthProvider authProvider(FirebaseAuth firebaseAuth) =>
    FirebaseAuthProvider(firebaseAuth);
}
```

---

## 🧪 Testes a Executar

### Unit Tests
```bash
# Testar cada serviço individualmente
flutter test test/core/services/fuel_crud_service_test.dart
flutter test test/core/services/sync_push_service_test.dart
flutter test test/core/services/firebase_auth_provider_test.dart
```

### Integration Tests
```bash
# Testar integração entre serviços
flutter test test/core/services/integration_test.dart
```

### Performance Tests
```bash
# Medir impacto de performance
flutter test test/core/services/performance_test.dart
```

---

## ⏱️ Timeline Estimada

| Tarefa | Duração | Total |
|--------|---------|-------|
| 1. Implementar interfaces | 30 min | 30 min |
| 2. Implementar ISyncAdapter | 1 h | 1.5 h |
| 3. Refatorar SyncPushService | 1.5 h | 3 h |
| 4. Criar Firebase providers | 1.5 h | 4.5 h |
| 5. Criar testes unitários | 2 h | 6.5 h |
| 6. Atualizar DI modules | 45 min | 7.25 h |
| 7. Executar testes | 1 h | 8.25 h |
| 8. Code review + ajustes | 1.5 h | 9.75 h |
| **TOTAL** | | **~10 horas (1 dia)** |

---

## ✅ Checklist Sprint 3

- [ ] Implementar IFuelCrudService em FuelCrudService
- [ ] Implementar IFuelQueryService em FuelQueryService
- [ ] Implementar IFuelSyncService em FuelSyncService
- [ ] Implementar ISyncAdapter em todos os 5 adapters
- [ ] Implementar ISyncPushService em SyncPushService
- [ ] Implementar ISyncPullService em SyncPullService
- [ ] Refatorar SyncPushService para usar registry
- [ ] Refatorar SyncPullService para usar registry
- [ ] Criar FirebaseAuthProvider
- [ ] Criar FirebaseAnalyticsProvider
- [ ] Criar testes unitários para 5+ serviços
- [ ] Atualizar DI modules
- [ ] Executar testes (todos passando)
- [ ] Performance testing
- [ ] Code review
- [ ] Merge para branch main

---

## 🎯 Resultado Esperado Sprint 3

### SOLID Score
```
Antes Sprint 3: B (80%)
Depois Sprint 3: A- (88%)
Delta: +8 pontos
```

### Código
```
✅ 0 erros de análise
✅ 100% testes passando
✅ Interfaces implementadas
✅ Firebase providers criados
✅ Registry pattern em uso
✅ DI atualizado
```

### Documentação
```
✅ Comentários nos serviços
✅ Exemplos de uso
✅ Guia de extensão
```

---

**Próxima Ação**: Começar Tarefa 1 - Implementar IFuelCrudService
