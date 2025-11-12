# 🔍 Auditoria de Arquivos Duplicados/Legados

**Data**: 12 de Novembro de 2025  
**App**: ReceitaAgro  
**Status**: 🔴 **DUPLICADOS ENCONTRADOS**

---

## 📊 Resumo Executivo

**Total de duplicados encontrados**: 17 arquivos  
**Espaço desperdiçado**: ~85 KB  
**Linhas de código duplicadas**: ~2.000+

---

## 🔴 CATEGORIA 1: Backups de Sync (DELETAR)

### Arquivos:
1. ❌ `lib/core/sync/sync_operations_original.dart` (10 KB)
2. ❌ `lib/core/sync/sync_operations_backup.dart` (10 KB)
3. ❌ `lib/core/sync/sync_operations_disabled.dart` (266 bytes)

### Arquivo Ativo:
✅ `lib/core/sync/sync_operations.dart` (1.6 KB)

### Análise:
```dart
// Todos marcados como:
// TEMPORARILY DISABLED: Hive to Drift migration in progress
// ignore_for_file: undefined_class, undefined_identifier...
```

**Status**: ⚠️ **CÓDIGO MORTO**  
**Imports**: 0 (ninguém usa)  
**Ação**: 🔴 **DELETAR TODOS OS 3**

---

## 🟡 CATEGORIA 2: Versões "_refactored" (REVISAR)

### 1. **busca_usecase_refactored.dart**
- 📁 `lib/features/busca_avancada/domain/usecases/`
- ✅ **EM USO**: injection.config.dart importa
- 📊 Tamanho: 2.0 KB
- 🔄 Duplicado: `busca_usecase.dart` (3.7 KB)

**Decisão**: 🟡 Verificar qual é a versão correta

---

### 2. **get_pragas_usecase_refactored.dart**
- 📁 `lib/features/pragas/domain/usecases/`
- ✅ **EM USO**: injection.config.dart importa
- 📊 Tamanho: desconhecido
- 🔄 Duplicado: `get_pragas_usecase.dart` existe?

**Decisão**: 🟡 Verificar qual é a versão correta

---

### 3. **theme_notifier_refactored.dart**
- 📁 `lib/features/settings/presentation/providers/`
- ❌ **NÃO USADO**: 0 imports
- 📊 Tamanho: 2.3 KB (+ .g.dart 1.7 KB)
- 🔄 Duplicado: `theme_notifier.dart` (5.5 KB) ✅ EM USO

**Decisão**: �� **DELETAR refactored** (versão antiga não usada)

---

### 4. **composite_settings_provider_refactored.dart**
- 📁 `lib/features/settings/presentation/providers/`
- ❌ **NÃO USADO**: 0 imports
- 🔄 Duplicado: `composite_settings_provider.dart` existe?

**Decisão**: 🔴 **DELETAR refactored** (versão antiga não usada)

---

## 🟢 CATEGORIA 3: Versões "_drift" (VALIDAR)

### Duplicados Drift vs Normal:

| Arquivo Drift | Arquivo Normal | Status |
|---------------|----------------|--------|
| `diagnostico_with_warnings_drift.dart` | `diagnostico_with_warnings.dart` | 🟡 Verificar |
| `data_initialization_service_drift.dart` | `data_initialization_service.dart` | 🟡 Verificar |
| `diagnostico_entity_resolver_drift.dart` | `diagnostico_entity_resolver.dart` | ✅ Drift ativo |
| `app_data_manager_drift.dart` | `app_data_manager.dart` | ✅ Normal ativo |
| `diagnostico_compatibility_service_drift.dart` | `diagnostico_compatibility_service.dart` | 🟡 Verificar |
| `favoritos_storage_service_drift.dart` | `favoritos_storage_service.dart` | 🟡 Verificar |

**Total**: 6 pares duplicados

### Análise Necessária:
- Verificar qual versão está sendo importada
- Se Drift está ativo, deletar versão normal (Hive)
- Se Normal está ativo, deletar versão Drift (não implementada)

---

## 🔵 CATEGORIA 4: Arquivos de Teste (REVISAR)

### Encontrados:
1. `lib/core/widgets/ab_testing_widget.dart`
2. `lib/core/widgets/premium_test_controls_widget.dart`

**Status**: 🟢 Widgets de teste/debug (OK manter em dev)

---

## 🟠 CATEGORIA 5: "new_items" / Versões Novas

### Encontrados:
1. `lib/features/defensivos/presentation/widgets/defensivos_new_items_section.dart`

**Análise**: Verificar se existe versão sem "_new"

---

## 📋 Plano de Ação

### 🔴 **ALTA PRIORIDADE** - Deletar Backups (3 arquivos)

```bash
rm lib/core/sync/sync_operations_original.dart
rm lib/core/sync/sync_operations_backup.dart
rm lib/core/sync/sync_operations_disabled.dart
```

**Ganho**: -20 KB, -500 linhas

---

### 🟡 **MÉDIA PRIORIDADE** - Resolver Duplicados Drift (6 pares)

Para cada par, executar:

```bash
# 1. Verificar qual está sendo usado
grep -r "diagnostico_with_warnings_drift\|diagnostico_with_warnings" lib/ --include="*.dart" | grep "import"

# 2. Deletar o não usado
```

**Ganho estimado**: -30 KB, -800 linhas

---

### 🟡 **MÉDIA PRIORIDADE** - Resolver "_refactored" (4 arquivos)

#### Task 1: theme_notifier_refactored
```bash
# Confirmar que não é usado
grep -r "theme_notifier_refactored" lib/ --include="*.dart"
# Se 0 results:
rm lib/features/settings/presentation/providers/theme_notifier_refactored.dart
rm lib/features/settings/presentation/providers/theme_notifier_refactored.g.dart
```

#### Task 2: composite_settings_provider_refactored
```bash
# Similar ao acima
```

#### Task 3: busca_usecase_refactored
```bash
# EM USO! Decidir:
# Opção A: Renomear refactored → busca_usecase (deletar o antigo)
# Opção B: Manter refactored, deletar antigo
```

#### Task 4: get_pragas_usecase_refactored
```bash
# Similar ao acima
```

**Ganho estimado**: -15 KB, -400 linhas

---

## 📊 Análise Detalhada de Cada Duplicado

### 1. diagnostico_with_warnings (Drift vs Normal)

**Verificação necessária**:
```bash
grep -r "diagnostico_with_warnings" lib/ --include="*.dart" | grep "import" | grep -v ".g.dart"
```

**Decisão**: 
- Se usa "drift": deletar normal
- Se usa "normal": deletar drift

---

### 2. data_initialization_service (Drift vs Normal)

**Usado em**: injection_container.dart ?

**Verificação**:
```bash
grep -r "data_initialization_service" lib/ --include="*.dart" | grep "import"
```

---

### 3. diagnostico_entity_resolver (Drift vs Normal)

**Provável**: Drift é o ativo (já validado anteriormente)

**Ação**: Deletar versão normal se não usada

---

### 4. app_data_manager (Drift vs Normal)

**Provável**: Normal é o ativo

**Ação**: Deletar versão Drift se não usada

---

### 5. diagnostico_compatibility_service (Drift vs Normal)

**Verificação necessária**

---

### 6. favoritos_storage_service (Drift vs Normal)

**Verificação necessária**

---

## 🎯 Estatísticas de Limpeza Estimada

| Categoria | Arquivos | KB | Linhas | Prioridade |
|-----------|----------|----|----|------------|
| Backups sync | 3 | 20 | 500 | 🔴 Alta |
| Duplicados Drift | 6+ | 30 | 800 | 🟡 Média |
| Refactored não usados | 2-4 | 15 | 400 | 🟡 Média |
| **TOTAL** | **11-13** | **65** | **1.700** | - |

---

## ✅ Checklist de Validação

Antes de deletar qualquer arquivo:

- [ ] Verificar imports com grep
- [ ] Verificar se tem .g.dart associado
- [ ] Executar flutter analyze
- [ ] Conferir injection.config.dart
- [ ] Build runner após deletar

---

## 🚀 Execução Recomendada

### Fase 1: Backups (5 min)
1. Deletar sync_operations backups (3 arquivos)
2. Validar build

### Fase 2: Drift Duplicados (20 min)
1. Analisar cada par drift/normal
2. Deletar versões não usadas
3. Validar imports
4. Build runner

### Fase 3: Refactored (15 min)
1. Verificar usages
2. Deletar ou renomear
3. Atualizar imports se necessário
4. Validar build

**Tempo total estimado**: 40 minutos

---

**Gerado em**: 2025-11-12 17:45 UTC  
**Status**: 🔴 Ação necessária - 11-13 arquivos para limpar
