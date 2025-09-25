# Relatório de Migração: get_it ^8.2.0 + injectable ^2.5.0

## 📊 Análise de Impacto

### **Apps Impactados (get_it):**
- ✅ **app-plantis** - get_it: ^8.2.0
- ✅ **app_taskolist** - get_it: ^8.2.0 (via Riverpod DI)
- ✅ **app-petiveti** - get_it: ^8.2.0
- ❌ **app-gasometer** - Usa Provider (não GetIt)
- ❌ **app-receituagro** - Usa Provider (não GetIt)

### **Apps Impactados (injectable):**
- ✅ **app-gasometer** - injectable: ^2.5.0
- ✅ **app-plantis** - injectable: ^2.5.0
- ✅ **app-petiveti** - injectable: ^2.5.0
- ❌ **app_taskolist** - Usa Riverpod manual
- ❌ **app-receituagro** - Usa Provider

**Total:** 3/5 apps usam GetIt + Injectable para DI unificado

### **Status no Core:**
✅ **get_it:** JÁ EXISTE no packages/core/pubspec.yaml
❌ **injectable:** NÃO EXISTE no packages/core/pubspec.yaml

---

## 🔍 Análise Técnica

### **Compatibilidade de Versões:**
```yaml
# Versão atual nos apps:
get_it: ^8.2.0         # IDÊNTICA em todos
injectable: ^2.5.0     # IDÊNTICA em todos

# Versão no Core atual:
get_it: ^8.2.0         # JÁ COMPATÍVEL ✅

# Versão recomendada para Core:
injectable: ^2.5.0     # ADICIONAR
```

### **Dependências (injectable):**
```yaml
dependencies:
  build: ^2.3.2
  analyzer: ^5.2.0
  source_gen: ^1.2.6
  get_it: ^7.0.0  # Compatible with ^8.2.0
```
- ✅ Todas são dev dependencies ou já disponíveis

### **Uso Típico nos Apps:**

#### **get_it Pattern:**
```dart
// Típico nos apps:
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

// Registration:
getIt.registerLazySingleton<Repository>(() => RepositoryImpl());

// Usage:
final repo = getIt<Repository>();
```

#### **injectable Pattern:**
```dart
// Típico nos apps com @injectable:
import 'package:injectable/injectable.dart';

@injectable
class UserService {
  final Repository _repository;
  UserService(this._repository);
}

@module
abstract class ServiceModule {
  @lazySingleton
  Repository get repository => RepositoryImpl();
}
```

### **Integration Patterns nos Apps:**

#### **app-gasometer (Provider + Injectable):**
```dart
// device_management_module.dart
@module
abstract class DeviceManagementModule {
  @lazySingleton
  DeviceManagementService get deviceService;
}
```

#### **app-plantis (GetIt + Injectable):**
```dart
// Full DI with injectable annotations
@injectable
class PlantRepository {
  final ApiService _api;
  PlantRepository(this._api);
}
```

#### **app_taskolist (GetIt + Riverpod):**
```dart
// Manual GetIt registration with Riverpod
final repositoryProvider = Provider<TaskRepository>((ref) {
  return getIt<TaskRepository>();
});
```

---

## 🎯 Plano de Migração

### **Passo 1: Adicionar injectable ao Core**
```yaml
# packages/core/pubspec.yaml
dependencies:
  get_it: ^8.2.0          # JÁ EXISTE ✅
  injectable: ^2.5.0      # ADICIONAR

dev_dependencies:
  injectable_generator: ^2.6.2  # ADICIONAR também
```

### **Passo 2: Export no Core**
```dart
// packages/core/lib/core.dart
export 'package:get_it/get_it.dart';
export 'package:injectable/injectable.dart';

// Opcional: GetIt instance global
final getIt = GetIt.instance;
```

### **Passo 3: Remover dos Apps**

#### **3.1. app-plantis (PRIMEIRO - GetIt + Injectable completo)**
```yaml
# REMOVER de app-plantis/pubspec.yaml:
# get_it: ^8.2.0
# injectable: ^2.5.0

# MANTER em dev_dependencies:
# injectable_generator: ^2.6.2  # Necessário para build
```

#### **3.2. app-petiveti (SEGUNDO - Similar ao plantis)**
```yaml
# REMOVER de app-petiveti/pubspec.yaml:
# get_it: ^8.2.0
# injectable: ^2.5.0
```

#### **3.3. app-gasometer (TERCEIRO - Apenas Injectable)**
```yaml
# REMOVER de app-gasometer/pubspec.yaml:
# injectable: ^2.5.0

# NOTE: app-gasometer usa Provider como primary, Injectable para modules
```

#### **3.4. app_taskolist (ÚLTIMO - GetIt + Riverpod híbrido)**
```yaml
# REMOVER de app_taskolist/pubspec.yaml:
# get_it: ^8.2.0

# CUIDADO: Riverpod + GetIt integration precisa de teste extra
```

### **Passo 4: Atualizar Imports (Opcional)**
```dart
// DE:
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// PARA (se quiser padronizar):
import 'package:core/core.dart';
```

---

## 🧪 Plano de Teste

### **Testes por App:**

#### **app-plantis (DI Crítico):**
```bash
cd apps/app-plantis
flutter clean
flutter pub get
flutter packages pub run build_runner build  # Injectable generation
flutter analyze
flutter test
flutter run  # Teste completo de DI
```

#### **app-petiveti (Similar):**
```bash
cd apps/app-petiveti
flutter clean
flutter pub get
flutter packages pub run build_runner build
flutter analyze
flutter test
```

#### **app-gasometer (Provider + Injectable Modules):**
```bash
cd apps/app-gasometer
flutter clean
flutter pub get
flutter packages pub run build_runner build  # Para @injectable modules
flutter analyze
flutter test
flutter run  # Verificar device management modules
```

#### **app_taskolist (Riverpod + GetIt):**
```bash
cd apps/app_taskolist
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run  # Teste critical: Riverpod providers usando GetIt
```

### **Pontos de Atenção Durante Testes:**

#### **Dependency Resolution:**
- ✅ **@injectable classes** sendo registrados
- ✅ **GetIt.instance** funcionando
- ✅ **Lazy singletons** inicializando
- ✅ **Module abstracts** sendo processados

#### **Build Generation:**
- ✅ **injectable_generator** funcionando
- ✅ **.g.dart files** sendo gerados
- ✅ **getIt.init()** funcionando

#### **Integration Patterns:**
- ✅ **Provider + Injectable** (gasometer)
- ✅ **Pure GetIt + Injectable** (plantis, petiveti)
- ✅ **Riverpod + GetIt** (taskolist)

---

## ⚠️ Riscos e Mitigações

### **Riscos Identificados:**

#### **🟡 MÉDIO RISCO: Build Generation**
- **Problema:** injectable_generator deve funcionar com core dependency
- **Mitigação:** Manter injectable_generator nos dev_dependencies dos apps
- **Validação:** build_runner build deve gerar .g.dart files

#### **🟡 MÉDIO RISCO: app_taskolist (Riverpod + GetIt)**
- **Problema:** Híbrido Riverpod usando GetIt pode quebrar
- **Mitigação:** Testar intensivamente providers que usam getIt<T>()
- **Validação:** Providers funcionando + state management OK

#### **🟡 MÉDIO RISCO: Module Dependencies**
- **Problema:** @module abstract classes podem não resolver dependencies
- **Mitigação:** Verificar se todos os @injectable são encontrados
- **Validação:** getIt.get<T>() deve funcionar para todos os types

#### **🟢 BAIXO RISCO: app-gasometer (Provider Primary)**
- **Problema:** Usa Injectable apenas para modules específicos
- **Mitigação:** Injectable é secundário, Provider é primary
- **Validação:** Device management modules funcionando

### **Rollback Plan:**
```bash
# Por app, rollback é simples:
git checkout HEAD~1 -- apps/app-plantis/pubspec.yaml
cd apps/app-plantis
flutter pub get
flutter packages pub run build_runner build
```

---

## 📈 Benefícios Esperados

### **Unificação DI:**
- ✅ **GetIt centralizado** para todos os apps
- ✅ **Injectable patterns** consistentes
- ✅ **Shared DI configuration** via core

### **Developer Experience:**
- ✅ **Consistent DI patterns** entre apps
- ✅ **Shared service locator** instance
- ✅ **Unified testing** approach para DI

### **Manutenibilidade:**
- ✅ **Central DI management**
- ✅ **Consistent dependency graphs**
- ✅ **Shared injectable services**

---

## 🏗️ Estratégia de DI Unificado

### **Core DI Architecture:**
```dart
// packages/core/lib/di/core_injection.dart
@InjectableInit()
void configureCoreInjection() => getIt.init();

// Core services disponíveis para todos apps:
@module
abstract class CoreModule {
  @lazySingleton
  DeviceManagementService get deviceService => DeviceManagementServiceImpl();

  @lazySingleton
  AnalyticsService get analyticsService => AnalyticsServiceImpl();
}
```

### **App-Specific DI Extension:**
```dart
// Por app - extends core DI:
@InjectableInit(
  initializerName: 'initGetItPlantis',
  preferRelativeImports: true,
  asExtension: false,
)
void configurePlantisInjection() => getIt.init();

void main() {
  configureCoreInjection();      // Core services first
  configurePlantisInjection();   // App-specific services
  runApp(MyApp());
}
```

---

## ✅ Critérios de Sucesso

### **Pré-Migração:**
- [ ] injectable ^2.5.0 adicionado ao core
- [ ] get_it já validado no core ✅
- [ ] Core exports configurados

### **Por App Migrado:**
- [ ] pubspec.yaml limpo (sem get_it/injectable)
- [ ] build_runner build sucesso (generates .g.dart files)
- [ ] flutter analyze limpo
- [ ] getIt.get<T>() funcionando para todos types
- [ ] App startup sem DI errors
- [ ] Functional testing de features que usam DI

### **Pós-Migração DI Unificado:**
- [ ] Todos os 3 apps com DI funcionando
- [ ] Core services acessíveis via getIt
- [ ] App-specific services funcionando
- [ ] Performance de DI mantida
- [ ] Zero circular dependencies

---

## 🚀 Cronograma Sugerido

### **Dia 1: Preparação + Core Setup**
- [ ] Adicionar injectable ao core
- [ ] Configurar core DI module
- [ ] Setup exports e global getIt instance
- [ ] Testar core build + generation

### **Dia 2: Apps Simples (Pure DI)**
- [ ] Migrar app-plantis (pure GetIt + Injectable)
- [ ] Migrar app-petiveti (similar pattern)
- [ ] Validação intensiva de DI resolution

### **Dia 3: Apps Híbridos (Complexos)**
- [ ] Migrar app-gasometer (Provider + Injectable modules)
- [ ] Migrar app_taskolist (Riverpod + GetIt)
- [ ] Teste de integration patterns

### **Dia 4: Unificação + Otimização**
- [ ] Setup unified core DI services
- [ ] Performance testing
- [ ] Documentation de DI patterns
- [ ] Final validation

---

## 📋 Checklist de Execução

```bash
# FASE 1: Preparar Core DI
[ ] cd packages/core
[ ] Adicionar "injectable: ^2.5.0" ao pubspec.yaml
[ ] Adicionar "injectable_generator: ^2.6.2" ao dev_dependencies
[ ] Setup core DI module
[ ] flutter pub get
[ ] flutter packages pub run build_runner build
[ ] flutter test

# FASE 2: Migrar Apps Pure DI
[ ] cd apps/app-plantis
[ ] Remover get_it + injectable do pubspec.yaml
[ ] Update imports para usar core
[ ] flutter clean && flutter pub get
[ ] flutter packages pub run build_runner build
[ ] flutter analyze && flutter test
[ ] flutter run (test DI funcionando)

# REPETIR para app-petiveti

# FASE 3: Migrar Apps Híbridos
[ ] cd apps/app-gasometer
[ ] Migrar injectable modules
[ ] Test Provider + Injectable integration
# REPETIR para app_taskolist

# FASE 4: Unificação Final
[ ] Test all apps
[ ] Setup shared core services
[ ] Performance validation
[ ] Commit & Push
```

---

## 🎖️ Classificação de Migração

**Complexidade:** 🟡 **MÉDIA** (6/10)
**Risco:** 🟡 **MÉDIO** (5/10)
**Benefício:** 🔥 **MUITO ALTO** (9/10)
**Tempo:** 🟡 **3-4 DIAS**

### **Critical Success Factors:**
- ✅ **Build generation** funcionando
- ✅ **DI patterns** mantidos por app
- ✅ **Integration patterns** preservados
- ✅ **Core services** accessible

---

**Status:** 🟡 **READY FOR CAREFUL EXECUTION**
**Recomendação:** **EXECUTAR APÓS cupertino_icons** (para ganhar confiança)
**Impacto:** 3/5 apps com DI unificado + core services shared

---

*Esta migração criará o foundation para DI unificado em todo o monorepo - high-impact architectural change.*