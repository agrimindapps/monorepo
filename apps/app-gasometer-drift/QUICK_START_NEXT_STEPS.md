# 🚀 Guia Rápido - Próximos Passos

## ✅ Estado Atual
- ✅ Hive removido completamente
- ✅ Drift 100% funcional
- ✅ 22 providers Riverpod prontos
- ✅ Zero erros de compilação

---

## 📋 Checklist - Feature Vehicles (PRIMEIRO)

### 1. Limpar Model ✏️
**Arquivo:** `/lib/features/vehicles/data/models/vehicle_model.dart`

**Remover:**
```dart
@HiveType(typeId: 10)                    // ❌ DELETE
@HiveField(0) final String id;           // ❌ DELETE @HiveField
factory VehicleModel.fromHiveMap(...)    // ❌ DELETE method
Map<String, dynamic> toHiveMap()         // ❌ DELETE method
```

**Manter:**
```dart
toJson()                                 // ✅ KEEP
fromJson()                               // ✅ KEEP
```

### 2. Converter Data Source 🔄
**Crie ou Atualize:** `/lib/features/vehicles/data/datasources/vehicle_local_datasource.dart`

**ANTES (Hive):**
```dart
class VehicleLocalDataSource {
  final Box<VehicleModel> _box;
  
  Future<List<VehicleModel>> getVehiclesByUser(String userId) async {
    return _box.values.where((v) => v.userId == userId).toList();
  }
  
  Future<void> addVehicle(VehicleModel vehicle) async {
    await _box.put(vehicle.id, vehicle);
  }
}
```

**DEPOIS (Drift):**
```dart
class VehicleLocalDataSource {
  final VehicleRepository _repository;
  
  VehicleLocalDataSource(this._repository);
  
  Future<List<VehicleData>> getVehiclesByUser(String userId) async {
    return _repository.findByUserId(userId);
  }
  
  Future<VehicleData> addVehicle(VehicleCompanion vehicle) async {
    return _repository.create(vehicle);
  }
}
```

### 3. Atualizar ViewModel/Controller 🎮
**Arquivo:** `/lib/features/vehicles/presentation/...`

**ANTES:**
```dart
class VehicleViewModel {
  final Box<VehicleModel> _box;
  
  List<VehicleModel> get vehicles => _box.values.toList();
  
  Future<void> addVehicle(VehicleModel vehicle) async {
    await _box.put(vehicle.id, vehicle);
  }
}
```

**DEPOIS (Riverpod):**
```dart
@riverpod
class VehicleController extends _$VehicleController {
  @override
  FutureOr<void> build() {}
  
  Future<void> addVehicle({
    required String userId,
    required String name,
    required String plate,
    // ... outros campos
  }) async {
    final repository = ref.read(vehicleRepositoryProvider);
    
    await repository.create(
      VehiclesCompanion.insert(
        userId: userId,
        name: name,
        plate: plate,
        // ... outros campos
      ),
    );
  }
  
  Future<void> updateVehicle(String id, VehiclesCompanion vehicle) async {
    final repository = ref.read(vehicleRepositoryProvider);
    await repository.update(id, vehicle);
  }
  
  Future<void> deleteVehicle(String id) async {
    final repository = ref.read(vehicleRepositoryProvider);
    await repository.softDelete(id);
  }
}
```

### 4. Atualizar UI (Pages/Widgets) 📱

**ANTES:**
```dart
class VehiclesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VehicleModel>>(
      stream: watchVehicles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        final vehicles = snapshot.data ?? [];
        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) => VehicleCard(vehicle: vehicles[index]),
        );
      },
    );
  }
}
```

**DEPOIS (Riverpod + AsyncValue):**
```dart
class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assumindo que você tem o userId disponível
    final userId = ref.watch(currentUserIdProvider);
    
    final vehiclesAsync = ref.watch(vehiclesStreamProvider(userId));
    
    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return Center(child: Text('Nenhum veículo cadastrado'));
        }
        
        return ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(
              vehicle: vehicle,
              onTap: () {
                // Navegar para detalhes
              },
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
    );
  }
}
```

### 5. Testar CRUD Completo ✅

**Checklist de Testes:**
- [ ] Listar veículos do usuário
- [ ] Adicionar novo veículo
- [ ] Editar veículo existente
- [ ] Deletar veículo (soft delete)
- [ ] Filtrar veículos
- [ ] Buscar por placa
- [ ] UI atualiza automaticamente (reactive)
- [ ] Loading states funcionam
- [ ] Error states funcionam

---

## 🔁 Repetir Para Outras Features

### Ordem Recomendada:
1. ✅ **Vehicles** ← COMEÇAR AQUI
2. **FuelSupplies** (depende de Vehicles)
3. **Maintenances** (depende de Vehicles)
4. **Expenses** (depende de Vehicles)
5. **OdometerReadings** (depende de Vehicles)

### Mesmo Processo Para Cada:
1. Limpar model (remover Hive)
2. Converter data source
3. Atualizar ViewModel/Controller
4. Atualizar UI
5. Testar

---

## 📚 Providers Disponíveis

### Database
```dart
final database = ref.read(gasometerDatabaseProvider);
```

### Repositories
```dart
final vehicleRepo = ref.read(vehicleRepositoryProvider);
final fuelSupplyRepo = ref.read(fuelSupplyRepositoryProvider);
final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
final expenseRepo = ref.read(expenseRepositoryProvider);
final odometerRepo = ref.read(odometerReadingRepositoryProvider);
```

### Stream Providers (UI Reactive)
```dart
// Veículos por usuário (reactive)
final vehicles = ref.watch(vehiclesStreamProvider(userId));

// Abastecimentos por veículo (reactive)
final fuelSupplies = ref.watch(fuelSuppliesByVehicleStreamProvider(vehicleId));

// Manutenções pendentes por veículo (reactive)
final maintenances = ref.watch(pendingMaintenancesByVehicleStreamProvider(vehicleId));

// Despesas por veículo (reactive)
final expenses = ref.watch(expensesByVehicleStreamProvider(vehicleId));

// Leituras de odômetro por veículo (reactive)
final readings = ref.watch(odometerReadingsByVehicleStreamProvider(vehicleId));
```

### Future Providers (Statistics)
```dart
// Total gasto em combustível
final totalSpent = ref.watch(totalFuelSpentByVehicleFutureProvider(vehicleId));

// Consumo médio
final avgConsumption = ref.watch(averageConsumptionByVehicleFutureProvider(vehicleId));

// Total de despesas
final totalExpenses = ref.watch(totalExpensesByVehicleFutureProvider(vehicleId));

// Última leitura do odômetro
final lastReading = ref.watch(lastOdometerReadingByVehicleFutureProvider(vehicleId));

// Total de quilômetros rodados
final totalDistance = ref.watch(totalDistanceByVehicleFutureProvider(vehicleId));
```

---

## 🛠️ Comandos Úteis

### Ver arquivos com Hive ainda:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-gasometer-drift
grep -r "@HiveType\|@HiveField" lib/features/
```

### Rebuild código gerado:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Análise estática:
```bash
flutter analyze
```

---

## ❓ Dúvidas Comuns

### Q: Como converter IDs?
**A:** Drift usa `int` auto-increment. Use:
```dart
// ANTES (Hive)
final id = const Uuid().v4(); // String UUID

// DEPOIS (Drift)
// Não precisa gerar ID, Drift gera automaticamente
await repository.create(VehiclesCompanion.insert(
  userId: userId,
  name: name,
  // ID é gerado automaticamente
));
```

### Q: Como fazer relacionamentos?
**A:** Use Foreign Keys já configuradas:
```dart
// Buscar abastecimentos de um veículo
final fuelSupplies = await fuelSupplyRepository.findByVehicleId(vehicleId);

// Drift usa FK com CASCADE, então deletar veículo deleta abastecimentos
await vehicleRepository.delete(vehicleId); // Deleta veículo + abastecimentos
```

### Q: Como fazer soft delete?
**A:** Use o método softDelete:
```dart
// Marca isDeleted = true ao invés de deletar
await vehicleRepository.softDelete(vehicleId);

// Buscar apenas não deletados (padrão)
final vehicles = await vehicleRepository.findByUserId(userId);

// Buscar incluindo deletados
final allVehicles = await vehicleRepository.findAll(includeDeleted: true);
```

### Q: Como sincronizar com Firebase depois?
**A:** Drift tem campos de sync prontos:
```dart
// Buscar registros que precisam sync
final dirtyRecords = await repository.findDirty();

// Após sync com sucesso, marcar como limpo
await repository.update(id, VehiclesCompanion(
  isDirty: Value(false),
  lastSyncAt: Value(DateTime.now()),
));
```

---

## 🎯 Meta

**Objetivo:** Migrar todas as 5 features para Drift

**Tempo Estimado:** 4-6 horas

**Progresso Atual:** 0/5 features migradas

---

**Boa sorte! 🚀**

Consulte `MIGRATION_GUIDE.md` para mais detalhes e exemplos completos.
