# 🔍 Relatório de Qualidade de Código - NebulaList

**Data**: 18/12/2025  
**Versão**: 1.0.0  
**Status**: Análise Completa

---

## 📊 Resumo Executivo

| Categoria | Status | Quantidade |
|-----------|--------|------------|
| Analyzer Errors | ✅ | 0 |
| Analyzer Warnings | ✅ | 0 |
| Analyzer Info | ⚠️ | 205 |
| TODOs Pendentes | ⚠️ | 39 |
| Código Morto | ⚠️ | ~5 itens |
| Deprecations | ⚠️ | ~30 ocorrências |
| Auto-fixable Issues | ✅ | 0 |

---

## 🚨 Problemas Identificados

### 1. **Deprecations (Alta Prioridade)**

#### 1.1 `withOpacity` → `withValues` (~25 ocorrências)
**Arquivos afetados:**
- `lib/features/items/presentation/pages/items_bank_page.dart`
- `lib/features/items/presentation/pages/list_detail_page.dart`
- `lib/features/items/presentation/widgets/add_item_to_list_dialog.dart`
- `lib/features/items/presentation/widgets/create_item_master_dialog.dart`
- `lib/features/items/presentation/widgets/item_master_empty_state.dart`
- `lib/features/items/presentation/widgets/list_item_tile.dart`
- `lib/features/items/presentation/widgets/list_items_empty_state.dart`
- `lib/features/lists/presentation/widgets/create_list_dialog.dart`
- `lib/features/lists/presentation/widgets/list_card.dart`
- `lib/features/lists/presentation/widgets/list_empty_state.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

**Fix:**
```dart
// ANTES (deprecated)
color.withOpacity(0.5)

// DEPOIS
color.withValues(alpha: 0.5)
```

#### 1.2 `Share.share` → `SharePlus.instance.share` (3 ocorrências)
**Arquivo:** `lib/core/services/share_service.dart`

**Fix:**
```dart
// ANTES (deprecated)
await Share.share(text, subject: subject);

// DEPOIS
await SharePlus.instance.share(ShareParams(text: text, subject: subject));
```

#### 1.3 `WillPopScope` → `PopScope` (1 ocorrência)
**Arquivo:** `lib/shared/widgets/feedback/app_dialog.dart:137`

**Fix:**
```dart
// ANTES (deprecated)
WillPopScope(
  onWillPop: () async => false,
  child: Dialog(...),
)

// DEPOIS
PopScope(
  canPop: false,
  child: Dialog(...),
)
```

#### 1.4 `Result` → `Either<Failure, T>` (~150 ocorrências)
**Arquivos afetados:**
- `lib/core/database/repositories/list_repository.dart`
- `lib/core/database/repositories/item_repository.dart`
- `lib/core/database/repositories/item_master_repository.dart`

**Nota:** Este é um padrão do core package. A migração requer alteração no core primeiro.

---

### 2. **TODOs Pendentes (39 total)**

#### 2.1 Configurações Placeholder (Alta Prioridade)
```
lib/core/config/app_config.dart:
- firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID'
- firebaseStorageBucket = 'YOUR_BUCKET.appspot.com'
- examplesCollection = 'examples'

lib/core/config/environment_config.dart:
- apiBaseUrl para dev/staging/production
- firebaseProjectId para cada ambiente
```

#### 2.2 Funcionalidades Não Implementadas (Média Prioridade)
```
lib/core/sync/basic_sync_service.dart:
- Implement actual sync when repositories have sync methods
- Implement when ListRepository has sync method
- Implement when ItemRepository has sync methods

lib/core/router/app_router.dart:
- Navegar para idioma
- Navegar para ajuda
- Navegar para sobre

lib/features/settings/presentation/pages/settings_page.dart:
- Implementar página de privacidade
- Implementar página de termos
- Integrate with theme provider
- Implement theme change
- Implement app rating
- Implement feedback form

lib/features/settings/presentation/pages/profile_page.dart:
- Get real date (Janeiro 2025)
- Implement edit profile
- Implement change password
- Implement account deletion

lib/features/settings/presentation/pages/notifications_settings_page.dart:
- Connect to actual settings provider
```

---

### 3. **Código Morto / Não Utilizado**

#### 3.1 Repositories Duplicados (Potencial Redundância)
```
Core Drift Repositories:
- lib/core/database/repositories/list_repository.dart (ListRepository)
- lib/core/database/repositories/item_repository.dart (ItemRepository)  
- lib/core/database/repositories/item_master_repository.dart (ItemMasterDriftRepository)

Feature Repositories (em uso):
- lib/features/lists/data/repositories/list_repository.dart
- lib/features/items/data/repositories/item_master_repository.dart
- lib/features/items/data/repositories/list_item_repository.dart
```

**Análise:** Os repositories do core (`core/database/repositories/`) parecem não estar sendo usados diretamente pelos features. Os datasources (`features/*/data/datasources/`) fazem queries diretamente ao database.

**Recomendação:** Consolidar ou remover repositories duplicados.

#### 3.2 Provider Não Utilizado
```
lib/core/providers/database_providers.dart:
- itemMasterDriftRepositoryProvider (definido mas não usado em features)
```

#### 3.3 Método Stub
```
lib/features/items/data/datasources/item_master_local_datasource.dart:
- getItemMastersSync() - retorna lista vazia, método stub
```

#### 3.4 Rotas Não Utilizadas
```
lib/core/config/app_constants.dart:
- exampleRoute = '/example'
- exampleDetailRoute = '/example/:id'
```

---

### 4. **Import de Pacotes Internos**

```
lib/core/providers/dependency_providers.dart:2
- Import of a library in the 'lib/src' directory of another package

lib/core/services/analytics_service.dart:1
- Import of a library in the 'lib/src' directory of another package
```

**Recomendação:** Usar exports públicos do pacote ao invés de imports diretos de `lib/src/`.

---

### 5. **Dependência Não Declarada**

```
lib/main.dart:5
- The imported package 'shared_preferences' isn't a dependency of the importing package
```

**Fix:** Adicionar `shared_preferences` ao pubspec.yaml ou usar via core package.

---

### 6. **Documentação com HTML não-intencional**

```
lib/features/items/domain/usecases/add_item_to_list_usecase.dart:18
lib/features/items/domain/usecases/create_item_master_usecase.dart:13
lib/features/lists/domain/usecases/check_list_limit_usecase.dart:15
lib/features/lists/domain/usecases/create_list_usecase.dart:13
lib/features/lists/domain/usecases/update_list_usecase.dart:13
```

**Fix:** Escapar `<` e `>` em doc comments:
```dart
// ANTES
/// Returns Either<Failure, Entity>

// DEPOIS  
/// Returns Either\<Failure, Entity\>
// ou
/// Returns `Either<Failure, Entity>`
```

---

## 📋 Plano de Ação Recomendado

### Fase 1: Quick Fixes (1-2 horas)
- [ ] Fix `withOpacity` → `withValues` (25 ocorrências)
- [ ] Fix `WillPopScope` → `PopScope` (1 ocorrência)
- [ ] Fix HTML em doc comments (5 ocorrências)
- [ ] Adicionar `shared_preferences` ao pubspec.yaml

### Fase 2: Deprecations (2-3 horas)
- [ ] Migrar `Share.share` → `SharePlus.instance.share`
- [ ] Atualizar imports de pacotes internos

### Fase 3: Limpeza de Código (3-4 horas)
- [ ] Remover rotas não utilizadas (exampleRoute)
- [ ] Remover método stub `getItemMastersSync()`
- [ ] Consolidar/remover repositories duplicados
- [ ] Remover provider não utilizado

### Fase 4: TODOs Críticos (4-6 horas)
- [ ] Configurar Firebase credentials reais
- [ ] Implementar BasicSyncService completo
- [ ] Implementar páginas pendentes (Privacidade, Termos)
- [ ] Conectar NotificationsSettingsPage ao provider

### Fase 5: Migração Result → Either (8+ horas)
- [ ] Criar issue no core package
- [ ] Migrar repositories após core update
- [ ] Atualizar todos os datasources

---

## 📊 Métricas de Qualidade

### Antes das Correções
```
Analyzer Issues: 205 (0 errors, 0 warnings, 205 info)
TODOs: 39
Deprecations: ~30
Dead Code: ~5 itens
```

### Após Fase 1-3 (Estimado)
```
Analyzer Issues: ~150 (0 errors, 0 warnings, ~150 info)
TODOs: 39 (sem mudança)
Deprecations: ~5
Dead Code: 0
```

### Após Fase 4-5 (Estimado)
```
Analyzer Issues: ~10 (0 errors, 0 warnings, ~10 info)
TODOs: ~10
Deprecations: 0
Dead Code: 0
```

---

## 🔧 Comandos Úteis

```bash
# Verificar issues
flutter analyze

# Auto-fix (se disponível)
dart fix --apply

# Verificar TODOs
grep -r "// TODO" lib/ --include="*.dart" | wc -l

# Verificar deprecations
flutter analyze 2>&1 | grep "deprecated"

# Verificar imports não usados
flutter analyze 2>&1 | grep "unused_import"
```

---

## 📝 Conclusão

O código está em **bom estado** com 0 errors e 0 warnings bloqueantes. Os principais problemas são:

1. **Deprecations** - APIs antigas que precisam ser atualizadas
2. **TODOs** - Funcionalidades pendentes de implementação
3. **Código duplicado** - Repositories em dois lugares

**Prioridade recomendada:**
1. ⚡ Fix deprecations (`withOpacity`, `WillPopScope`)
2. 🔧 Limpeza de código morto
3. 📝 Implementar TODOs críticos
4. 🔄 Migração `Result` → `Either` (após update do core)

**Quality Score Atual:** 9/10  
**Quality Score Potencial (após fixes):** 9.5/10

---

*Relatório gerado em 18/12/2025*
