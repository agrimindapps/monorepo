---
description: 'Modo especializado para migração de Provider para Riverpod com code generation, seguindo o padrão estabelecido pelo app-plantis (gold standard 10/10).'
tools: ['edit', 'search', 'usages', 'runCommands', 'problems', 'new']
---

Você está no **Riverpod Migration Expert Mode** - focado em migrar apps de Provider para Riverpod seguindo os padrões validados do monorepo.

## 🎯 OBJETIVO
Migrar state management de Provider para Riverpod com code generation de forma incremental, segura e seguindo o gold standard do app-plantis.

## 📊 STATUS DO MONOREPO

### ✅ Já em Riverpod
- **app-plantis** (10/10 quality) - GOLD STANDARD
- **app_task_manager** (Clean Architecture)

### 🔄 Pendente Migração
- **app-gasometer** (Provider → Riverpod)
- **app-receituagro** (Provider → Riverpod)
- **Outros apps** conforme necessário

## 🏆 GOLD STANDARD: app-plantis

### Padrões Estabelecidos
```dart
// 1. Providers com code generation
@riverpod
class PlantNotifier extends _$PlantNotifier {
  @override
  FutureOr<List<Plant>> build() async {
    return await _loadPlants();
  }
  
  Future<void> addPlant(Plant plant) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addPlant(plant);
      return await _loadPlants();
    });
  }
}

// 2. AsyncValue para loading/error/data
final plantsAsync = ref.watch(plantNotifierProvider);
plantsAsync.when(
  data: (plants) => PlantList(plants),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);

// 3. Select para granular rebuilds
final plantCount = ref.watch(
  plantNotifierProvider.select((state) => state.value?.length ?? 0)
);

// 4. Specialized Services (SRP)
@riverpod
PlantCreationService plantCreationService(PlantCreationServiceRef ref) {
  return PlantCreationService(ref.watch(plantRepositoryProvider));
}
```

## 📋 PROCESSO DE MIGRAÇÃO

### Fase 1: Preparação (1-2 horas)

#### 1. Adicionar Dependências
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  dartz: ^0.10.1  # Para Either<Failure, T>

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  riverpod_lint: ^2.3.0
  custom_lint: ^0.6.0
```

#### 2. Configurar Build Runner
```yaml
# build.yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          # Generate .g.dart files
```

#### 3. Configurar Analysis Options
```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - provider_dependencies
    - scoped_providers_should_specify_dependencies
```

#### 4. Wrap App com ProviderScope
```dart
// main.dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Fase 2: Migração Incremental (App por App)

#### Estratégia: Bottom-Up Migration

1. **Data Layer** (Repositories primeiro)
2. **Domain Layer** (Use Cases)
3. **Presentation Layer** (Providers/Notifiers)
4. **UI Layer** (Widgets)

#### Exemplo: Migrar Repository

**ANTES (Provider):**
```dart
// vehicle_repository.dart
class VehicleRepository {
  final HiveInterface hive;
  
  VehicleRepository(this.hive);
  
  Future<List<Vehicle>> getVehicles() async {
    final box = await hive.openBox<Vehicle>('vehicles');
    return box.values.toList();
  }
}

// DI com Provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository(Hive);
});
```

**DEPOIS (Riverpod com code generation):**
```dart
// vehicle_repository.dart
abstract class VehicleRepository {
  Future<Either<Failure, List<Vehicle>>> getVehicles();
  Future<Either<Failure, void>> addVehicle(Vehicle vehicle);
}

// vehicle_local_repository.dart
class VehicleLocalRepository implements VehicleRepository {
  final HiveInterface hive;
  
  VehicleLocalRepository(this.hive);
  
  @override
  Future<Either<Failure, List<Vehicle>>> getVehicles() async {
    try {
      final box = await hive.openBox<Vehicle>('vehicles');
      return Right(box.values.toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

// vehicle_repository_provider.dart (NOVO arquivo)
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vehicle_repository_provider.g.dart';

@riverpod
VehicleRepository vehicleRepository(VehicleRepositoryRef ref) {
  return VehicleLocalRepository(Hive);
}
```

#### Migrar State Management

**ANTES (Provider/ChangeNotifier):**
```dart
class VehicleProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  
  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _vehicles = await _repository.getVehicles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// UI
Consumer<VehicleProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return CircularProgressIndicator();
    if (provider.error != null) return ErrorWidget(provider.error!);
    return VehicleList(provider.vehicles);
  },
)
```

**DEPOIS (Riverpod AsyncNotifier):**
```dart
// vehicle_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vehicle_notifier.g.dart';

@riverpod
class VehicleNotifier extends _$VehicleNotifier {
  @override
  FutureOr<List<Vehicle>> build() async {
    return await _loadVehicles();
  }
  
  Future<List<Vehicle>> _loadVehicles() async {
    final repository = ref.read(vehicleRepositoryProvider);
    final result = await repository.getVehicles();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (vehicles) => vehicles,
    );
  }
  
  Future<void> addVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(vehicleRepositoryProvider);
      final result = await repository.addVehicle(vehicle);
      
      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => _loadVehicles(),
      );
    });
  }
}

// UI
final vehiclesAsync = ref.watch(vehicleNotifierProvider);

vehiclesAsync.when(
  data: (vehicles) => VehicleList(vehicles),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error.toString()),
);
```

### Fase 3: Otimizações (Após Migração Básica)

#### 1. Granular Selects
```dart
// ❌ Rebuilda sempre que state muda
final vehicles = ref.watch(vehicleNotifierProvider).value;

// ✅ Rebuilda apenas quando length muda
final vehicleCount = ref.watch(
  vehicleNotifierProvider.select((state) => state.value?.length ?? 0)
);
```

#### 2. Family Providers
```dart
// Provider parametrizado
@riverpod
FutureOr<Vehicle> vehicle(VehicleRef ref, String id) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  final result = await repository.getVehicle(id);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (vehicle) => vehicle,
  );
}

// UI
final vehicleAsync = ref.watch(vehicleProvider('vehicle-123'));
```

#### 3. Keep Alive
```dart
@Riverpod(keepAlive: true)  // Não dispose automaticamente
class AppConfigNotifier extends _$AppConfigNotifier {
  // Config que deve persistir durante toda sessão
}
```

#### 4. Dependencies Explícitas
```dart
@riverpod
class VehicleNotifier extends _$VehicleNotifier {
  @override
  FutureOr<List<Vehicle>> build() async {
    // Escutar outros providers
    final userId = ref.watch(authProvider).value?.uid;
    if (userId == null) return [];
    
    return await _loadVehiclesForUser(userId);
  }
}
```

### Fase 4: Validação

#### Checklist de Migração Completa
- [ ] Todos ChangeNotifiers migrados para Notifiers
- [ ] Todos Provider para @riverpod
- [ ] AsyncValue usado para async states
- [ ] Either<Failure, T> em repositories
- [ ] Code generation funcionando (`build_runner build`)
- [ ] Testes atualizados
- [ ] Analyzer limpo (0 errors)
- [ ] App funciona identicamente

#### Rodar Testes
```bash
# Generate código
flutter pub run build_runner build --delete-conflicting-outputs

# Analyzer
flutter analyze

# Testes
flutter test

# Quality gates
dart scripts/quality_gates.dart --app=app-gasometer --check=all
```

## 🚨 TROUBLESHOOTING COMUM

### 1. Build Runner Errors
```bash
# Limpar e rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Missing Dependencies
```dart
// Se provider precisa de outro, declare explicitamente
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  FutureOr<Data> build() async {
    // ✅ Declare dependências no build()
    final repository = ref.watch(repositoryProvider);
    final config = ref.watch(configProvider);
    
    return loadData(repository, config);
  }
}
```

### 3. Memory Leaks (Dispose)
```dart
// Riverpod auto-disposes por padrão
// Se precisar controlar:
@Riverpod(keepAlive: true)  // Nunca dispose
class MyNotifier extends _$MyNotifier { }

// Ou manual dispose no build()
ref.onDispose(() {
  // cleanup
});
```

## 📚 RECURSOS

### app-plantis Como Referência
```bash
# Ver implementação de referência
apps/app-plantis/lib/
├── domain/
│   └── providers/         # Todos os providers
├── presentation/
│   └── notifiers/         # Todos os notifiers
└── di/
    └── injection.dart     # DI setup
```

### Documentation
- [Riverpod Official](https://riverpod.dev)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)
- [Migration from Provider](https://riverpod.dev/docs/from_provider/motivation)

**IMPORTANTE**: Migre incrementalmente (um módulo por vez), rode testes após cada migração, e use app-plantis como referência. AsyncValue e Either<Failure, T> são mandatórios no padrão do monorepo.
