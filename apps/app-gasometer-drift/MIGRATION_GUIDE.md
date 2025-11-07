# Guia de Migração: Hive → Drift

## 🎯 Objetivo
Substituir completamente o Hive pelo Drift no app-gasometer-drift.
**Sem necessidade de migração de dados** (app não foi lançado ainda).

## 📋 PASSO 1: Remover Dependências do Hive

### 1.1 Atualizar pubspec.yaml

**Remover:**
```yaml
dependencies:
  hive: any
  hive_flutter: any
  
dev_dependencies:
  hive_generator: any  # ← Encontrado no pubspec.yaml
  build_runner: any    # Manter para Drift
```

**Manter/Adicionar:**
```yaml
dependencies:
  # Drift já está adicionado
  drift: ^2.21.0
  drift_flutter: ^0.2.7
  sqlite3_flutter_libs: ^0.5.40
  
dev_dependencies:
  # Drift dev já está adicionado
  drift_dev: ^2.21.2
  build_runner: ^2.4.13
```

### 1.2 Executar
```bash
cd apps/app-gasometer-drift
flutter pub get
```

## 📋 PASSO 2: Deletar Código Hive

### 2.1 Encontrar e Deletar Arquivos Hive

```bash
# Buscar arquivos que usam Hive
cd apps/app-gasometer-drift
grep -r "import.*hive" lib/ --include="*.dart"
grep -r "Hive\." lib/ --include="*.dart"
```

### 2.2 Arquivos Típicos a Deletar

❌ Deletar:
- `lib/core/storage/hive_service.dart` (se existir)
- `lib/core/utils/hive_initializer.dart` (se existir)
- Models com `@HiveType()` e `@HiveField()` annotations
- Repositories que usam `Box<T>`

## 📋 PASSO 3: Atualizar main.dart

### Antes (Hive):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ❌ Remover inicialização do Hive
  await Hive.initFlutter();
  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(FuelSupplyAdapter());
  // ... outros adapters
  
  runApp(MyApp());
}
```

### Depois (Drift):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Drift não precisa de inicialização no main
  // O database é inicializado lazy pelo provider
  
  runApp(
    const ProviderScope(  // Necessário para Riverpod
      child: MyApp(),
    ),
  );
}
```

## 📋 PASSO 4: Converter Features

### 4.1 Exemplo: Feature de Veículos

#### ANTES (Hive):
```dart
// ❌ Model Hive
@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String marca;
  
  // ...
}

// ❌ Repository Hive
class VehicleRepository {
  late Box<Vehicle> _box;
  
  Future<void> init() async {
    _box = await Hive.openBox<Vehicle>('vehicles');
  }
  
  Future<void> addVehicle(Vehicle vehicle) async {
    await _box.add(vehicle);
  }
  
  List<Vehicle> getAllVehicles() {
    return _box.values.toList();
  }
}

// ❌ ViewModel/Controller
class VehicleController extends ChangeNotifier {
  final VehicleRepository _repository;
  List<Vehicle> _vehicles = [];
  
  Future<void> loadVehicles() async {
    _vehicles = _repository.getAllVehicles();
    notifyListeners();
  }
}

// ❌ UI
class VehicleListScreen extends StatefulWidget {
  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late VehicleController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = VehicleController(repository);
    _controller.loadVehicles();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _controller.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _controller.vehicles[index];
        return ListTile(title: Text(vehicle.marca));
      },
    );
  }
}
```

#### DEPOIS (Drift + Riverpod):
```dart
// ✅ Model já existe como VehicleData (no repository)
// Não precisa de annotations

// ✅ Repository já criado
// VehicleRepository já existe em:
// lib/database/repositories/vehicle_repository.dart

// ✅ Provider já criado
// vehicleRepositoryProvider em:
// lib/database/providers/database_providers.dart

// ✅ UI Reativa com Riverpod
class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = 'user123'; // Obter do auth provider
    final vehiclesAsync = ref.watch(activeVehiclesStreamProvider(userId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Veículos')),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(child: Text('Sem veículos'));
          }
          
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return ListTile(
                title: Text('${vehicle.marca} ${vehicle.modelo}'),
                subtitle: Text(vehicle.placa),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showAddVehicleDialog(BuildContext context, WidgetRef ref) {
    // Implementar dialog para adicionar veículo
  }
}
```

### 4.2 Adicionar Veículo

#### ANTES (Hive):
```dart
Future<void> addVehicle() async {
  final vehicle = Vehicle(
    id: uuid.v4(),
    marca: 'Toyota',
    modelo: 'Corolla',
    // ...
  );
  
  await _box.add(vehicle);
}
```

#### DEPOIS (Drift):
```dart
Future<void> addVehicle(WidgetRef ref) async {
  final repo = ref.read(vehicleRepositoryProvider);
  
  final vehicle = VehicleData(
    id: 0, // Auto-increment
    userId: 'user123',
    moduleName: 'gasometer',
    createdAt: DateTime.now(),
    updatedAt: null,
    lastSyncAt: null,
    isDirty: true,
    isDeleted: false,
    version: 1,
    marca: 'Toyota',
    modelo: 'Corolla',
    ano: 2023,
    placa: 'ABC-1234',
    cor: 'Prata',
    odometroInicial: 0.0,
    odometroAtual: 0.0,
    combustivel: 0,
    renavan: '12345678901',
    chassi: 'XYZ123',
    foto: null,
    vendido: false,
    valorVenda: 0.0,
  );
  
  try {
    await repo.insert(vehicle);
    // UI atualiza automaticamente via stream
  } catch (e) {
    // Tratar erro
  }
}
```

## 📋 PASSO 5: Padrões de Conversão

### 5.1 CRUD Operations

| Hive | Drift |
|------|-------|
| `box.add(item)` | `repo.insert(item)` |
| `box.put(key, item)` | `repo.update(item)` |
| `box.get(key)` | `repo.findById(id)` |
| `box.delete(key)` | `repo.delete(id)` ou `repo.softDelete(id)` |
| `box.values.toList()` | `repo.findAll()` |
| `box.clear()` | `repo.deleteAll()` |

### 5.2 Queries

| Hive | Drift |
|------|-------|
| `box.values.where((v) => v.userId == id)` | `repo.findByUserId(id)` |
| `box.values.where((v) => !v.deleted)` | `repo.findActiveVehicles(userId)` |
| Manual sorting/filtering | Queries SQL otimizadas |

### 5.3 Streams/Reactive

| Hive | Drift |
|------|-------|
| `box.watch()` | `ref.watch(streamProvider)` |
| `box.listenable()` | Riverpod streams automáticos |
| `ValueListenable` | `AsyncValue<T>` |

## 📋 PASSO 6: Features Específicas

### 6.1 Abastecimentos (Fuel Supplies)

**Provider já criado:**
```dart
// Listar abastecimentos de um veículo
final suppliesAsync = ref.watch(vehicleFuelSuppliesStreamProvider(vehicleId));

// Total gasto
final totalSpent = await ref.read(vehicleTotalFuelSpentProvider(vehicleId).future);

// Adicionar
final repo = ref.read(fuelSupplyRepositoryProvider);
await repo.insert(fuelSupplyData);
```

### 6.2 Manutenções (Maintenances)

```dart
// Manutenções pendentes
final pendingAsync = ref.watch(pendingMaintenancesStreamProvider(vehicleId));

// Marcar como concluída
final repo = ref.read(maintenanceRepositoryProvider);
await repo.markAsCompleted(maintenanceId);
```

### 6.3 Despesas (Expenses)

```dart
// Despesas por categoria
final categoryStats = await ref.read(expensesByCategoryProvider(vehicleId).future);

// Categorias distintas
final categories = await ref.read(distinctExpenseCategoriesProvider(vehicleId).future);
```

## 📋 PASSO 7: Testes

### 7.1 Testar CRUD Básico

```dart
void main() {
  test('Adicionar e buscar veículo', () async {
    final container = ProviderContainer();
    final repo = container.read(vehicleRepositoryProvider);
    
    final vehicle = VehicleData(/* ... */);
    final id = await repo.insert(vehicle);
    
    final found = await repo.findById(id);
    expect(found, isNotNull);
    expect(found!.marca, vehicle.marca);
  });
}
```

### 7.2 Testar Streams

```dart
test('Stream de veículos atualiza na inserção', () async {
  final container = ProviderContainer();
  final repo = container.read(vehicleRepositoryProvider);
  
  final stream = container.read(activeVehiclesStreamProvider('user123').stream);
  
  await repo.insert(vehicle);
  
  await expectLater(
    stream,
    emits(predicate((List<VehicleData> list) => list.isNotEmpty)),
  );
});
```

## 📋 PASSO 8: Limpeza Final

### 8.1 Deletar dados Hive antigos (opcional)

```dart
// Se necessário limpar dados antigos:
import 'package:path_provider/path_provider.dart';

Future<void> cleanOldHiveData() async {
  final dir = await getApplicationDocumentsDirectory();
  final hiveDir = Directory('${dir.path}/hive');
  
  if (await hiveDir.exists()) {
    await hiveDir.delete(recursive: true);
    print('Dados Hive removidos');
  }
}
```

### 8.2 Verificar imports

```bash
# Buscar imports de Hive restantes
grep -r "import.*hive" lib/ --include="*.dart"

# Não deve retornar nenhum resultado
```

## ✅ Checklist Final

- [ ] Remover dependências Hive do pubspec.yaml
- [ ] Atualizar main.dart (remover Hive.init, adicionar ProviderScope)
- [ ] Converter feature de Veículos
- [ ] Converter feature de Abastecimentos
- [ ] Converter feature de Manutenções
- [ ] Converter feature de Despesas
- [ ] Converter feature de Odômetro
- [ ] Testar CRUD em cada feature
- [ ] Testar UI reativa com streams
- [ ] Testar queries customizadas
- [ ] Remover código Hive antigo
- [ ] Verificar que não há imports de Hive
- [ ] Testar em device real
- [ ] Build release sem erros

## 🚀 Vantagens do Drift

1. **Performance**: SQLite é mais rápido para queries complexas
2. **Type Safety**: Queries compiladas e verificadas em tempo de compilação
3. **Relationships**: Foreign keys com CASCADE
4. **Migrations**: Schema migrations automáticas
5. **Streams**: Notificações granulares de mudanças
6. **Transactions**: Operações atômicas ACID
7. **Testing**: Suporte excelente para testes

## 📚 Recursos

- Documentação completa: `DRIFT_IMPLEMENTATION.md`
- Exemplos de uso: `lib/examples/drift_usage_examples.dart`
- Repositórios: `lib/database/repositories/`
- Providers: `lib/database/providers/`
