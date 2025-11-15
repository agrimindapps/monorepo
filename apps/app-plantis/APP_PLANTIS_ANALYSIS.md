# 📊 APP-PLANTIS - ANÁLISE DE ERROS E PLANO DE CORREÇÃO

**Data:** 15 de Novembro de 2025
**Status:** Análise Completa - Pronto para Correções

---

## 🔍 RESUMO EXECUTIVO

**Total de Issues:** 772
- 🔴 **Errors:** 80 (10%)
- 🟡 **Warnings:** 69 (9%)
- 🟢 **Info:** 623 (81%)

**Build Status:** ❌ Falha na compilação web
**Razão:** 80 erros críticos (comparado com 671 no app-receituagro - **11.9% do tamanho!**)

---

## 🎯 ERROS CRÍTICOS - ANÁLISE DETALHADA

### 1. DRIFT DATABASE ISSUES (20+ erros)
**Localização:** `lib/database/tables/plantis_tables.dart`

**Problema:**
```
- Ambiguous import: 'Column' definido em drift E flutter
- Invalid override: uniqueKeys return type mismatch
- Afeta 6 tabelas: Spaces, Plants, PlantConfigs, PlantTasks, Tasks, Comments, ConflictHistory
```

**Causa:** `import 'package:core/core.dart'` exporta Column do Flutter, conflitando com Drift

**Solução:**
```dart
import 'package:core/core.dart' hide Column;  // ← Esconder Column do Flutter
import 'package:drift/drift.dart';            // ← Usar Column do Drift
```

**Impacto:** 🔴 CRÍTICO - Bloqueia geração de código Drift

---

### 2. DATABASE PROVIDER ISSUE (1 erro)
**Localização:** `lib/database/providers/database_providers.dart:38`

**Problema:**
```
The method 'injectable' isn't defined for the type 'PlantisDatabase'
```

**Causa:** PlantisDatabase pode não ter @injectable annotation ou método removido

**Solução:** Verificar se PlantisDatabase tem `@lazySingleton` ou `@singleton` ao invés de `@injectable`

---

### 3. TASK QUERY NOTIFIER - LIST/SET MISMATCHES (10+ erros)
**Localização:** `lib/features/tasks/presentation/notifiers/tasks_query_notifier.dart`

**Problema:**
```
Line 53-54:   List<TaskType> → Set<String> (incompatível)
Line 77-78:   List<TaskPriority> → Set<int> (incompatível)
Line 162:     Set<int> → List<TaskPriority> (incompatível)
Line 106-107: Object → Set (incompatível)
```

**Causa:** Interface de filtro espera Set mas código passa List

**Solução:**
```dart
// ❌ ANTES:
someMethod(listVariable)

// ✅ DEPOIS:
someMethod(listVariable.toSet())  // ou .toList() dependendo da direção
```

**Impacto:** 🟡 ALTO - Filtros de tarefas não funcionam

---

### 4. TASK PRIORITY COMPARISON ISSUES (5+ erros)
**Localização:** `lib/features/tasks/presentation/notifiers/tasks_recommendation_notifier.dart`

**Problema:**
```
Line 38:   task.priority >= 8        (>= não definido para TaskPriority)
Line 67:   compareTo() method undefined
Line 104:  Similar >= issue
Line 162:  TaskPriority → int (type mismatch)
```

**Causa:** TaskPriority é um enum/custom type que não suporta comparação numérica

**Solução Opção A (se TaskPriority é enum com valores):**
```dart
task.priority.index >= 8  // Usar .index se for enum
```

**Solução Opção B (se precisa comparar com int):**
```dart
(task.priority as int) >= 8  // Cast para int
```

**Impacto:** 🟡 ALTO - Sistema de recomendação quebrado

---

### 5. TASK PROPERTIES MISSING (3+ erros)
**Localização:** `lib/features/tasks/presentation/notifiers/tasks_schedule_notifier.dart`

**Problema:**
```
Line 91, 97:   recurringInterval getter não existe
Line 98:       recurringEndDate getter não existe
Line 106:      Task constructor não tem 'id' parameter
```

**Causa:** Propriedades foram renomeadas ou removidas da entidade Task

**Solução:**
1. Verificar definição de Task em `lib/features/tasks/domain/entities/task.dart`
2. Usar nomes de propriedade corretos
3. Verificar constructor de Task para parâmetro 'id'

**Impacto:** 🟡 ALTO - Tarefas recorrentes não funcionam

---

### 6. NULLABLE VALUE ISSUE (1 erro)
**Localização:** `lib/features/tasks/data/repositories/tasks_repository_impl.dart:678`

**Problema:**
```
A nullable expression can't be used as a condition
```

**Solução:**
```dart
// ❌ ANTES:
if (nullableVar.someProperty) { }

// ✅ DEPOIS:
if (nullableVar != null && nullableVar.someProperty) { }
```

---

## 📊 DISTRIBUIÇÃO DE ERROS

| Categoria | Quantidade | Arquivos | Prioridade |
|-----------|-----------|----------|-----------|
| Drift Import | 20 | plantis_tables.dart | 🔴 CRÍTICO |
| List/Set Mismatch | 10 | tasks_query_notifier.dart | 🟡 ALTO |
| TaskPriority Issues | 5 | tasks_recommendation_notifier.dart | 🟡 ALTO |
| Task Properties | 3 | tasks_schedule_notifier.dart | 🟡 ALTO |
| Provider Issues | 1 | database_providers.dart | 🟡 ALTO |
| Nullable Issues | 1 | tasks_repository_impl.dart | 🟢 MÉDIO |
| Test Errors | 35 | test files | 🟢 BAIXO |

---

## 🎯 PLANO DE AÇÃO

### FASE 1 - CRÍTICO (30 min)
1. **Fixar Drift Import** (plantis_tables.dart)
   - Adicionar `hide Column` ao import de core
   - Impacto: Resolve 20 erros imediatamente

### FASE 2 - IMPORTANTE (1-2 horas)
1. **Fixar List/Set Mismatches** (tasks_query_notifier.dart)
   - Converter List → Set com `.toSet()`
   - Converter Set → List com `.toList()`

2. **Fixar TaskPriority Issues** (tasks_recommendation_notifier.dart)
   - Adicionar enum methods ou casts
   - Fixar comparação de prioridades

3. **Fixar Task Properties** (tasks_schedule_notifier.dart)
   - Verificar e corrigir nomes de propriedades
   - Fixar constructor parameters

### FASE 3 - COMPLEMENTAR (30 min)
1. Fixar nullable values
2. Fixar database provider
3. Corrigir testes

---

## ✅ PRÓXIMOS PASSOS

1. **Imediato:**
   - Aplicar correção de Drift import (résolution de 20 erros)
   - Rodar web build novamente
   - Verificar erros restantes

2. **Seguinte:**
   - Fixar List/Set mismatches
   - Fixar TaskPriority comparisons
   - Verificar Task entity definition

3. **Final:**
   - Corrigir testes
   - Rodar flutter analyze
   - Confirmar 0 erros críticos

---

## 📈 ESTIMATIVA

- **FASE 1:** 30 minutos
- **FASE 2:** 1-2 horas
- **FASE 3:** 30 minutos
- **TOTAL:** 2-3 horas (muito mais rápido que app-receituagro!)

---

## 🎁 BOM SINAL

App-plantis é o "Gold Standard 10/10" do monorepo - somente 80 erros contra 671 do app-receituagro.

**Conclusão:** Correções devem ser rápidas e diretas!

---

**Status:** Pronto para implementar correções
**Prioridade:** Alta (Gold Standard deve estar perfeito)
**Complexidade:** Média (erros bem localizados)
