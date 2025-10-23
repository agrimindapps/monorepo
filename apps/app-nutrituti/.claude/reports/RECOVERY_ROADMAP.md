# Recovery Roadmap - app-nutrituti

**Data**: 2025-10-22
**Orquestrador**: project-orchestrator
**Status Inicial**: 🔴 **CRÍTICO - 1170 ERROS**
**Objetivo Final**: ✅ **PRODUÇÃO-READY (Qualidade 8/10+)**

---

## 🎯 Executive Summary - Diagnóstico Multi-Especialista

### **Situação Atual (Estado Crítico)**

| Aspecto | Métrica | Status | Severidade |
|---------|---------|--------|------------|
| **Compilação** | 1170 erros | ❌ NÃO COMPILA | 🔴 BLOQUEADOR |
| **Warnings** | 334 warnings | ⚠️ ALTO | 🟡 IMPORTANTE |
| **Code Generation** | 0 arquivos .g.dart | ❌ NÃO EXECUTADO | 🔴 BLOQUEADOR |
| **Migração Riverpod** | 3% (8 de 308 arquivos) | 🔴 INICIAL | 🟡 IMPORTANTE |
| **Providers Legados** | 26 arquivos | ⚠️ 8.4% | 🟡 MÉDIO |
| **Qualidade** | 1/10 | 🔴 CRÍTICO | 🔴 CRÍTICO |

### **Causas Raiz Identificadas**

#### **1. Build Runner Não Executado (Causa Primária - 60% dos erros)**
- ❌ **0 arquivos .g.dart gerados**
- ❌ **injection.config.dart ausente** → DI quebrado
- ❌ **Hive adapters ausentes** → Persistência quebrada
- ❌ **Riverpod providers ausentes** → State management quebrado
- ❌ **15 arquivos aguardando code generation**

**Impacto**: 700+ erros diretamente relacionados

#### **2. Core Package API Breaking Changes (Causa Secundária - 20% dos erros)**
- ❌ **SubscriptionFactoryService**: 12 métodos ausentes
  - Implementação local tem apenas `create()`
  - `in_app_purchase_const.dart` tenta usar API inexistente
- ❌ **ModuleAuthConfig**: API mudou de named constructor para construtor
  - `ModuleAuthConfig.nutrituti` não existe mais
  - Requer instância explícita com parâmetros

**Impacto**: 234+ erros de API incompatível

#### **3. Type Casting Unsafe (Causa Terciária - 10% dos erros)**
- ❌ **environment_const.dart**: 8 erros de type casting `dynamic → String`
- Código usa Map sem type safety: `prod['key']` sem cast

**Impacto**: 8 erros de compilação + runtime risks

#### **4. Provider Exposure Issues (Causa Quaternária - 10% dos erros)**
- ❌ **aguaNotifierProvider**: Definido mas não acessível
  - Provider existe em `agua_controller.dart` com `@riverpod`
  - Arquivos .g.dart não gerados → provider não exposto
  - 50+ arquivos tentam usar provider inexistente

**Impacto**: 228+ erros de undefined identifier

---

## 📊 Análise Comparativa (Benchmark com Apps de Sucesso)

| Métrica | app-plantis (10/10) | app-receituagro (100%) | app-nutrituti (1/10) | Gap |
|---------|---------------------|------------------------|----------------------|-----|
| **Compilação** | ✅ 0 erros | ✅ 0 erros | ❌ 1170 erros | **-1170** |
| **Progresso Riverpod** | 95% (46 providers) | 100% (38 providers) | 3% (8 providers) | **-97%** |
| **Providers Legados** | 3 (tolerável) | 0 (perfeito) | 26 (alto) | **+26** |
| **Code Generation** | ✅ Executado | ✅ Executado | ❌ NÃO executado | **-100%** |
| **Infraestrutura** | ✅ Funcional | ✅ Funcional | ❌ Quebrada | **CRÍTICO** |
| **Arquitetura** | Clean Arch 10/10 | Clean Arch 8/10 | Híbrida 3/10 | **-7 pontos** |
| **Testes** | 13 testes (100%) | ≥80% coverage | 0 testes | **-100%** |

**Conclusão**: app-nutrituti está **dramaticamente atrás** dos outros apps do monorepo e em **estado não-funcional**.

---

## 🏗️ Análise Arquitetural (flutter-architect)

### **Estrutura Atual (Híbrida - Problemática)**

```
lib/
├── features/           ← MODERNO (Clean Architecture)
│   └── water/          ← ✅ Única feature migrada
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── pages/              ← LEGADO (Feature folders)
│   ├── agua/           ← ⚠️ Duplicação com features/water?
│   ├── calc/           ← 🔴 25 calculadoras com ChangeNotifier
│   ├── exercicios/
│   ├── meditacao/
│   ├── peso/
│   └── ...
│
├── core/               ← Infraestrutura compartilhada
│   ├── di/            ← ❌ injection.config.dart missing
│   ├── services/      ← ⚠️ SubscriptionFactoryService desatualizado
│   ├── controllers/   ← ⚠️ auth_controller com API antiga
│   └── theme/
│
└── widgets/            ← ⚠️ Widgets não organizados
```

**Problemas Arquiteturais Identificados**:

1. **Duplicação features/water + pages/agua**
   - Ambos tratam de hidratação
   - Qual é canônico?
   - Inconsistência confunde manutenção

2. **pages/calc/** - God Objects (25 calculadoras)
   - Cada calculadora = 1 ChangeNotifier
   - Padrão repetitivo ideal para automação
   - Violação SOLID (SRP)

3. **Core services desatualizados**
   - SubscriptionFactoryService com API antiga
   - auth_controller com ModuleAuthConfig.nutrituti inexistente

4. **Ausência de Clean Architecture consistente**
   - Apenas `features/water` segue padrão
   - Resto do app em estrutura legada

### **Arquitetura Alvo (Baseada em app-plantis 10/10)**

```
lib/
├── core/
│   ├── config/         ← Centralizar environment, subscriptions
│   ├── di/            ← Injectable + GetIt
│   ├── error/         ← Either<Failure, T> handlers
│   ├── router/        ← GoRouter
│   ├── services/      ← Sincronizados com core package
│   └── theme/         ← Riverpod providers
│
├── features/          ← 100% Clean Architecture
│   ├── water/         ← ✅ JÁ MIGRADO
│   ├── calculators/   ← NOVO (migrar 25 calculadoras)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── exercicios/    ← MIGRAR de pages/
│   ├── meditacao/     ← MIGRAR de pages/
│   └── peso/          ← MIGRAR de pages/
│
└── shared/
    └── widgets/       ← Widgets reutilizáveis
```

**Estratégia de Migração Arquitetural**:
1. **Manter features/water** (já está correto)
2. **Migrar pages/* → features/** gradualmente
3. **Consolidar calculadoras** em features/calculators
4. **Remover duplicações** (pages/agua vs features/water)

---

## 🚀 ROADMAP DE RECUPERAÇÃO - 4 FASES

### **FASE 0: Build & Compilation Fixes** ⏱️ **2-3 horas**

**Objetivo**: Fazer o app compilar e executar
**Prioridade**: 🔴 **P0 - BLOQUEADOR**
**Especialistas**: task-intelligence (Sonnet) + quick-fix-agent (Haiku)

#### **Etapa 0.1: Code Generation (1h)**

```bash
# 1. Executar build runner
cd apps/app-nutrituti
dart run build_runner build --delete-conflicting-outputs

# Arquivos esperados:
# - lib/core/di/injection.config.dart
# - lib/pages/agua/controllers/agua_controller.g.dart
# - lib/pages/agua/models/beber_agua_model.g.dart
# - lib/database/comentarios_models.g.dart
# - lib/database/perfil_model.g.dart
# - lib/features/water/data/models/*.g.dart
# - + outros 8 arquivos .g.dart
```

**Resultado Esperado**: -700 erros (60% dos erros resolvidos)

**Validação**:
```bash
flutter analyze | grep "uri_has_not_been_generated\|uri_does_not_exist" | wc -l
# Esperado: 0
```

---

#### **Etapa 0.2: Core Package Sync - SubscriptionFactoryService (45 min)**

**Problema**: `SubscriptionFactoryService` local tem apenas método `create()`, mas `in_app_purchase_const.dart` tenta usar 12 métodos inexistentes.

**Solução A - Substituir por Implementação Direta (RECOMENDADO)** ⏱️ 30 min:

```dart
// lib/const/in_app_purchase_const.dart (REFATORAR)

const String _appId = 'nutrituti';

// REMOVER: SubscriptionFactoryService calls
// ADICIONAR: Constantes diretas

const List<Map<String, dynamic>> inappProductIds = [
  {
    'id': 'br.com.agrimind.nutrituti.monthly',
    'title': 'Nutrituti Premium - Mensal',
    'price': 'R\$ 9,90',
  },
  {
    'id': 'br.com.agrimind.nutrituti.yearly',
    'title': 'Nutrituti Premium - Anual',
    'price': 'R\$ 99,90',
  },
];

const String regexAssinatura = r'^br\.com\.agrimind\.nutrituti\..*';

const List<Map<String, dynamic>> inappVantagens = [
  {'icon': '🧮', 'text': 'Calculadoras ilimitadas'},
  {'icon': '💧', 'text': 'Controle de hidratação avançado'},
  {'icon': '🏋️', 'text': 'Planos de exercícios personalizados'},
  {'icon': '🧘', 'text': 'Meditações exclusivas'},
];

const Map<String, String> inappTermosUso = {
  'terms': 'https://nutrituti.com/terms',
  'privacy': 'https://nutrituti.com/privacy',
};

const Map<String, dynamic> infoAssinatura = {
  'name': 'Nutrituti Premium',
  'description': 'Acesso completo a todas as funcionalidades',
  'trial_days': 7,
};

// RevenueCat Keys (mover para environment)
const String entitlementID = 'premium';
const String appleApiKey = 'NUTRITUTI_APPLE_KEY';
const String googleApiKey = 'NUTRITUTI_GOOGLE_KEY';

// Validações
bool get isConfigurationValid =>
    inappProductIds.isNotEmpty &&
    entitlementID.isNotEmpty;

List<String> get configurationErrors {
  final errors = <String>[];
  if (inappProductIds.isEmpty) errors.add('Produtos não configurados');
  if (entitlementID.isEmpty) errors.add('Entitlement ID vazio');
  return errors;
}

bool get hasValidApiKeys =>
    appleApiKey.isNotEmpty && googleApiKey.isNotEmpty;

Map<String, dynamic> get fullConfiguration => {
  'app_id': _appId,
  'products': inappProductIds,
  'regex': regexAssinatura,
  'advantages': inappVantagens,
  'terms': inappTermosUso,
  'info': infoAssinatura,
  'entitlement': entitlementID,
};
```

**Solução B - Sincronizar com Core Package (SE existir implementação)** ⏱️ 45 min:
- Verificar se outros apps (plantis, receituagro) resolveram isso
- Copiar implementação funcional
- Ajustar para nutrituti

**Resultado Esperado**: -12 erros (SubscriptionFactoryService methods)

**Validação**:
```bash
flutter analyze | grep "SubscriptionFactoryService" | wc -l
# Esperado: 0
```

---

#### **Etapa 0.3: Core Package Sync - ModuleAuthConfig (30 min)**

**Problema**: `auth_controller.dart` usa `ModuleAuthConfig.nutrituti` (named constructor inexistente).

**Solução**:

```dart
// lib/controllers/auth_controller.dart (ATUALIZAR)

import 'package:core/core.dart';
import '../../core/controllers/base_auth_controller.dart';

class NutrituitAuthController extends BaseAuthController {
  @override
  ModuleAuthConfig get moduleConfig => const ModuleAuthConfig(
    moduleName: 'nutrituti',
    homeRoute: '/home',
    loginRoute: '/login',
    allowGuestMode: false,
    requireEmailVerification: false,
    allowSessionSharing: true,
    sessionTimeoutMinutes: 60,
    allowSocialLogin: true,
    customSettings: {
      'app_id': 'nutrituti',
      'theme': 'nutrituti_theme',
    },
  );
}
```

**Resultado Esperado**: -2 erros (ModuleAuthConfig API)

**Validação**:
```bash
flutter analyze | grep "ModuleAuthConfig" | wc -l
# Esperado: 0
```

---

#### **Etapa 0.4: Type Casting Fixes (15 min)**

**Problema**: `environment_const.dart` tem 8 erros de `dynamic → String` sem cast.

**Solução**:

```dart
// lib/const/environment_const.dart (CORRIGIR)

// ❌ ANTES:
admobBanner = Platform.isAndroid
    ? prod['admobBanner-android']
    : prod['admobBanner-ios'];

// ✅ DEPOIS:
admobBanner = Platform.isAndroid
    ? prod['admobBanner-android'] as String? ?? ''
    : prod['admobBanner-ios'] as String? ?? '';

// Aplicar padrão para todas as 8 ocorrências
```

**Automação**: usar analyzer-fixer (Haiku) para correções repetitivas.

**Resultado Esperado**: -8 erros (type casting)

**Validação**:
```bash
flutter analyze lib/const/environment_const.dart | grep "invalid_assignment" | wc -l
# Esperado: 0
```

---

#### **Checkpoints FASE 0**

**Checkpoint 1 - Após 0.1 (Code Generation)**:
```bash
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: ~470 erros (de 1170 → redução de 60%)
```

**Checkpoint 2 - Após 0.2+0.3+0.4 (Core Sync + Type Fixes)**:
```bash
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: ~450 erros (de 470 → redução de 4%)
```

**Checkpoint FINAL - FASE 0 COMPLETA**:
```bash
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: 0 erros 🎉

flutter build apk --debug
# Esperado: BUILD SUCCESSFUL
```

**Critérios de Sucesso FASE 0**:
- ✅ 0 erros de compilação
- ✅ App compila com `flutter build apk --debug`
- ✅ App executa em dispositivo/emulador
- ⚠️ Warnings podem permanecer (acceptable)

---

### **FASE 1: Core Package Full Sync** ⏱️ **3-4 horas**

**Objetivo**: Sincronizar 100% dos core services e eliminar breaking changes
**Prioridade**: 🟡 **P1 - IMPORTANTE**
**Especialistas**: code-intelligence (Sonnet) + task-intelligence (Sonnet)

**SOMENTE APÓS FASE 0 COMPLETA!**

#### **Etapa 1.1: Auditoria Completa de Core Dependencies (1h)**

**Tarefa**: Identificar TODOS os pontos de integração com `packages/core`.

```bash
# Análise automática
grep -r "import 'package:core" lib --include="*.dart" | wc -l
grep -r "from '../../packages/core" lib --include="*.dart" | wc -l
```

**Áreas Críticas**:
1. **Firebase Integration**
   - FirebaseAuthService
   - FirebaseAnalyticsService
   - Firestore sync

2. **RevenueCat Integration**
   - Subscription validation
   - Premium feature gates

3. **Hive Integration**
   - BoxManager patterns
   - Adapter registration

4. **Analytics Events**
   - Event naming conventions
   - User properties sync

**Deliverable**: `CORE_DEPENDENCIES_AUDIT.md`

---

#### **Etapa 1.2: Atualizar APIs Quebradas (2h)**

**Tarefas**:

1. **SubscriptionFactoryService** (implementado em FASE 0.2)
2. **ModuleAuthConfig** (implementado em FASE 0.3)
3. **Verificar outros serviços**:
   ```bash
   # Buscar por métodos undefined
   flutter analyze | grep "isn't defined for the type"
   ```

**Especialista**: task-intelligence (Sonnet) para mudanças complexas.

---

#### **Etapa 1.3: Validação Cross-App Consistency (1h)**

**Comparar com apps de sucesso**:

```bash
# Ver implementação de app-receituagro (100% Riverpod)
cd ../app-receituagro
grep -r "SubscriptionFactoryService\|ModuleAuthConfig" lib

# Ver implementação de app-plantis (10/10 Quality)
cd ../app-plantis
grep -r "SubscriptionFactoryService\|ModuleAuthConfig" lib
```

**Objetivo**: Garantir que app-nutrituti usa mesmos padrões que apps funcionais.

---

#### **Checkpoints FASE 1**

**Checkpoint FINAL - FASE 1 COMPLETA**:
```bash
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: 0 erros

flutter analyze 2>&1 | grep "^warning" | grep -v "unused_import\|info" | wc -l
# Esperado: <50 warnings críticos
```

**Critérios de Sucesso FASE 1**:
- ✅ 100% dos core services sincronizados
- ✅ Nenhum método undefined de core package
- ✅ Padrões consistentes com app-plantis/receituagro
- ✅ App funciona com todas features core integradas

---

### **FASE 2: Riverpod Migration** ⏱️ **12-16 horas**

**Objetivo**: Migrar 100% para Riverpod moderno com @riverpod
**Prioridade**: 🟢 **P2 - REFATORAÇÃO**
**Especialistas**: flutter-engineer + task-intelligence (Haiku para repetitivos)

**SOMENTE APÓS FASE 1 COMPLETA!**

#### **Estado Atual da Migração**

| Categoria | Quantidade | Status | Esforço Estimado |
|-----------|------------|--------|------------------|
| **@riverpod (migrados)** | 8 providers | ✅ Completo | - |
| **ChangeNotifier (legado)** | 20 controllers | ❌ Pendente | 8-10h |
| **Provider/StateNotifierProvider** | 6 providers | ❌ Pendente | 2h |
| **Total Pendente** | 26 arquivos | 🔴 8.4% migrado | **10-12h** |

---

#### **Etapa 2.1: Core Infrastructure Providers (2h)**

**Targets**:
1. `core/theme/theme_providers.dart` → @riverpod
2. Outros providers de infraestrutura

**Pattern**:

```dart
// ❌ ANTES (Provider legado):
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

// ✅ DEPOIS (@riverpod):
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

@riverpod
class Theme extends _$Theme {
  @override
  ThemeData build() {
    return ThemeData.light();
  }

  void toggleTheme() {
    state = state.brightness == Brightness.light
        ? ThemeData.dark()
        : ThemeData.light();
  }
}
```

**Validação**:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze core/theme/
```

---

#### **Etapa 2.2: Calculadoras Migration (BULK - 8-10h)**

**Challenge**: 20 ChangeNotifier controllers com padrão repetitivo.

**Estratégia de Automação**:

1. **Identificar padrão comum**:
   ```dart
   // Padrão repetido em todas as 20 calculadoras:
   class XxxController extends ChangeNotifier {
     double _result = 0.0;
     double get result => _result;

     void calculate(Map<String, dynamic> params) {
       _result = _calculateLogic(params);
       notifyListeners();
     }
   }
   ```

2. **Template @riverpod**:
   ```dart
   @riverpod
   class XxxCalculator extends _$XxxCalculator {
     @override
     double build() => 0.0;

     void calculate(Map<String, dynamic> params) {
       state = _calculateLogic(params);
     }

     double _calculateLogic(Map<String, dynamic> params) {
       // Lógica existente (não muda)
     }
   }
   ```

3. **Migração em Lote**:
   - Usar task-intelligence (Haiku) para calculadoras simples
   - Usar flutter-engineer para calculadoras complexas
   - Migrar 5 por vez, validar, continuar

**Lista de Calculadoras** (priorização por complexidade):

**LOTE 1 - Simples (2h)** - task-intelligence (Haiku):
1. volume_sanguineo_controller.dart
2. cintura_quadril_controller.dart
3. alcool_sangue_controller.dart
4. adiposidade_controller.dart
5. densidade_ossea_controller.dart

**LOTE 2 - Médias (3h)** - task-intelligence (Haiku):
6. taxa_metabolica_basal_controller.dart
7. peso_ideal_controller.dart
8. massa_corporea_controller.dart
9. gordura_corporea_controller.dart
10. calorias_diarias_controller.dart

**LOTE 3 - Complexas (3h)** - flutter-engineer:
11. macronutrientes_controller.dart
12. gasto_energetico_controller.dart
13. densidade_nutrientes_controller.dart
14. deficit_superavit_controller.dart
15. calorias_exercicio_controller.dart

**LOTE 4 - Restantes (2h)**:
16-20. Outras calculadoras

**Validação por Lote**:
```bash
# Após cada lote:
dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/pages/calc/
flutter test test/calc/ # se houver testes
```

---

#### **Etapa 2.3: Features Migration (2h)**

**Targets**:
- pages/exercicios/controllers/ → @riverpod
- pages/meditacao/providers/ → @riverpod
- pages/peso/controllers/ → @riverpod

**Especialista**: flutter-engineer (features têm lógica de negócio complexa).

---

#### **Etapa 2.4: Cleanup & Dependency Removal (1h)**

**Tarefas**:

1. **Remover dependências legadas**:
   ```yaml
   # pubspec.yaml - REMOVER:
   # provider: any  ❌
   # get: any       ❌ (se não usado)
   ```

2. **Validar nenhum import legado**:
   ```bash
   grep -r "import 'package:provider" lib --include="*.dart"
   # Esperado: 0 resultados

   grep -r "extends ChangeNotifier" lib --include="*.dart"
   # Esperado: 0 resultados
   ```

3. **Executar flutter pub get**:
   ```bash
   flutter pub get
   flutter pub upgrade
   ```

---

#### **Checkpoints FASE 2**

**Checkpoint 1 - Após Infraestrutura (Etapa 2.1)**:
```bash
grep -r "@riverpod" lib/core --include="*.dart" | wc -l
# Esperado: ≥3 (theme + outros providers core)
```

**Checkpoint 2 - Após Calculadoras LOTE 1 (5 migradas)**:
```bash
grep -r "@riverpod" lib/pages/calc --include="*.dart" | wc -l
# Esperado: ≥5
```

**Checkpoint 3 - Após Calculadoras COMPLETAS (20 migradas)**:
```bash
grep -r "@riverpod" lib/pages/calc --include="*.dart" | wc -l
# Esperado: 20

grep -r "extends ChangeNotifier" lib/pages/calc --include="*.dart" | wc -l
# Esperado: 0
```

**Checkpoint FINAL - FASE 2 COMPLETA**:
```bash
# 1. Nenhum provider legado
grep -r "extends ChangeNotifier\|StateNotifierProvider" lib --include="*.dart" | wc -l
# Esperado: 0

# 2. Todos os providers com @riverpod
grep -r "@riverpod" lib --include="*.dart" | wc -l
# Esperado: ≥34 (8 existentes + 26 migrados)

# 3. Build runner sem erros
dart run build_runner build --delete-conflicting-outputs
# Esperado: Build successful, 0 conflicting outputs

# 4. Análise sem erros críticos
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: 0
```

**Critérios de Sucesso FASE 2**:
- ✅ 100% migrado para @riverpod (34+ providers)
- ✅ 0 providers legados (ChangeNotifier, StateNotifierProvider)
- ✅ Dependencies limpas (provider, get removidos)
- ✅ Build runner funciona sem conflitos
- ✅ App funciona com todas features migradas

---

### **FASE 3: Quality & Testing** ⏱️ **8-12 horas**

**Objetivo**: Atingir qualidade 8/10+ (padrão app-receituagro)
**Prioridade**: 🟢 **P3 - QUALIDADE**
**Especialistas**: specialized-auditor + code-intelligence + flutter-engineer

**SOMENTE APÓS FASE 2 COMPLETA!**

---

#### **Etapa 3.1: Architecture Refactoring (4-6h)**

**Objetivo**: Migrar estrutura legada `pages/` → `features/` (Clean Architecture).

**Atual vs Alvo**:

```
❌ ATUAL (Híbrido):
lib/
├── features/water/        ✅ Clean Arch
└── pages/                 ❌ Legado
    ├── agua/              ← Duplica features/water?
    ├── calc/              ← 20 calculadoras
    ├── exercicios/
    ├── meditacao/
    └── peso/

✅ ALVO (100% Clean Arch):
lib/
└── features/
    ├── water/             ✅ Mantém
    ├── calculators/       🆕 Migrar pages/calc
    ├── exercicios/        🆕 Migrar pages/exercicios
    ├── meditacao/         🆕 Migrar pages/meditacao
    └── peso/              🆕 Migrar pages/peso
```

**Sub-tarefas**:

**3.1.1 - Resolver Duplicação agua/ vs water/ (1h)**:
- Investigar se pages/agua e features/water são duplicados
- Se sim: consolidar em features/water
- Se não: renomear para evitar confusão

**3.1.2 - Migrar Calculadoras → features/calculators/ (2h)**:
```
features/calculators/
├── data/
│   └── repositories/
│       └── calculator_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── calculation_result.dart
│   ├── repositories/
│   │   └── calculator_repository.dart
│   └── usecases/
│       ├── calculate_imc_usecase.dart
│       ├── calculate_tmb_usecase.dart
│       └── ... (20 usecases)
└── presentation/
    ├── providers/
    │   └── calculator_providers.dart
    └── pages/
        ├── imc_page.dart
        └── ... (20 pages)
```

**3.1.3 - Migrar Outras Features (2-3h)**:
- pages/exercicios → features/exercicios
- pages/meditacao → features/meditacao
- pages/peso → features/peso

**Especialista**: flutter-engineer (refatoração arquitetural complexa).

**Validação**:
```bash
# Estrutura antiga deve estar vazia
ls -la lib/pages/
# Esperado: apenas arquivos de roteamento se necessário

# Todas features em Clean Arch
find lib/features -type d -name "data" | wc -l
find lib/features -type d -name "domain" | wc -l
find lib/features -type d -name "presentation" | wc -l
# Esperado: ≥5 para cada (water + calculators + exercicios + meditacao + peso)
```

---

#### **Etapa 3.2: Testing Infrastructure (3-4h)**

**Objetivo**: Criar suite de testes com ≥80% coverage (padrão monorepo).

**Atual**: 0 testes mencionados no relatório inicial.

**Targets**:

**3.2.1 - Setup Testing Infrastructure (30 min)**:
```yaml
# pubspec.yaml - dev_dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4          # Mocking (padrão monorepo)
  integration_test:
    sdk: flutter
```

**3.2.2 - Unit Tests (2h)**:

Prioridade para **use cases críticos**:

```dart
// test/features/calculators/domain/usecases/calculate_imc_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late CalculateImcUseCase usecase;
  late MockCalculatorRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculatorRepository();
    usecase = CalculateImcUseCase(mockRepository);
  });

  group('CalculateImcUseCase', () {
    test('should return success with valid params', () async {
      // Arrange
      final params = ImcParams(weight: 70, height: 1.75);

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (imc) => expect(imc, closeTo(22.86, 0.01)),
      );
    });

    test('should return ValidationFailure for zero height', () async {
      // Arrange
      final params = ImcParams(weight: 70, height: 0);

      // Act
      final result = await usecase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    // + 3-5 testes adicionais (validations, edge cases)
  });
}
```

**Targets de Coverage**:
- ✅ Use cases: ≥80% (5-7 testes por use case)
- ✅ Providers: ≥70% (usando ProviderContainer)
- ✅ Repositories: ≥70%

**3.2.3 - Widget Tests (1h)**:

Testes de widgets críticos:
```dart
// test/features/calculators/presentation/pages/imc_page_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('IMC Page should display form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ImcPage()),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2)); // weight, height
    expect(find.byType(ElevatedButton), findsOneWidget); // calculate button
  });

  // + testes de interação, validação, resultado
}
```

**3.2.4 - Riverpod Provider Tests (30 min)**:

```dart
// test/features/water/presentation/providers/agua_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late ProviderContainer container;
  late MockAguaRepository mockRepository;

  setUp(() {
    mockRepository = MockAguaRepository();
    container = ProviderContainer(
      overrides: [
        aguaRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('aguaNotifierProvider initial state should be loading', () async {
    final provider = container.read(aguaNotifierProvider);
    expect(provider, isA<AsyncValue<AguaState>>());
  });

  // + testes de CRUD operations, state updates
}
```

**Validação**:
```bash
# Executar testes
flutter test

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Esperado: ≥80% para use cases críticos
```

---

#### **Etapa 3.3: Code Quality Audit (1-2h)**

**Tarefas**:

1. **Executar specialized-auditor (quality)**:
   - Análise de quality metrics
   - Identificação de technical debt
   - Recomendações de refatoração

2. **Executar analyzer-fixer (Haiku)**:
   - Corrigir warnings automáticos
   - Aplicar lints sugeridos

3. **Code cleanup**:
   ```bash
   # Remover imports não usados
   dart fix --apply

   # Formatar código
   dart format lib/ test/

   # Análise final
   flutter analyze
   ```

**Validação**:
```bash
flutter analyze 2>&1 | grep "^  error" | wc -l
# Esperado: 0

flutter analyze 2>&1 | grep "^warning" | wc -l
# Esperado: <20 (apenas warnings informativos)
```

---

#### **Checkpoints FASE 3**

**Checkpoint 1 - Após Architecture Refactoring**:
```bash
find lib/features -type d | wc -l
# Esperado: ≥15 (5 features × 3 layers each)

find lib/pages -name "*.dart" | wc -l
# Esperado: <10 (apenas arquivos de roteamento)
```

**Checkpoint 2 - Após Testing**:
```bash
flutter test
# Esperado: All tests passing

# Coverage (se configurado)
flutter test --coverage
# Esperado: ≥80% para use cases
```

**Checkpoint FINAL - FASE 3 COMPLETA**:
```bash
# 1. Análise limpa
flutter analyze 2>&1 | grep "^  error\|^warning" | grep -v "info" | wc -l
# Esperado: <20 (apenas warnings menores)

# 2. Testes passando
flutter test
# Esperado: All tests passing, ≥80% coverage

# 3. Build release funciona
flutter build apk --release
# Esperado: BUILD SUCCESSFUL
```

**Critérios de Sucesso FASE 3**:
- ✅ 100% Clean Architecture (todas features em lib/features/)
- ✅ ≥80% test coverage para use cases críticos
- ✅ 0 erros analyzer
- ✅ <20 warnings (apenas informativos)
- ✅ Build release funciona
- ✅ Qualidade 8/10+ (comparável a app-receituagro)

---

## 📊 Resumo de Estimativas

| Fase | Objetivo | Prioridade | Esforço | Especialistas | Critério Sucesso |
|------|----------|------------|---------|---------------|------------------|
| **FASE 0** | Build & Compilation | 🔴 P0 | 2-3h | task-intelligence + quick-fix | ✅ 0 erros, app compila |
| **FASE 1** | Core Package Sync | 🟡 P1 | 3-4h | code-intelligence + task-intelligence | ✅ APIs sincronizadas 100% |
| **FASE 2** | Riverpod Migration | 🟢 P2 | 12-16h | flutter-engineer + task-intelligence | ✅ 100% @riverpod, 0 legados |
| **FASE 3** | Quality & Testing | 🟢 P3 | 8-12h | specialized-auditor + flutter-engineer | ✅ 8/10 quality, ≥80% coverage |
| **TOTAL** | **PRODUÇÃO-READY** | - | **25-35h** | Multi-especialista | ✅ 8/10+ quality |

**Tempo Total**: 25-35 horas (~1-1.5 semanas de trabalho dedicado)

**Conversão Conservadora**: 30-40 horas (incluindo validações e ajustes)

---

## 🎯 Estratégia de Execução

### **Recomendação: Abordagem Incremental**

**Opção A - Sprint Intensivo (1-1.5 semanas)** ⏱️ 25-35h:
- **Vantagem**: App recuperado rapidamente
- **Desvantagem**: Requer dedicação exclusiva
- **Ideal para**: Time dedicado ou contractor focado

**Opção B - Incremental Semanal (4 semanas)** ⏱️ 6-9h/semana:
- Semana 1: FASE 0 + FASE 1 (5-7h)
- Semana 2: FASE 2 - Calculadoras LOTE 1+2 (8h)
- Semana 3: FASE 2 - Calculadoras LOTE 3+4 + Cleanup (7h)
- Semana 4: FASE 3 - Quality + Testing (8-12h)

**Opção C - Manutenção Contínua (2 meses)** ⏱️ 3-4h/semana:
- 2-3h/semana dedicadas consistentemente
- Progresso gradual, baixo risco
- **Desvantagem**: App permanece não-funcional por mais tempo

### **Recomendação do Orquestrador**: 🎯 **Opção A (Sprint Intensivo)**

**Justificativa**:
1. **App está não-funcional** (1170 erros) - cada dia parado = oportunidade perdida
2. **FASE 0 é bloqueadora** - sem ela, nenhum desenvolvimento adicional é possível
3. **FASE 2 (Riverpod) é repetitiva** - alta automação possível com task-intelligence
4. **ROI rápido** - app funcional em 1-2 semanas vs 2 meses

**Sequência Recomendada**:
```
DIA 1-2 (6-8h):  FASE 0 + FASE 1 → App compila e funciona basicamente
DIA 3-5 (12-16h): FASE 2 → 100% Riverpod, arquitetura moderna
DIA 6-8 (8-12h):  FASE 3 → Quality 8/10+, testes, produção-ready
```

---

## 🚨 Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| **Build runner falha** | Média | Alto | Limpar cache: `flutter clean && flutter pub get` |
| **Core package incompatível** | Baixa | Alto | Usar implementações de app-receituagro como referência |
| **Migração Riverpod quebra UI** | Média | Médio | Migrar em lotes de 5, validar UI após cada lote |
| **Calculadoras têm lógica complexa** | Alta | Baixo | Usar flutter-engineer para casos complexos (LOTE 3) |
| **Testes descobrem bugs** | Alta | Médio | **ESPERADO** - descobrir bugs é objetivo dos testes! |
| **Refatoração arquitetural quebra features** | Média | Alto | Manter páginas antigas até validação completa da nova estrutura |
| **Estimativa subestimada** | Média | Médio | Buffer de 20% já incluído (25-35h → 30-40h conservador) |

---

## 🔄 Próximos Passos Imediatos

### **Decisão Necessária**: Escolher estratégia de execução

**RECOMENDAÇÃO**: Executar **FASE 0 IMEDIATAMENTE** (2-3h) independente da estratégia escolhida.

**Motivo**: FASE 0 é **bloqueadora** - sem ela:
- ❌ App não compila
- ❌ Nenhum desenvolvimento adicional é possível
- ❌ Impossível testar features existentes
- ❌ Impossível validar integrações

**Comando para Início Imediato**:

```bash
# 1. Navegar para app-nutrituti
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-nutrituti

# 2. Executar FASE 0.1 - Code Generation
dart run build_runner build --delete-conflicting-outputs

# 3. Verificar redução de erros
flutter analyze 2>&1 | grep "^  error" | wc -l

# 4. Se ainda >500 erros, prosseguir com FASE 0.2-0.4
# 5. Se <500 erros, validar build
flutter build apk --debug
```

**Após FASE 0**: Revisar este roadmap e decidir estratégia para FASE 1-3.

---

## 📚 Referências e Recursos

### **Documentação Gerada**
- **Este Roadmap**: `.claude/reports/RECOVERY_ROADMAP.md`
- **Análise Crítica Inicial**: `.claude/reports/CRITICAL_ANALYSIS.md`

### **Apps de Referência (Success Cases)**
- **app-plantis**: Gold Standard 10/10
  - `.claude/reports/RIVERPOD_MIGRATION_STATUS.md`
  - Specialized Services pattern
  - 13 testes unitários exemplares

- **app-receituagro**: 100% Riverpod em 30min
  - `.claude/reports/RIVERPOD_MIGRATION_ANALYSIS.md`
  - 38 providers @riverpod
  - Padrões de migração rápida

### **Guias Técnicos**
- `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md` - Guia oficial de migração
- `CLAUDE.md` - Padrões do monorepo

### **Especialistas Disponíveis (Contato via Orquestrador)**
- **task-intelligence** (Sonnet/Haiku): Execução de tarefas
- **flutter-engineer**: Desenvolvimento end-to-end
- **code-intelligence** (Sonnet/Haiku): Análise de código
- **specialized-auditor** (quality/security/performance): Auditorias
- **analyzer-fixer** (Haiku): Correções automáticas
- **quick-fix-agent** (Haiku): Fixes pontuais rápidos

---

## 🏁 Conclusão

**app-nutrituti está em ESTADO CRÍTICO** mas **RECUPERÁVEL**.

**Diagnóstico**:
- 🔴 1170 erros de compilação → **Causa raiz: Build runner não executado**
- 🔴 Core package APIs desatualizadas → **Causa raiz: Breaking changes não sincronizadas**
- 🟡 3% migrado para Riverpod → **Oportunidade: 97% pendente, mas padrão repetitivo**
- 🟡 Arquitetura híbrida → **Oportunidade: Consolidar em Clean Architecture**

**Recomendação Final**: ✅ **EXECUTAR FASE 0 IMEDIATAMENTE (2-3h)**

**Sem FASE 0**, o app permanece **inutilizável**. Com FASE 0 completa:
- ✅ App volta a compilar
- ✅ Features básicas funcionam
- ✅ Desenvolvimento pode continuar
- ✅ FASE 1-3 podem ser planejadas com app funcional

**Próximo Checkpoint**: Após FASE 0, gerar relatório de progresso e ajustar estimativas para FASE 1-3.

---

**Status**: 🔴 **CRÍTICO - REQUER ATENÇÃO IMEDIATA**
**Risco Atual**: 🔴 **MUITO ALTO**
**Risco Após FASE 0**: 🟡 **MÉDIO (App funcional mas não otimizado)**
**Risco Após FASE 2**: 🟢 **BAIXO (App moderno e funcional)**
**Risco Após FASE 3**: 🟢 **MUITO BAIXO (Produção-ready)**

**Tempo para Produção-Ready**: ⏱️ **25-35 horas (1-1.5 semanas sprint intensivo)**

---

**Gerado por**: project-orchestrator
**Especialistas Consultados**: specialized-auditor (quality) + code-intelligence (Sonnet) + flutter-architect
**Data**: 2025-10-22
**Revisão**: v1.0 - Diagnóstico Multi-Especialista Completo
