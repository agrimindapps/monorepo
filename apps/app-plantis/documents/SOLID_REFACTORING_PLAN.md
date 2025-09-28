# 🔧 Plano de Refatoração SOLID - App Plantis

> **Documento Estratégico:** Roadmap detalhado para correção das violações SOLID  
> **Timeline:** 6 Sprints (12 semanas)  
> **Objetivo:** Alcançar 85%+ de conformidade SOLID  

## 🎯 Objetivos da Refatoração

### **Metas Quantitativas**
- **Conformidade SOLID**: 60% → 85%+
- **Tamanho médio de classes**: 600+ linhas → <300 linhas
- **Índice de acoplamento**: 45% → <30%
- **Classes God**: 3 → 0
- **Cobertura de testes**: Atual → 80%+

### **Benefícios Esperados**
- ⚡ **Performance de desenvolvimento**: +50% velocidade em novas features
- 🐛 **Redução de bugs**: -70% bugs relacionados a acoplamento
- 🧪 **Testabilidade**: +200% facilidade de teste unitário
- 🔧 **Manutenibilidade**: -60% tempo para correções

---

## 📅 Timeline de Execução

### **Fase 1: Emergencial** (Sprints 1-2) - 4 semanas
**Objetivo:** Resolver violações críticas que bloqueiam desenvolvimento

#### Sprint 1 (Semanas 1-2)
- [ ] **PlantsProvider Refactoring** - Quebrar em 4 classes
- [ ] **IAuthStateProvider Interface** - Abstrair singleton
- [ ] **Testes unitários** para novas classes

#### Sprint 2 (Semanas 3-4)
- [ ] **PlantFormProvider Refactoring** - Separar responsabilidades
- [ ] **Dependency Injection** básica
- [ ] **Integration tests** para fluxos críticos

### **Fase 2: Estrutural** (Sprints 3-4) - 4 semanas
**Objetivo:** Resolver problemas arquiteturais fundamentais

#### Sprint 3 (Semanas 5-6)
- [ ] **TasksProvider Refactoring** - Maior classe do projeto
- [ ] **Service Locator Replacement** - Implementar DI adequado
- [ ] **Interface Creation** para dependências concretas

#### Sprint 4 (Semanas 7-8)
- [ ] **Strategy Pattern Implementation** - Tipos de tarefa
- [ ] **Factory Pattern** para criação de objetos
- [ ] **Code Review** completo das mudanças

### **Fase 3: Otimização** (Sprints 5-6) - 4 semanas
**Objetivo:** Polimento e conformidade total

#### Sprint 5 (Semanas 9-10)
- [ ] **Command Pattern** para operações complexas
- [ ] **Observer Pattern** para eventos
- [ ] **Performance optimization**

#### Sprint 6 (Semanas 11-12)
- [ ] **Final audit** e correções
- [ ] **Documentation update**
- [ ] **Team training** em novos padrões

---

## 🔨 Planos de Refatoração Detalhados

### **1. PlantsProvider → 4 Classes Especializadas**

#### **Antes:** 960 linhas, 6 responsabilidades
```dart
class PlantsStateNotifier extends StateNotifier<AsyncValue<PlantsState>> {
  // ❌ 960 linhas com múltiplas responsabilidades
}
```

#### **Depois:** 4 classes, responsabilidade única cada
```dart
// 1. Estado UI (150 linhas)
class PlantsStateManager extends StateNotifier<AsyncValue<PlantsState>> {
  void updateState(PlantsState newState) { ... }
  void setLoading(bool loading) { ... }
  void setError(String? error) { ... }
}

// 2. Operações de dados (200 linhas)
class PlantsDataService {
  Future<List<Plant>> getPlants() async { ... }
  Future<Plant> addPlant(AddPlantParams params) async { ... }
  Future<Plant> updatePlant(UpdatePlantParams params) async { ... }
  Future<void> deletePlant(String plantId) async { ... }
}

// 3. Sistema de filtros (180 linhas)
class PlantsFilterService {
  List<Plant> searchPlants(List<Plant> plants, String query) { ... }
  List<Plant> filterBySpace(List<Plant> plants, String? spaceId) { ... }
  List<Plant> sortPlants(List<Plant> plants, SortBy sortBy) { ... }
}

// 4. Cálculos de cuidado (150 linhas)
class PlantsCareCalculator {
  Map<String, CareStatus> calculateCareStatuses(List<Plant> plants) { ... }
  CareStatus calculatePlantCareStatus(Plant plant) { ... }
}
```

#### **Implementação Step-by-Step:**

**Semana 1:**
1. Criar interfaces para cada serviço
2. Implementar `PlantsDataService`
3. Testes unitários para `PlantsDataService`

**Semana 2:**
1. Implementar `PlantsFilterService`
2. Implementar `PlantsCareCalculator`
3. Refatorar `PlantsStateManager`
4. Integrar todas as classes
5. Testes de integração

### **2. PlantFormProvider → 4 Classes Especializadas**

#### **Estrutura Atual:** 1,035 linhas
```dart
class PlantFormProvider extends ChangeNotifier {
  // ❌ Estado + Validação + Arquivo + Persistência + Negócio
}
```

#### **Nova Estrutura:**
```dart
// 1. Estado (150 linhas)
class PlantFormState extends ChangeNotifier {
  String name = '';
  String? species;
  List<String> imageUrls = [];
  PlantConfigModel? config;
  
  void updateName(String name) { ... }
  void updateSpecies(String? species) { ... }
}

// 2. Validação (120 linhas)
class PlantFormValidator {
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  ValidationResult validateForm(PlantFormState state) { ... }
  String? validateName(String? value) { ... }
  String? validateSpecies(String? value) { ... }
}

// 3. Gerenciamento de imagens (200 linhas)
class PlantImageManager {
  final IImageService _imageService;
  final IStorageService _storageService;
  
  Future<File?> pickImage() async { ... }
  Future<String> uploadImage(File file) async { ... }
  Future<void> deleteImage(String url) async { ... }
}

// 4. Construtor de configuração (180 linhas)
class PlantConfigBuilder {
  PlantConfigModel buildConfig(PlantFormState state) { ... }
  List<TaskConfigModel> generateDefaultTasks(String species) { ... }
  WateringConfig calculateWateringConfig(String species) { ... }
}
```

### **3. TasksProvider → Arquitetura Modular**

#### **Problema Atual:** 1,402 linhas - maior classe do projeto

#### **Nova Arquitetura:**
```dart
// 1. Coordenador principal (200 linhas)
class TasksCoordinator {
  final TasksDataService _dataService;
  final TasksNotificationService _notificationService;
  final TasksSyncService _syncService;
  final TasksStateManager _stateManager;
  
  Future<void> createTask(CreateTaskParams params) async {
    final task = await _dataService.createTask(params);
    await _notificationService.scheduleNotification(task);
    _stateManager.addTask(task);
  }
}

// 2. Serviço de dados (300 linhas)
class TasksDataService {
  Future<List<Task>> getTasks(String plantId) async { ... }
  Future<Task> createTask(CreateTaskParams params) async { ... }
  Future<Task> updateTask(UpdateTaskParams params) async { ... }
}

// 3. Serviço de notificações (250 linhas)
class TasksNotificationService {
  Future<void> scheduleNotification(Task task) async { ... }
  Future<void> cancelNotification(String taskId) async { ... }
}

// 4. Sincronização (200 linhas)
class TasksSyncService {
  Future<void> syncTasks() async { ... }
  Future<void> handleConflicts(List<TaskConflict> conflicts) async { ... }
}

// 5. Estado (150 linhas)
class TasksStateManager extends StateNotifier<AsyncValue<TasksState>> {
  void addTask(Task task) { ... }
  void updateTask(Task task) { ... }
  void removeTask(String taskId) { ... }
}
```

---

## 🛠️ Ferramentas e Utilitários

### **1. Scripts de Automação**

#### **Analyzer Personalizado**
```dart
// tools/solid_analyzer.dart
class SolidAnalyzer {
  static const int maxClassLines = 300;
  static const int maxMethodLines = 50;
  
  List<SolidViolation> analyzeProject(String projectPath) {
    // Análise automática de violações
  }
}
```

#### **Gerador de Interfaces**
```dart
// tools/interface_generator.dart
class InterfaceGenerator {
  String generateInterface(ClassAnalysis classAnalysis) {
    // Gera interface automaticamente a partir de classe concreta
  }
}
```

### **2. Testes Arquiteturais**

```dart
// test/architecture/solid_tests.dart
void main() {
  group('SOLID Compliance Tests', () {
    test('classes should not exceed 300 lines', () {
      final violations = SolidAnalyzer.analyzeClassSizes();
      expect(violations, isEmpty);
    });
    
    test('should not have concrete dependencies', () {
      final violations = DependencyAnalyzer.findConcreteDependencies();
      expect(violations, isEmpty);
    });
  });
}
```

### **3. Code Review Checklist**

```markdown
## SOLID Review Checklist

### Single Responsibility
- [ ] Classe tem apenas uma razão para mudar?
- [ ] Métodos fazem apenas uma coisa?
- [ ] Nome da classe é específico e claro?

### Open/Closed
- [ ] Extensível sem modificação?
- [ ] Usa polimorfismo em vez de switch/case?
- [ ] Interfaces bem definidas?

### Dependency Inversion
- [ ] Depende de abstrações?
- [ ] Dependências injetadas via construtor?
- [ ] Não usa Service Locator?
```

---

## 📊 Métricas e Monitoramento

### **Dashboard de Métricas SOLID**

```dart
class SolidMetrics {
  double calculateSrpCompliance() {
    // % de classes com responsabilidade única
  }
  
  double calculateDipCompliance() {
    // % de classes usando injeção de dependência
  }
  
  Map<String, dynamic> generateReport() {
    return {
      'srp_compliance': calculateSrpCompliance(),
      'ocp_compliance': calculateOcpCompliance(),
      'lsp_compliance': calculateLspCompliance(),
      'isp_compliance': calculateIspCompliance(),
      'dip_compliance': calculateDipCompliance(),
      'overall_score': calculateOverallScore(),
    };
  }
}
```

### **Alerts Automáticos**

```dart
class SolidAlerts {
  void checkNewCode(GitDiff diff) {
    for (final file in diff.modifiedFiles) {
      if (file.linesAdded > 50 && isClassFile(file)) {
        // Alert: classe pode estar ficando muito grande
      }
      
      if (containsServiceLocatorPattern(file)) {
        // Alert: possível violação de DIP
      }
    }
  }
}
```

---

## 🎓 Training e Knowledge Transfer

### **Workshop 1: SOLID Fundamentals** (2 horas)
- Conceitos teóricos de cada princípio
- Exemplos práticos do projeto
- Code review em pares

### **Workshop 2: Refactoring Patterns** (3 horas)
- Como quebrar classes grandes
- Técnicas de extração de responsabilidades
- Padrões de design aplicáveis

### **Workshop 3: Testing Strategy** (2 horas)
- Como testar código refatorado
- Testes de arquitetura
- Mocking e dependency injection

---

## 🚀 Quick Wins

### **Semana 1 - Resultados Imediatos**
1. **Script de análise** funcionando
2. **PlantsDataService** extraído e testado
3. **Primeira redução** de 200 linhas no PlantsProvider

### **Semana 2 - Validação**
1. **Build verde** com nova estrutura
2. **Testes passando** com coverage >70%
3. **Performance mantida** ou melhorada

---

## 📋 Checklist de Entrega

### **Fase 1 (Sprint 1-2)**
- [ ] PlantsProvider quebrado em 4 classes (<300 linhas cada)
- [ ] IAuthStateProvider interface implementada
- [ ] PlantFormProvider refatorado
- [ ] Testes unitários >70% coverage
- [ ] Build pipeline verde
- [ ] Performance benchmarks mantidos

### **Fase 2 (Sprint 3-4)**
- [ ] TasksProvider refatorado completamente
- [ ] Service Locator substituído por DI
- [ ] Todas as dependências abstraídas
- [ ] Testes de arquitetura implementados
- [ ] Documentação atualizada

### **Fase 3 (Sprint 5-6)**
- [ ] Padrões de design implementados
- [ ] Métricas SOLID >85%
- [ ] Team training completo
- [ ] Code review process atualizado
- [ ] Auditoria final aprovada

---

*Este plano de refatoração garante uma evolução segura e incremental do código, mantendo a funcionalidade enquanto melhora drasticamente a arquitetura e manutenibilidade do projeto.*