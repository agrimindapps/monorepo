# 🚨 Violações SOLID Detalhadas - App Plantis

> **Documento Técnico:** Análise detalhada de cada violação dos princípios SOLID encontrada  
> **Target Audience:** Desenvolvedores e Arquitetos de Software  

## 📚 Índice

1. [Single Responsibility Principle (SRP)](#single-responsibility-principle-srp)
2. [Open/Closed Principle (OCP)](#openclosed-principle-ocp)
3. [Liskov Substitution Principle (LSP)](#liskov-substitution-principle-lsp)
4. [Interface Segregation Principle (ISP)](#interface-segregation-principle-isp)
5. [Dependency Inversion Principle (DIP)](#dependency-inversion-principle-dip)

---

## Single Responsibility Principle (SRP)

> *"Uma classe deve ter apenas uma razão para mudar"*

### 🔴 Violação #1: PlantsProvider

**Arquivo:** `/lib/core/riverpod_providers/plants_providers.dart`  
**Severidade:** Crítica  
**Linhas de Código:** 960+  

#### Responsabilidades Identificadas:
1. **Gerenciamento de Estado UI** (linhas 16-50)
2. **Operações CRUD** (linhas 400-600)
3. **Sistema de Filtros** (linhas 200-350)
4. **Cálculos de Cuidado** (linhas 650-800)
5. **Sincronização Offline** (linhas 850-960)
6. **Autenticação** (linhas 100-150)

#### Código Problemático:
```dart
class PlantsStateNotifier extends StateNotifier<AsyncValue<PlantsState>> {
  // ❌ Múltiplas responsabilidades em uma única classe
  
  // Responsabilidade 1: Estado UI
  PlantsState get currentState => state.valueOrNull ?? const PlantsState();
  
  // Responsabilidade 2: CRUD
  Future<bool> addPlant(AddPlantParams params) async { ... }
  Future<bool> updatePlant(UpdatePlantParams params) async { ... }
  Future<bool> deletePlant(String plantId) async { ... }
  
  // Responsabilidade 3: Filtros
  void searchPlants(String query) { ... }
  void setSpaceFilter(String? spaceId) { ... }
  void setSortBy(SortBy sortBy) { ... }
  
  // Responsabilidade 4: Cálculos
  Map<String, CareStatus> _calculateCareStatuses(List<Plant> plants) { ... }
  
  // Responsabilidade 5: Sync
  Future<void> _syncPlants() async { ... }
  
  // Responsabilidade 6: Auth
  bool get _isAuthenticated => AuthStateNotifier.instance.isAuthenticated;
}
```

#### Refatoração Proposta:
```dart
// ✅ Separação de responsabilidades

// 1. Apenas estado UI
class PlantsStateManager extends StateNotifier<AsyncValue<PlantsState>> {
  void updateState(PlantsState newState) { ... }
  void setLoading(bool loading) { ... }
  void setError(String? error) { ... }
}

// 2. Operações de dados
class PlantsDataService {
  Future<List<Plant>> getPlants() async { ... }
  Future<Plant> addPlant(AddPlantParams params) async { ... }
  Future<Plant> updatePlant(UpdatePlantParams params) async { ... }
  Future<void> deletePlant(String plantId) async { ... }
}

// 3. Sistema de filtros
class PlantsFilterService {
  List<Plant> searchPlants(List<Plant> plants, String query) { ... }
  List<Plant> filterBySpace(List<Plant> plants, String? spaceId) { ... }
  List<Plant> sortPlants(List<Plant> plants, SortBy sortBy) { ... }
}

// 4. Cálculos de cuidado
class PlantsCareCalculator {
  Map<String, CareStatus> calculateCareStatuses(List<Plant> plants) { ... }
  CareStatus calculatePlantCareStatus(Plant plant) { ... }
}
```

### 🔴 Violação #2: PlantFormProvider

**Arquivo:** `/lib/features/plants/presentation/providers/plant_form_provider.dart`  
**Severidade:** Crítica  
**Linhas de Código:** 1,035+  

#### Responsabilidades Identificadas:
1. **Estado do Formulário** (linhas 1-100)
2. **Validação** (linhas 200-400)
3. **Operações de Imagem** (linhas 500-700)
4. **Persistência** (linhas 800-900)
5. **Regras de Negócio** (linhas 900-1035)

#### Código Problemático:
```dart
class PlantFormProvider extends ChangeNotifier {
  // ❌ Estado, validação, arquivo, persistência e negócio misturados
  
  // Estado
  String _name = '';
  String? _species;
  List<File> _images = [];
  
  // Validação
  String? validateName(String? value) { ... }
  String? validateSpecies(String? value) { ... }
  bool get isFormValid => _validateAll();
  
  // Operações de arquivo
  Future<void> pickImage() async { ... }
  Future<String?> _uploadImage(File file) async { ... }
  
  // Persistência
  Future<bool> savePlant() async { ... }
  
  // Regras de negócio
  PlantConfigModel _buildPlantConfig() { ... }
  List<TaskConfigModel> _generateDefaultTasks() { ... }
}
```

#### Refatoração Proposta:
```dart
// ✅ Responsabilidades separadas

// 1. Apenas estado
class PlantFormState extends ChangeNotifier {
  String name = '';
  String? species;
  List<String> imageUrls = [];
  
  void updateName(String name) { ... }
  void updateSpecies(String? species) { ... }
  void addImageUrl(String url) { ... }
}

// 2. Validação
class PlantFormValidator {
  String? validateName(String? value) { ... }
  String? validateSpecies(String? value) { ... }
  ValidationResult validateForm(PlantFormState state) { ... }
}

// 3. Gerenciamento de imagens
class PlantImageManager {
  Future<File?> pickImage() async { ... }
  Future<String> uploadImage(File file) async { ... }
  Future<void> deleteImage(String url) async { ... }
}

// 4. Construtor de configuração
class PlantConfigBuilder {
  PlantConfigModel buildConfig(PlantFormState state) { ... }
  List<TaskConfigModel> generateDefaultTasks(String species) { ... }
}
```

### 🔴 Violação #3: TasksProvider

**Arquivo:** `/lib/features/plants/presentation/providers/tasks_provider.dart`  
**Severidade:** Crítica  
**Linhas de Código:** 1,402+  

#### Responsabilidades Excessivas:
- CRUD de tarefas
- Sistema de notificações
- Sincronização offline
- Cálculos de próximas tarefas
- Gerenciamento de segurança
- Estado da UI

---

## Open/Closed Principle (OCP)

> *"Classes devem estar abertas para extensão, mas fechadas para modificação"*

### 🟡 Violação #1: Switch/Case para Tipos de Tarefa

**Arquivo:** `/lib/features/plants/domain/entities/task.dart`  
**Severidade:** Moderada  

#### Código Problemático:
```dart
class TaskService {
  // ❌ Precisa modificar para adicionar novo tipo
  String getTaskDescription(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return 'Regar a planta';
      case TaskType.fertilizing:
        return 'Fertilizar a planta';
      case TaskType.pruning:
        return 'Podar a planta';
      // ❌ Novo tipo requer modificação aqui
      default:
        return 'Tarefa desconhecida';
    }
  }
}
```

#### Refatoração Proposta:
```dart
// ✅ Extensível sem modificação
abstract class TaskTypeHandler {
  String getDescription();
  Duration getDefaultInterval();
  IconData getIcon();
}

class WateringTaskHandler implements TaskTypeHandler {
  @override
  String getDescription() => 'Regar a planta';
  
  @override
  Duration getDefaultInterval() => Duration(days: 3);
  
  @override
  IconData getIcon() => Icons.water_drop;
}

class TaskService {
  final Map<TaskType, TaskTypeHandler> _handlers = {
    TaskType.watering: WateringTaskHandler(),
    TaskType.fertilizing: FertilizingTaskHandler(),
    // ✅ Novos tipos só requerem nova implementação
  };
  
  String getTaskDescription(TaskType type) {
    return _handlers[type]?.getDescription() ?? 'Desconhecido';
  }
}
```

---

## Liskov Substitution Principle (LSP)

> *"Subclasses devem ser substituíveis por suas classes base"*

### ✅ Conformidade: Repositórios

Os repositórios do projeto seguem corretamente o LSP:

```dart
// ✅ Interface bem definida
abstract class IPlantsRepository {
  Future<Either<Failure, List<Plant>>> getPlants();
  Future<Either<Failure, Plant>> addPlant(Plant plant);
}

// ✅ Implementação mantém contrato
class PlantsRepositoryImpl implements IPlantsRepository {
  @override
  Future<Either<Failure, List<Plant>>> getPlants() async {
    // Implementação que respeita o contrato
  }
}
```

---

## Interface Segregation Principle (ISP)

> *"Nenhum cliente deve ser forçado a depender de métodos que não usa"*

### ✅ Conformidade: Interfaces de Notificação

Excelente segregação de interfaces:

```dart
// ✅ Interface focada apenas em permissões
abstract class INotificationPermissionManager {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
}

// ✅ Interface focada apenas em notificações de tarefas
abstract class ITaskNotificationManager {
  Future<void> scheduleTaskNotification(Task task);
  Future<void> cancelTaskNotification(String taskId);
}

// ✅ Cliente usa apenas o que precisa
class TaskService {
  TaskService(this._notificationManager); // Não precisa de permissões
  
  final ITaskNotificationManager _notificationManager;
}
```

---

## Dependency Inversion Principle (DIP)

> *"Módulos de alto nível não devem depender de módulos de baixo nível"*

### 🔴 Violação #1: Dependência de Singleton

**Arquivos:** Múltiplos providers  
**Severidade:** Crítica  

#### Código Problemático:
```dart
class PlantsProvider {
  // ❌ Dependência direta de implementação concreta
  Future<void> loadPlants() async {
    final user = AuthStateNotifier.instance.currentUser;
    if (user == null) return;
    // ...
  }
}
```

#### Refatoração Proposta:
```dart
// ✅ Abstrair com interface
abstract class IAuthStateProvider {
  UserEntity? get currentUser;
  Stream<UserEntity?> get userStream;
  bool get isAuthenticated;
  bool get isInitialized;
}

class PlantsProvider {
  PlantsProvider(this._authProvider); // ✅ Injeção de dependência
  
  final IAuthStateProvider _authProvider;
  
  Future<void> loadPlants() async {
    final user = _authProvider.currentUser;
    if (user == null) return;
    // ...
  }
}
```

### 🟡 Violação #2: Service Locator Anti-pattern

**Arquivo:** `/lib/core/di/injection_container.dart`  
**Severidade:** Moderada  

#### Código Problemático:
```dart
class SomeService {
  void doSomething() {
    // ❌ Service Locator anti-pattern
    final repository = sl<IRepository>();
    repository.getData();
  }
}
```

#### Refatoração Proposta:
```dart
class SomeService {
  // ✅ Injeção de dependência no construtor
  SomeService(this._repository);
  
  final IRepository _repository;
  
  void doSomething() {
    _repository.getData();
  }
}
```

---

## 📋 Checklist de Refatoração

### Single Responsibility Principle
- [ ] Quebrar PlantsProvider em 4 classes especializadas
- [ ] Refatorar PlantFormProvider em responsabilidades únicas
- [ ] Dividir TasksProvider por responsabilidade
- [ ] Separar validação de regras de negócio

### Open/Closed Principle
- [ ] Implementar Strategy Pattern para tipos de tarefa
- [ ] Criar Factory Pattern para criação de objetos
- [ ] Usar polimorfismo em lugar de switch/case

### Dependency Inversion Principle
- [ ] Criar IAuthStateProvider interface
- [ ] Implementar injeção de dependência adequada
- [ ] Eliminar Service Locator onde possível
- [ ] Abstrair todas as dependências concretas

### Métricas de Validação
- [ ] Classes com <300 linhas
- [ ] Métodos com <50 linhas
- [ ] Dependências injetadas via construtor
- [ ] Testes unitários para cada responsabilidade

---

*Este documento serve como guia técnico detalhado para a refatoração das violações SOLID identificadas no app-plantis.*