# 🎯 Estratégia Revisada - Migração Hive → Drift

## Situação Atual

✅ **Concluído:**
- Infraestrutura Drift 100% funcional
- Hive removido (dependências + serviços)
- VehicleModel limpo (sem Hive)
- Documentação completa

⚠️ **Problema:**
- Outros models ainda têm código Hive
- Comandos sed removeram campos acidentalmente
- Precisam ser restaurados ou reescritos

## 🚀 Nova Abordagem - Pragmática

### Estratégia: **"Feature-First, Clean Later"**

Em vez de limpar todos os models primeiro (trabalhoso e propenso a erros), vamos:

1. **Criar camada de dados com Drift** (data sources usando repositories)
2. **Atualizar ViewModels/Controllers** para usar Drift
3. **Atualizar UI** para usar providers Drift
4. **Testar funcionalidade**
5. **Limpar models no final** (quando não mais usados)

### Vantagens:
- ✅ Progresso visível mais rápido
- ✅ Testamos Drift funcionando end-to-end
- ✅ Models Hive não causam erros se não usados
- ✅ Podemos limpar models gradualmente
- ✅ Menos risco de quebrar tudo de uma vez

## 📋 Plano Revisado

### Fase 1: Feature Vehicles (FOCO AGORA)

#### 1.1 Criar VehicleDataSource com Drift ✨ PRÓXIMO
```dart
// lib/features/vehicles/data/datasources/vehicle_local_datasource.dart
class VehicleLocalDataSource {
  final VehicleRepository _repository;
  
  VehicleLocalDataSource(this._repository);
  
  Future<List<VehicleData>> getVehiclesByUserId(String userId) =>
      _repository.findByUserId(userId);
  
  Stream<List<VehicleData>> watchVehiclesByUserId(String userId) =>
      _repository.watchByUserId(userId);
  
  Future<VehicleData> addVehicle(VehiclesCompanion vehicle) =>
      _repository.create(vehicle);
  
  // ... outros métodos
}
```

#### 1.2 Criar/Atualizar Repository (Domain Layer)
```dart
// lib/features/vehicles/domain/repositories/i_vehicle_repository.dart
abstract class IVehicleRepository {
  Future<List<VehicleEntity>> getVehiclesByUser(String userId);
  Stream<List<VehicleEntity>> watchVehiclesByUser(String userId);
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle);
  // ...
}

// lib/features/vehicles/data/repositories/vehicle_repository_impl.dart
class VehicleRepositoryImpl implements IVehicleRepository {
  final VehicleLocalDataSource _localDataSource;
  
  // Implementar métodos usando _localDataSource (Drift)
}
```

#### 1.3 Criar Riverpod Providers
```dart
// lib/features/vehicles/presentation/providers/vehicle_providers.dart
@riverpod
VehicleRepository vehicleRepositoryDrift(VehicleRepositoryDriftRef ref) {
  return ref.watch(vehicleRepositoryProvider);
}

@riverpod
Stream<List<VehicleData>> watchUserVehicles(
  WatchUserVehiclesRef ref, 
  String userId,
) {
  return ref.watch(vehiclesStreamProvider(userId));
}
```

#### 1.4 Criar Controller
```dart
// lib/features/vehicles/presentation/controllers/vehicle_controller.dart
@riverpod
class VehicleController extends _$VehicleController {
  @override
  FutureOr<void> build() {}
  
  Future<void> addVehicle({
    required String userId,
    required String name,
    required String plate,
    // ... campos
  }) async {
    final repository = ref.read(vehicleRepositoryProvider);
    await repository.create(VehiclesCompanion.insert(...));
  }
}
```

#### 1.5 Atualizar UI
```dart
// Exemplo: vehicles_page.dart
Consumer(
  builder: (context, ref, child) {
    final userId = ref.watch(currentUserIdProvider);
    final vehiclesAsync = ref.watch(vehiclesStreamProvider(userId));
    
    return vehiclesAsync.when(
      data: (vehicles) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  },
)
```

### Fase 2: Outras Features
Repetir o mesmo processo para:
- FuelSupplies
- Maintenances
- Expenses
- OdometerReadings

### Fase 3: Limpeza Final
- Remover código Hive dos models restantes
- Deletar datasources antigos
- Code review e testes finais

## 🎯 Próxima Ação IMEDIATA

**Criar VehicleLocalDataSource com Drift**

Arquivo: `lib/features/vehicles/data/datasources/vehicle_local_datasource.dart`

Este será o ponto de entrada da camada de dados, substituindo o acesso direto ao Hive.

---

**Status:** Pronto para implementar data source  
**Progresso:** 35% (infraestrutura completa, models parcialmente limpos)  
**ETA:** 3-4 horas restantes
