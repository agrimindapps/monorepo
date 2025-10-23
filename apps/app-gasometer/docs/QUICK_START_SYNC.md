# Quick Start - Sincronismo no app-gasometer

**Guia Rápido para Novos Desenvolvedores**

---

## 🚀 Setup Inicial (5 minutos)

### 1. Dependências

O app-gasometer usa o `UnifiedSyncManager` do package `core` para sincronização.

```bash
# Instalar dependências
cd apps/app-gasometer
flutter pub get

# Gerar código (se necessário)
dart run build_runner build --delete-conflicting-outputs
```

### 2. Inicialização (main.dart)

O sistema de sincronização é configurado automaticamente na inicialização do app:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configurar DI (GetIt + Injectable)
  await configureDependencies();

  // 2. Configurar sincronização (automático via DI)
  await GasometerSyncConfig.configure();

  // 3. Inicializar auto-sync
  final autoSync = getIt<AutoSyncService>();
  await autoSync.initialize();
  autoSync.start();

  // 4. Inicializar connectivity monitoring
  final connectivitySync = getIt<ConnectivitySyncIntegration>();
  await connectivitySync.initialize();

  runApp(const MyApp());
}
```

**Pronto!** O sistema de sincronização está funcionando. 🎉

---

## 📝 Usar Sincronização em Repositories

### Padrão: UnifiedSyncManager

Todos os repositories usam o `UnifiedSyncManager` para operações CRUD:

```dart
class VehicleRepositoryImpl implements VehicleRepository {
  final UnifiedSyncManager _syncManager = UnifiedSyncManager.instance;

  @override
  Future<Either<Failure, Vehicle>> create(Vehicle vehicle) async {
    try {
      // UnifiedSyncManager cuida de:
      // ✅ Salvar localmente (Hive)
      // ✅ Marcar como pendente de sync
      // ✅ Sincronizar quando online (automático)
      await _syncManager.create('gasometer', vehicle.toEntity());

      return Right(vehicle);
    } catch (e, stackTrace) {
      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> update(Vehicle vehicle) async {
    try {
      await _syncManager.update('gasometer', vehicle.toEntity());
      return Right(vehicle);
    } catch (e, stackTrace) {
      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _syncManager.delete('gasometer', VehicleEntity, id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Vehicle>>> getAll() async {
    try {
      final entities = await _syncManager.getAll<VehicleEntity>('gasometer', VehicleEntity);
      final vehicles = entities.map((e) => Vehicle.fromEntity(e)).toList();
      return Right(vehicles);
    } catch (e, stackTrace) {
      return Left(ExceptionMapper.mapException(e, stackTrace));
    }
  }
}
```

### Quando o Sync Acontece?

1. **Automático (3min)**: Timer periódico sincroniza todas entidades pendentes
2. **Ao reconectar**: Sync imediato quando app volta online
3. **Manual**: `await syncManager.forceSyncApp('gasometer')`

---

## 🔄 Fluxo Típico: Criar Veículo Offline → Online

```dart
// 1. Usuário cria veículo OFFLINE
final vehicle = Vehicle(
  id: uuid.v4(), // ID local temporário
  name: 'Meu Carro',
  licensePlate: 'ABC-1234',
);

final result = await vehicleRepository.create(vehicle);

// ✅ Veículo salvo localmente IMEDIATAMENTE
// ✅ UI atualiza instantaneamente (offline-first)
// ✅ Marcado como "pending sync" automaticamente

// 2. App volta ONLINE (automático)
// ✅ AutoSyncService detecta conectividade
// ✅ UnifiedSyncManager sincroniza veículo com Firebase
// ✅ Firebase pode gerar ID permanente: 'firebase_xyz789'

// 3. ID Reconciliation (automático)
// ✅ DataIntegrityService reconcilia IDs
// ✅ Remove ID local, mantém ID remoto
// ✅ Atualiza referências (FuelRecord.vehicleId, Maintenance.vehicleId)

// RESULTADO FINAL:
// ✅ Sem duplicação
// ✅ Dados sincronizados em todos devices
// ✅ Referências consistentes
```

---

## ⚔️ Conflict Resolution: Multi-Device

**Cenário**: Dois devices editam o mesmo veículo offline

```dart
// Device A (offline - 10:00 AM)
vehicle.name = "Meu Carro A";
vehicle.odometer = 10000;
await repository.update(vehicle);

// Device B (offline - 11:00 AM)
vehicle.name = "Meu Carro B";
vehicle.odometer = 12000;
await repository.update(vehicle);

// Ambos devices voltam online → CONFLITO DETECTADO!

// ✅ RESOLUÇÃO AUTOMÁTICA (VehicleConflictResolver):
// - version: 3 (incrementado)
// - name: "Meu Carro B" (updatedAt mais recente - Device B)
// - odometer: 12000 (max(10000, 12000) - nunca regride!)

// ✅ RESULTADO:
// Ambos devices convergem para a mesma versão (v3)
```

**Estratégias por Entidade**:

| Entidade | Strategy | Exemplo |
|----------|----------|---------|
| Vehicle | Version + Merge | Merge inteligente (odometer max, name recente) |
| FuelSupply | Last Write Wins | Timestamp mais recente vence |
| Maintenance | Last Write Wins | Timestamp mais recente vence |

---

## 🛠️ Operações Comuns

### Forçar Sync Manual

```dart
// Obter serviço
final autoSync = getIt<AutoSyncService>();

// Sync agora (não espera timer de 3min)
await autoSync.syncNow();
```

### Verificar Integridade de Dados

```dart
// Útil antes de gerar relatórios financeiros
final dataIntegrity = getIt<DataIntegrityService>();
final result = await dataIntegrity.verifyDataIntegrity();

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (issues) {
    print('Orphaned fuel records: ${issues['orphaned_fuel_records']}');
    print('Orphaned maintenances: ${issues['orphaned_maintenances']}');
  },
);
```

### Reconciliar IDs Manualmente (raro)

```dart
// Normalmente automático, mas pode ser útil em debugging
final dataIntegrity = getIt<DataIntegrityService>();

await dataIntegrity.reconcileVehicleId(
  'local_abc123',      // ID local temporário
  'firebase_xyz789',   // ID remoto permanente
);
```

### Pausar/Resumir Auto-Sync

```dart
final autoSync = getIt<AutoSyncService>();

// App vai para background
autoSync.pause();

// App volta para foreground
autoSync.resume();
```

---

## 🧪 Testar Sincronização

### 1. Criar Entity de Teste

```dart
test('should create vehicle and sync successfully', () async {
  // Arrange
  final vehicle = Vehicle(
    id: 'test_vehicle_1',
    name: 'Test Car',
    licensePlate: 'TEST-123',
  );

  final mockSyncManager = MockUnifiedSyncManager();
  when(() => mockSyncManager.create('gasometer', any()))
      .thenAnswer((_) async => Future.value());

  final repository = VehicleRepositoryImpl(mockSyncManager);

  // Act
  final result = await repository.create(vehicle);

  // Assert
  expect(result.isRight(), true);
  verify(() => mockSyncManager.create('gasometer', any())).called(1);
});
```

### 2. Testar Conflict Resolution

```dart
test('should resolve vehicle conflict using merge strategy', () {
  // Arrange
  final local = VehicleModel(id: '1', version: 2, odometer: 10000);
  final remote = VehicleModel(id: '1', version: 2, odometer: 12000);

  final resolver = VehicleConflictResolver();

  // Act
  final resolution = resolver.resolve(local, remote);

  // Assert
  expect(resolution.action, ConflictAction.useMerged);
  expect(resolution.resolvedEntity.version, 3);
  expect(resolution.resolvedEntity.odometer, 12000); // max
});
```

---

## 📖 Próximos Passos

1. **Ler documentação completa**: [SYNC_ARCHITECTURE.md](./SYNC_ARCHITECTURE.md)
2. **Estudar exemplo**: `lib/core/sync/examples/unified_vehicle_repository_example.dart`
3. **Rodar testes**: `flutter test test/core/sync/`
4. **Explorar conflitos**: `lib/core/sync/conflict_resolution_strategy.dart`

---

## 🆘 Troubleshooting Rápido

### Sync não está funcionando?

```dart
// 1. Verificar se AutoSync está rodando
final autoSync = getIt<AutoSyncService>();
if (!autoSync.isRunning) {
  autoSync.start();
}

// 2. Verificar conectividade
final connectivityService = getIt<ConnectivityService>();
final isOnline = await connectivityService.isOnline();
print('Online: $isOnline');

// 3. Forçar sync manual
await autoSync.syncNow();
```

### Dados duplicados?

```dart
// Executar verificação de integridade
final dataIntegrity = getIt<DataIntegrityService>();
await dataIntegrity.verifyDataIntegrity();
```

### Performance lenta?

```dart
// Verificar se cache está funcionando
class VehicleRepositoryImpl extends VehicleRepository
    with CachedRepositoryMixin<Vehicle> { // ← Adicionar mixin

  @override
  Duration get cacheTtl => const Duration(minutes: 15);
}
```

---

## 💡 Dicas Pro

1. **Sempre use Either<Failure, T>**: Error handling consistente
2. **Invalide cache após mutations**: `invalidateCache()` após create/update/delete
3. **Verifique integridade periodicamente**: Antes de relatórios financeiros
4. **Log operações financeiras**: Use `FinancialLogger` para auditoria
5. **Teste com múltiplos devices**: Simule conflitos reais

---

**Happy Coding!** 🚀

Para mais detalhes, consulte [SYNC_ARCHITECTURE.md](./SYNC_ARCHITECTURE.md).
