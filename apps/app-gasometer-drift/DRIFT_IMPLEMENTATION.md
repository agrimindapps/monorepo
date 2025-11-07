# Drift Implementation - App Gasometer

## ✅ O que foi implementado

### 1. Infraestrutura Base (packages/core)
- ✅ `DriftDatabaseConfig` - Configuração e utilitários de banco
- ✅ `BaseDriftDatabase` - Mixin com operações comuns (transactions, batch, vacuum, stats)
- ✅ `BaseDriftRepository` - Repositório genérico com CRUD + streams
- ✅ Documentação completa e exemplo funcional

### 2. Tabelas do Gasometer (app-gasometer-drift)
- ✅ `Vehicles` - Veículos com todos os campos
- ✅ `FuelSupplies` - Abastecimentos
- ✅ `Maintenances` - Manutenções
- ✅ `Expenses` - Despesas gerais
- ✅ `OdometerReadings` - Leituras de odômetro
- ✅ Foreign keys com CASCADE delete
- ✅ Soft delete (isDeleted flag)
- ✅ Sync control (isDirty, version, lastSyncAt)

### 3. Database Principal
- ✅ `GasometerDatabase` - Classe principal com migrations
- ✅ Queries utilitárias (getVehiclesByUser, getTotalExpenses, etc)
- ✅ Factories: production(), development(), test()
- ✅ Código gerado (270KB) - gasometer_database.g.dart

### 4. Repositórios Completos
- ✅ `VehicleRepository` - 20+ métodos customizados
- ✅ `FuelSupplyRepository` - Queries + cálculos de consumo
- ✅ `MaintenanceRepository` - Pendentes, concluídas, por tipo
- ✅ `ExpenseRepository` - Por categoria, estatísticas
- ✅ `OdometerReadingRepository` - Distâncias, médias por mês
- ✅ Todos com streams reativos
- ✅ Todos com soft delete e sync control

### 5. Providers Riverpod
- ✅ `gasometerDatabaseProvider` - Database singleton
- ✅ Repository providers (5)
- ✅ Stream providers para UI (8)
- ✅ Future providers para estatísticas (9)
- ✅ `syncStateProvider` - Controle de sincronização
- ✅ `dirtyRecordsProvider` - Registros não sincronizados

### 6. Documentação
- ✅ Exemplos de uso completos (drift_usage_examples.dart)
- ✅ Comentários em todos os arquivos
- ✅ Zero erros de compilação

## 📋 Próximos Passos para Completar a Migração

### PASSO 1: Remover Hive
```bash
# 1. Remover dependências do Hive do pubspec.yaml
# 2. Deletar arquivos de models Hive (se existirem)
# 3. Deletar boxes e configurações Hive
```

### PASSO 2: Integrar Drift na Aplicação

#### 2.1 Atualizar main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Não precisa mais inicializar Hive
  // await Hive.initFlutter(); // REMOVER
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

#### 2.2 Atualizar Features que usavam Hive
Substituir todos os locais que usavam Hive boxes por Drift repositories:

**ANTES (Hive):**
```dart
final vehiclesBox = await Hive.openBox<Vehicle>('vehicles');
final vehicles = vehiclesBox.values.toList();
```

**DEPOIS (Drift):**
```dart
final vehicles = await ref.read(vehicleRepositoryProvider).findByUserId(userId);
// OU com stream para UI reativa:
final vehiclesStream = ref.watch(activeVehiclesStreamProvider(userId));
```

### PASSO 3: Adaptar ViewModels/Controllers

Substituir chamadas diretas ao Hive por providers Drift:

```dart
// ANTES
class VehicleViewModel {
  final Box<Vehicle> vehiclesBox;
  
  Future<void> addVehicle(Vehicle vehicle) async {
    await vehiclesBox.add(vehicle);
  }
}

// DEPOIS
class VehicleViewModel {
  final VehicleRepository repository;
  
  Future<void> addVehicle(VehicleData vehicle) async {
    await repository.insert(vehicle);
  }
}
```

### PASSO 4: Atualizar UI para usar Streams

```dart
// Exemplo: Tela de listagem de veículos
class VehicleListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(activeVehiclesStreamProvider(userId));
    
    return vehiclesAsync.when(
      data: (vehicles) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

### PASSO 5: Implementar Sincronização (Opcional)

Se precisar de sincronização com backend:

```dart
// 1. Implementar chamadas API no SyncStateNotifier
// 2. Usar isDirty flag para identificar registros não sincronizados
// 3. Chamar markAsSynced após sucesso

final dirtyVehicles = await vehicleRepo.findDirtyRecords();
for (final vehicle in dirtyVehicles) {
  await api.syncVehicle(vehicle);
  await vehicleRepo.markAsSynced([vehicle.id]);
}
```

## 🔧 Comandos Úteis

### Gerar código Drift (após mudanças nas tabelas)
```bash
cd apps/app-gasometer-drift
flutter pub run build_runner build --delete-conflicting-outputs
```

### Limpar banco (desenvolvimento)
```dart
final db = ref.read(gasometerDatabaseProvider);
await db.clearAllTables();
```

### Verificar integridade do banco
```dart
final db = ref.read(gasometerDatabaseProvider);
final isOk = await db.checkIntegrity();
print('Database OK: $isOk');
```

### Fazer backup
```dart
final db = ref.read(gasometerDatabaseProvider);
final backupPath = await DriftDatabaseConfig.backup(db);
print('Backup criado em: $backupPath');
```

## 📁 Estrutura de Arquivos

```
apps/app-gasometer-drift/
├── lib/
│   ├── database/
│   │   ├── tables/
│   │   │   └── gasometer_tables.dart          # 5 tables
│   │   ├── repositories/
│   │   │   ├── vehicle_repository.dart        # ✅
│   │   │   ├── fuel_supply_repository.dart    # ✅
│   │   │   ├── maintenance_repository.dart    # ✅
│   │   │   ├── expense_repository.dart        # ✅
│   │   │   ├── odometer_reading_repository.dart # ✅
│   │   │   └── repositories.dart              # Barrel export
│   │   ├── providers/
│   │   │   ├── database_providers.dart        # 22 providers
│   │   │   ├── sync_providers.dart            # Sync control
│   │   │   └── providers.dart                 # Barrel export
│   │   ├── gasometer_database.dart            # Main database
│   │   └── gasometer_database.g.dart          # Generated (270KB)
│   ├── examples/
│   │   └── drift_usage_examples.dart          # Como usar
│   └── features/
│       └── ... (suas features aqui)
└── pubspec.yaml
```

## 🎯 Checklist de Migração

- [ ] Remover dependências do Hive do pubspec.yaml
- [ ] Remover imports de Hive dos arquivos
- [ ] Substituir Hive boxes por Drift repositories nas features
- [ ] Atualizar ViewModels/Controllers para usar Riverpod providers
- [ ] Atualizar UI para usar streams (watch)
- [ ] Testar CRUD de cada entidade
- [ ] Testar relacionamentos (cascade delete)
- [ ] Testar queries customizadas
- [ ] Testar sincronização (se aplicável)
- [ ] Deletar código antigo do Hive
- [ ] Testar em device/emulator real
- [ ] Documentar mudanças para o time

## 💡 Dicas

1. **Transição Gradual**: Migre uma feature por vez
2. **Use Streams**: A UI fica reativa automaticamente com `watch`
3. **Soft Delete**: Use `softDelete()` ao invés de `delete()` para manter histórico
4. **Transactions**: Use `executeTransaction` para operações atômicas
5. **Testing**: O Drift tem suporte excelente para testes unitários

## 🚀 Performance

- ✅ SQLite é mais rápido que Hive para queries complexas
- ✅ Índices automáticos em foreign keys
- ✅ Queries compiladas (type-safe)
- ✅ Batch operations para inserções em massa
- ✅ Streams eficientes (apenas notifica quando dados mudam)

## 📚 Recursos

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift GitHub](https://github.com/simolus3/drift)
- Exemplos no arquivo: `lib/examples/drift_usage_examples.dart`
