# UnifiedSyncManager - Guia de Integração (app-gasometer)

## 📋 Visão Geral

O `UnifiedSyncManager` do pacote `core` fornece sincronização offline-first robusta e automática para todas as entidades do app-gasometer que estendem `BaseSyncEntity`.

**✅ Já Implementado:**
- `GasometerSyncConfig` configurado com:
  - VehicleEntity (prioridade ALTA)
  - FuelRecordEntity (prioridade ALTA)
  - MaintenanceEntity (prioridade ALTA)
- Estratégia de conflito: Version-based (segurança para dados financeiros)
- Sincronização automática a cada 3 minutos
- Offline-first: salva local primeiro, sincroniza em background

## 🚀 Como Usar nos Repositórios

### Exemplo Atual (VehicleRepository - Manual Background Sync)

```dart
@override
Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
  // 1. Salva localmente
  final vehicleModel = VehicleModel.fromEntity(vehicle);
  await localDataSource.saveVehicle(vehicleModel);

  // 2. Sync manual em background
  unawaited(_syncVehicleToRemoteInBackground(vehicleModel));

  return Right(vehicleModel.toEntity());
}
```

### Exemplo com UnifiedSyncManager (Recomendado)

```dart
@override
Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
  // UnifiedSyncManager gerencia TUDO automaticamente:
  // - Salva local (Hive)
  // - Marca como dirty (precisa sync)
  // - Sincroniza com Firebase em background
  // - Resolve conflitos usando strategy configurada
  // - Gerencia offline/online transitions
  // - Retry automático em caso de falha

  final result = await UnifiedSyncManager.instance.create<VehicleEntity>(
    'gasometer',
    vehicle,
  );

  return result.fold(
    (failure) => Left(failure),
    (id) => Right(vehicle.copyWith(id: id)),
  );
}
```

### Vantagens do UnifiedSyncManager

✅ **Automático**: Não precisa gerenciar sync manual
✅ **Consistente**: Mesmo padrão em todos os repositórios
✅ **Robusto**: Retry automático, conflict resolution, error handling
✅ **Testável**: Facilita mocking em testes
✅ **Observável**: Streams de status, events, debug info
✅ **Performático**: Batch operations, throttling, smart scheduling

## 📚 API do UnifiedSyncManager

### Create (CRUD)

```dart
// Cria e sincroniza automaticamente
final result = await UnifiedSyncManager.instance.create<VehicleEntity>(
  'gasometer',
  vehicle,
);
// Returns: Either<Failure, String> (ID da entidade criada)
```

### Update

```dart
// Atualiza e marca para sync
final result = await UnifiedSyncManager.instance.update<VehicleEntity>(
  'gasometer',
  vehicleId,
  updatedVehicle,
);
// Returns: Either<Failure, void>
```

### Delete (Soft Delete)

```dart
// Marca como deletado (soft delete) e sincroniza
final result = await UnifiedSyncManager.instance.delete<VehicleEntity>(
  'gasometer',
  vehicleId,
);
// Returns: Either<Failure, void>
```

### FindById

```dart
// Busca local primeiro, depois remoto se necessário
final result = await UnifiedSyncManager.instance.findById<VehicleEntity>(
  'gasometer',
  vehicleId,
);
// Returns: Either<Failure, VehicleEntity?>
```

### FindAll

```dart
// Lista todas as entidades (local + sync background)
final result = await UnifiedSyncManager.instance.findAll<VehicleEntity>(
  'gasometer',
);
// Returns: Either<Failure, List<VehicleEntity>>
```

### FindWhere (Filtros)

```dart
// Busca com filtros personalizados
final result = await UnifiedSyncManager.instance.findWhere<VehicleEntity>(
  'gasometer',
  {'brand': 'Toyota', 'isActive': true},
);
// Returns: Either<Failure, List<VehicleEntity>>
```

### Stream (Realtime Updates)

```dart
// Stream reativo de dados
final stream = UnifiedSyncManager.instance.streamAll<VehicleEntity>('gasometer');
// Returns: Stream<List<VehicleEntity>>?

// Uso em repository:
@override
Stream<List<VehicleEntity>> watchVehicles() {
  return UnifiedSyncManager.instance
      .streamAll<VehicleEntity>('gasometer')
      ?? const Stream.empty();
}
```

### Force Sync (Manual)

```dart
// Força sincronização de todas as entidades
await UnifiedSyncManager.instance.forceSyncApp('gasometer');

// Força sync de uma entidade específica
await UnifiedSyncManager.instance.forceSyncEntity<VehicleEntity>('gasometer');
```

## 📊 Monitoramento e Debug

### Status de Sincronização

```dart
// Obtém status atual
final status = UnifiedSyncManager.instance.getAppSyncStatus('gasometer');
// Returns: SyncStatus (offline, localOnly, syncing, synced)

// Stream de status global
final statusStream = UnifiedSyncManager.instance.globalSyncStatusStream;
// Emite: Map<String, SyncStatus> (status por app)
```

### Eventos de Sincronização

```dart
// Stream de eventos (create, update, delete, sync, conflict, error)
final eventStream = UnifiedSyncManager.instance.syncEventStream;
// Emite: AppSyncEvent (appName, entityType, action, entityId, error)

// Exemplo de uso:
eventStream.listen((event) {
  print('Sync event: ${event.action} on ${event.entityType}');
  if (event.error != null) {
    print('Error: ${event.error}');
  }
});
```

### Debug Info

```dart
// Informações detalhadas para debugging
final debugInfo = UnifiedSyncManager.instance.getAppDebugInfo('gasometer');
print(debugInfo);

// Output:
// {
//   'app_name': 'gasometer',
//   'sync_status': 'synced',
//   'current_user_id': 'user-123',
//   'entities_count': 3,
//   'config': {...},
//   'entities': {
//     'VehicleEntity': {
//       'collection': 'vehicles',
//       'can_sync': true,
//       'unsynced_items_count': 2,
//       ...
//     },
//     ...
//   }
// }
```

## 🔧 Manutenção de Dados

### Limpar Dados Locais

```dart
// Limpa cache local de todas as entidades do app
await UnifiedSyncManager.instance.clearAppData('gasometer');
// Returns: Either<Failure, void>
```

## 🎯 Migração de Repositórios Existentes

### Antes (Manual Sync)

```dart
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource localDataSource;
  final VehicleRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    // 1. Salva local
    final model = VehicleModel.fromEntity(vehicle);
    await localDataSource.saveVehicle(model);

    // 2. Sync manual
    final isConnected = await _isConnected;
    if (isConnected) {
      final userId = await _getCurrentUserId();
      if (userId != null) {
        try {
          await remoteDataSource.saveVehicle(userId, model);
        } catch (e) {
          // Silently fail, sync later
        }
      }
    }

    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    // 1. Load from local
    final localVehicles = await localDataSource.getAllVehicles();

    // 2. Sync in background
    unawaited(_syncInBackground());

    return Right(localVehicles.map((m) => m.toEntity()).toList());
  }

  Future<void> _syncInBackground() async {
    // Complex manual sync logic...
  }
}
```

### Depois (UnifiedSyncManager)

```dart
class VehicleRepositoryImpl implements VehicleRepository {
  // Não precisa mais de: connectivity, localDataSource, remoteDataSource
  // UnifiedSyncManager gerencia tudo!

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    final result = await UnifiedSyncManager.instance.create<VehicleEntity>(
      'gasometer',
      vehicle,
    );

    return result.fold(
      (failure) => Left(failure),
      (id) => Right(vehicle.copyWith(id: id)),
    );
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getAllVehicles() async {
    return await UnifiedSyncManager.instance.findAll<VehicleEntity>('gasometer');
  }

  @override
  Stream<List<VehicleEntity>> watchVehicles() {
    return UnifiedSyncManager.instance.streamAll<VehicleEntity>('gasometer')
        ?? const Stream.empty();
  }
}
```

**Redução de código: ~70%**
**Complexidade: ↓↓↓**
**Confiabilidade: ↑↑↑**

## ⚠️ Notas Importantes

1. **Inicialização**: Chamar `GasometerSyncConfig.configure()` no app startup (main.dart)
2. **Entidades**: Devem estender `BaseSyncEntity` e implementar `toFirebaseMap()` / `fromFirebaseMap()` (✅ já implementado)
3. **IDs**: Gerados automaticamente pelo manager (usar UUIDs)
4. **User Context**: UnifiedSyncManager detecta userId automaticamente via FirebaseAuth
5. **Offline Mode**: Funciona 100% offline, sync automático quando conectar
6. **Conflict Resolution**: Configurado para version-based (segurança financeira)
7. **Performance**: Auto-throttling, batching, e smart scheduling

## 🔄 Próximos Passos (Recomendado)

1. ✅ **Inicializar no app startup** - Adicionar ao main.dart
2. ⚠️ **Migrar VehicleRepository** - Usar como exemplo validação
3. ⚠️ **Migrar FuelRepository** - Aplicar learnings
4. ⚠️ **Migrar MaintenanceRepository** - Completar migração
5. ⚠️ **Remover código legacy** - Limpar datasources manuais e background sync
6. ⚠️ **Adicionar testes** - Testar sync com ProviderContainer

**Tempo estimado**: 2-4 horas (completa migração de todos os repositórios)
**Benefício**: Código 70% menor, mais robusto, mais testável
