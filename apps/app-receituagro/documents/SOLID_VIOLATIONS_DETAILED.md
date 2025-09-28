# 🔍 Violações SOLID - Detalhamento Técnico

## 🚨 Single Responsibility Principle (SRP) - 12 Violações

### Violação Crítica #1: PremiumService
**Arquivo:** `lib/core/services/premium_service.dart`  
**Linhas:** 1-400+

**Problema:**
```dart
class PremiumService {
  // Responsabilidade 1: Gerenciar licenças
  Future<bool> validateLicense() { ... }
  
  // Responsabilidade 2: Sincronização
  Future<void> syncPremiumStatus() { ... }
  
  // Responsabilidade 3: Validações de features
  bool canUseFeature(String feature) { ... }
  
  // Responsabilidade 4: UI/UX interactions
  void showPremiumDialog() { ... }
}
```

**Refatoração Sugerida:**
```dart
// Separar em múltiplos services
abstract class IPremiumLicenseService {
  Future<bool> validateLicense();
}

abstract class IPremiumSyncService {
  Future<void> syncStatus();
}

abstract class IPremiumFeatureValidator {
  bool canUseFeature(String feature);
}

abstract class IPremiumUIService {
  void showUpgradeDialog();
}
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 3-5 dias

---

### Violação Crítica #2: ReceitaAgroDataCleaner
**Arquivo:** `lib/core/services/receituagro_data_cleaner.dart`  
**Linhas:** 1-300+

**Problema:**
```dart
class ReceitaAgroDataCleaner {
  // Responsabilidade 1: Limpeza de dados
  Future<void> cleanDatabase() { ... }
  
  // Responsabilidade 2: Validação
  bool validateDataIntegrity() { ... }
  
  // Responsabilidade 3: Migração
  Future<void> migrateData() { ... }
  
  // Responsabilidade 4: Logging
  void logCleanupResults() { ... }
  
  // Responsabilidade 5: Backup
  Future<void> createBackup() { ... }
}
```

**Refatoração Sugerida:**
```dart
abstract class IDataCleaner {
  Future<void> cleanDatabase();
}

abstract class IDataValidator {
  bool validateIntegrity();
}

abstract class IDataMigrator {
  Future<void> migrateData();
}

abstract class IDataBackupService {
  Future<void> createBackup();
}
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 2-3 dias

---

### Violação Alta #3: InjectionContainer
**Arquivo:** `lib/core/di/injection_container.dart`  
**Linhas:** 1-500+

**Problema:**
```dart
class InjectionContainer {
  // Responsabilidade 1: Configuração DI
  void configureDependencies() { ... }
  
  // Responsabilidade 2: Inicialização de services
  Future<void> initializeServices() { ... }
  
  // Responsabilidade 3: Validação de dependências
  bool validateDependencies() { ... }
  
  // Responsabilidade 4: Gestão de lifecycle
  void dispose() { ... }
}
```

**Refatoração Sugerida:**
```dart
// Usar módulos especializados
abstract class DIModule {
  void configure(GetIt container);
}

class AuthModule extends DIModule { ... }
class DataModule extends DIModule { ... }
class PremiumModule extends DIModule { ... }
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 3-4 dias

---

## 🔓 Open/Closed Principle (OCP) - 8 Violações

### Violação Crítica #1: Tipo de Pragas
**Arquivo:** `lib/features/pragas/domain/services/praga_type_resolver.dart`  
**Linhas:** 45-80

**Problema:**
```dart
String resolvePragaType(String typeId) {
  switch (typeId) {
    case '1': return 'Insetos';
    case '2': return 'Doenças';
    case '3': return 'Plantas Daninhas';
    default: return 'Desconhecido';
  }
}
```

**Refatoração Sugerida:**
```dart
abstract class PragaTypeResolver {
  String resolve(String typeId);
}

class PragaTypeRegistry {
  final Map<String, PragaTypeResolver> _resolvers = {};
  
  void register(String typeId, PragaTypeResolver resolver) {
    _resolvers[typeId] = resolver;
  }
  
  String resolve(String typeId) => _resolvers[typeId]?.resolve(typeId) ?? 'Desconhecido';
}
```

**Prioridade:** 🟡 Alto  
**Esforço:** 1-2 dias

---

### Violação Alta #2: Validadores Hard-coded
**Arquivo:** `lib/core/validation/validation_service.dart`  
**Linhas:** 120-150

**Problema:**
```dart
bool validateInput(String type, dynamic value) {
  if (type == 'email') {
    return EmailValidator.validate(value);
  } else if (type == 'phone') {
    return PhoneValidator.validate(value);
  } else if (type == 'cpf') {
    return CpfValidator.validate(value);
  }
  return false;
}
```

**Refatoração Sugerida:**
```dart
abstract class IValidator<T> {
  bool validate(T value);
}

class ValidationService {
  final Map<String, IValidator> _validators = {};
  
  void registerValidator(String type, IValidator validator) {
    _validators[type] = validator;
  }
  
  bool validate(String type, dynamic value) =>
      _validators[type]?.validate(value) ?? false;
}
```

**Prioridade:** 🟡 Alto  
**Esforço:** 1-2 dias

---

## ⚖️ Interface Segregation Principle (ISP) - 5 Violações

### Violação Crítica #1: IDataService Monolítica
**Arquivo:** `lib/core/interfaces/i_data_service.dart`  
**Linhas:** 1-100

**Problema:**
```dart
abstract class IDataService {
  // Repository operations
  Future<List<T>> getAll<T>();
  Future<T?> getById<T>(String id);
  Future<void> save<T>(T entity);
  Future<void> delete<T>(String id);
  
  // Sync operations
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
  
  // Cache operations
  void clearCache();
  Future<void> warmupCache();
  
  // Validation operations
  bool validateEntity<T>(T entity);
  List<String> getValidationErrors<T>(T entity);
  
  // Export operations
  Future<String> exportToJson();
  Future<void> importFromJson(String json);
}
```

**Refatoração Sugerida:**
```dart
abstract class IRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T entity);
  Future<void> delete(String id);
}

abstract class ISyncService {
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
}

abstract class ICacheService {
  void clearCache();
  Future<void> warmupCache();
}

abstract class IValidationService<T> {
  bool validate(T entity);
  List<String> getErrors(T entity);
}
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 2-3 dias

---

## 🔄 Dependency Inversion Principle (DIP) - 5 Violações

### Violação Crítica #1: Provider com Dependencies Diretas
**Arquivo:** `lib/features/premium/presentation/providers/premium_provider.dart`  
**Linhas:** 20-30

**Problema:**
```dart
class PremiumProvider extends ChangeNotifier {
  final PremiumService _service = PremiumService(); // Dependency direta
  final HiveService _hive = HiveService(); // Dependency direta
  final FirebaseService _firebase = FirebaseService(); // Dependency direta
}
```

**Refatoração Sugerida:**
```dart
class PremiumProvider extends ChangeNotifier {
  final IPremiumService _service;
  final IStorageService _storage;
  final ICloudService _cloud;
  
  PremiumProvider({
    required IPremiumService service,
    required IStorageService storage,
    required ICloudService cloud,
  }) : _service = service, _storage = storage, _cloud = cloud;
}
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 1 dia

---

### Violação Crítica #2: Repository sem Abstração
**Arquivo:** `lib/core/repositories/diagnostico_hive_repository.dart`  
**Linhas:** 15-25

**Problema:**
```dart
class DiagnosticoHiveRepository {
  final HiveManager _hive = HiveManager(); // Dependency direta
  final NetworkInfo _network = NetworkInfo(); // Dependency direta
}
```

**Refatoração Sugerida:**
```dart
class DiagnosticoHiveRepository implements IDiagnosticoRepository {
  final IHiveManager _hive;
  final INetworkInfo _network;
  
  DiagnosticoHiveRepository({
    required IHiveManager hive,
    required INetworkInfo network,
  }) : _hive = hive, _network = network;
}
```

**Prioridade:** 🔴 Crítico  
**Esforço:** 1 dia

---

## 🔄 Liskov Substitution Principle (LSP) - 3 Violações

### Violação Crítica #1: Mock Service Inconsistente
**Arquivo:** `lib/core/services/mock_premium_service.dart`  
**Linhas:** 30-40

**Problema:**
```dart
class MockPremiumService extends PremiumService {
  @override
  Future<bool> validateLicense() async {
    throw UnimplementedError('Mock não implementa validação'); // Quebra contrato
  }
}
```

**Refatoração Sugerida:**
```dart
class MockPremiumService implements IPremiumService {
  @override
  Future<bool> validateLicense() async {
    return true; // Comportamento consistente para testes
  }
}
```

**Prioridade:** 🟡 Alto  
**Esforço:** 0.5 dias

---

## 📊 Resumo de Impacto

| Violação | Arquivos Afetados | Esforço Total | Dependências |
|----------|------------------|---------------|--------------|
| **SRP** | 8 arquivos | 8-12 dias | Baixa |
| **OCP** | 5 arquivos | 4-6 dias | Média |
| **ISP** | 3 arquivos | 4-5 dias | Alta |
| **DIP** | 7 arquivos | 3-4 dias | Baixa |
| **LSP** | 2 arquivos | 1-2 dias | Baixa |

**Total estimado:** 20-29 dias de desenvolvimento

---

## 🎯 Ordem de Refatoração Recomendada

1. **DIP** - Criar abstrações (base para outras refatorações)
2. **SRP** - Quebrar classes monolíticas  
3. **ISP** - Segregar interfaces
4. **OCP** - Implementar extensibilidade
5. **LSP** - Corrigir hierarquias

Esta ordem minimiza o retrabalho e garante que as bases arquiteturais sejam estabelecidas primeiro.