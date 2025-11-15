# 📊 FLUTTER ANALYZE - APP-RECEITUAGRO
## Relatório Completo de Erros Críticos

**Data:** 15 de Novembro de 2025
**Executado:** `flutter analyze` na raiz do app-receituagro

---

## 🔍 RESUMO EXECUTIVO

**Total de Issues:** 1,603
- 🔴 **Errors (Críticos):** 671
- 🟡 **Warnings:** 443
- 🟢 **Info:** 489

**Build Status:** Passou em Web (com stubs temporários), mas Analyze encontra 671 erros críticos

---

## 📋 ERROS CRÍTICOS - TOP 5 ARQUIVOS

### 🔴 1. diagnosticos_filter_notifier.dart (40+ erros)
**Localização:** `lib/features/diagnosticos/presentation/notifiers/diagnosticos_filter_notifier.dart`

**Erros principais:**
- `Classes can only extend other classes` (linha 13)
- `Too many positional arguments: 0 expected, but 1 found` (linha 15)
- `Undefined name 'state'` (40+ ocorrências em todo o arquivo)

**Causa:** Arquivo tem sintaxe/estrutura quebrada. Provavelmente usa classe base incorreta ou está com pattern de Notifier quebrado.

**Impacto:** 🔴 CRÍTICO - Módulo de filtros de diagnósticos não funciona

**Solução Recomendada:** Revisar/reescrever completamente a estrutura de classe. Verificar se deve herdar de StateNotifier ou usar @riverpod pattern.

---

### 🔴 2. user_data_repository.dart (6 erros)
**Localização:** `lib/core/data/repositories/user_data_repository.dart:123-133`

**Erros principais:**
- `The method 'whereType' isn't defined for the type 'Either'`
- Múltiplos `argument_type_not_assignable: dynamic -> String`

**Causa:** Either<Failure, T> não pode ser usado como collection. Precisa fazer unwrap com .fold() antes de usar métodos de collection.

**Impacto:** 🔴 CRÍTICO - Carregamento de dados de usuário quebrado

**Solução:**
```dart
// ❌ INCORRETO:
Either.right(data).whereType<String>()

// ✅ CORRETO:
Either.right(data).fold(
  (failure) => [],
  (data) => (data as List).whereType<String>().toList()
)
```

---

### 🔴 3. database_initialization.dart (2 erros)
**Localização:** `lib/database/initialization/database_initialization.dart:49,52`

**Erros principais:**
- `The method 'count' isn't defined for the type 'GeneratedColumn'`

**Causa:** `.count()` usado diretamente em GeneratedColumn fora do contexto `selectOnly()`

**Impacto:** 🟡 ALTO - Inicialização do banco de dados pode falhar

**Solução:**
```dart
// ❌ INCORRETO:
final count = _db.table.id.count();

// ✅ CORRETO:
final countColumn = _db.table.id.count();
final query = _db.selectOnly(_db.table)
  ..addColumns([countColumn]);
final result = await query.getSingle();
return result.read(countColumn)!;
```

---

### 🔴 4. busca_avancada - busca_repository_impl.dart (8 erros)
**Localização:** `lib/features/busca_avancada/data/repositories/busca_repository_impl.dart:191-223`

**Erros principais:**
- `argument_type_not_assignable: dynamic -> String?` (5 ocorrências)
- `argument_type_not_assignable: dynamic -> Map<dynamic, dynamic>` (2 ocorrências)

**Causa:** JSON/map data carregado de repositórios sem type casting apropriado

**Impacto:** 🟡 ALTO - Busca avançada com filtros não funciona corretamente

**Solução:**
```dart
// ❌ INCORRETO:
final nome = jsonData['nome'];  // dynamic

// ✅ CORRETO:
final data = (jsonData as Map<String, dynamic>);
final nome = (data['nome'] as String?);
final filtros = (data['filtros'] as Map<String, dynamic>? ?? {});
```

---

### 🔴 5. busca_avancada_notifier.dart (4 erros)
**Localização:** `lib/features/busca_avancada/presentation/providers/busca_avancada_notifier.dart:282-293`

**Erros principais:**
- `1 positional argument expected by 'hasActiveFilters', but 0 found`
- `undefined_named_parameter: culturaId, pragaId, defensivoId`
- `The method 'buildFiltrosAtivosTexto' isn't defined`

**Causa:** Interface `IBuscaValidationService` não define os métodos esperados ou assinatura mudou

**Impacto:** 🟡 ALTO - Notifier de busca avançada não funciona

**Solução:** Atualizar assinatura de métodos na interface `IBuscaValidationService` ou refatorar as chamadas.

---

## 📊 DISTRIBUIÇÃO DE ERROS POR TIPO

### Erros por Categoria (dos 671 errors):

| Categoria | Quantidade | Exemplos |
|-----------|-----------|----------|
| Type Casting / Conversão | ~200 | dynamic -> String, Map type casting |
| Method Not Found / Undefined | ~150 | Métodos faltando em interfaces/classes |
| Structure/Syntax Issues | ~120 | diagnosticos_filter_notifier broken |
| Either<T> Unwrapping | ~80 | whereType, map, filter em Either |
| Drift Database | ~60 | .count(), .contains() patterns |
| Test Setup | ~30 | mocktail, mock definitions |
| Outros | ~31 | Various |

---

## 🎯 PLANO DE AÇÃO - PRIORIDADE

### 🔴 FASE 1 - CRÍTICO (Bloqueia funcionalidade principal)
**Tempo Estimado:** 3.5 horas

1. **diagnosticos_filter_notifier.dart**
   - Restruturar classe (2-3 horas)
   - Verificar padrão Riverpod vs StateNotifier
   - Implementar getters 'state' corretamente

2. **user_data_repository.dart**
   - Fixar Either unwrapping em todas as linhas (1 hora)
   - Adicionar type casting apropriado

3. **database_initialization.dart**
   - Fixar .count() pattern (30 min)
   - Validar selectOnly() usage

### 🟡 FASE 2 - IMPORTANTE (Afeta features secundárias)
**Tempo Estimado:** 4-5 horas

1. **busca_avancada type casting**
   - Adicionar type casts em busca_repository_impl.dart (1-2 horas)

2. **busca_avancada_notifier signatures**
   - Atualizar interface IBuscaValidationService (1 hora)
   - Refatorar chamadas em notifier (1 hora)

3. **Test files - Setup mocktail**
   - Adicionar imports faltantes (30 min)
   - Setup mock definitions (1-1.5 horas)

### 🟢 FASE 3 - MANUTENÇÃO (Warnings e Info)
**Tempo Estimado:** 1-2 horas

1. **Naming conventions**
   - sync_* variables using snake_case (baixa prioridade - apenas info)

2. **Unused imports/classes**
   - Limpeza geral (baixa prioridade)

---

## ⏱️ ESTIMATIVA DE TEMPO TOTAL

| Fase | Tempo |
|------|-------|
| FASE 1 (Crítico) | 3.5h |
| FASE 2 (Importante) | 4-5h |
| FASE 3 (Manutenção) | 1-2h |
| **TOTAL** | **8.5-10.5h** |

---

## 🔗 ARQUIVOS AFETADOS

**Arquivos com múltiplos erros (prioritários):**
- lib/features/diagnosticos/presentation/notifiers/diagnosticos_filter_notifier.dart (40+ erros)
- lib/features/busca_avancada/data/repositories/busca_repository_impl.dart (8+ erros)
- lib/core/data/repositories/user_data_repository.dart (6+ erros)
- lib/features/busca_avancada/presentation/providers/busca_avancada_notifier.dart (4+ erros)
- lib/database/initialization/database_initialization.dart (2+ erros)

**Test files com issues:**
- test/features/settings/presentation/providers/notifiers/theme_notifier_test.dart (20+ erros)

---

## 📌 RECOMENDAÇÕES

1. **Começar pela FASE 1** para ter um codebase compilável sem stubs temporários
2. **Focar em diagnosticos_filter_notifier.dart** primeiro - tem maior impacto (40+ erros = ~25% de todos os errors)
3. **Padronizar Either unwrapping** - padrão recorrente que pode ser aplicado a vários arquivos
4. **Type casting** - segunda maior categoria de erros (200 ocorrências)
5. **Drift patterns** - consolidar padrão correto de .count() em todos os repos

---

## ✅ PRÓXIMAS AÇÕES

- [ ] FASE 1: Corrigir diagnosticos_filter_notifier.dart
- [ ] FASE 1: Fixar user_data_repository.dart
- [ ] FASE 1: Fixar database_initialization.dart
- [ ] FASE 2: Type casting em busca_avancada
- [ ] FASE 2: Atualizar interfaces e signatures
- [ ] FASE 2: Test setup
- [ ] FASE 3: Limpeza e refatoração

---

**Gerado em:** 15 de Novembro de 2025
**Comando:** `flutter analyze`
**Status:** Pronto para ação
