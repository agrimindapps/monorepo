# 🐾 animals - Tarefas

**Feature**: animals
**Atualizado**: 2025-12-09
**Quality Score**: 8.5/10 (bloqueado por testes + sync)

---

## 📋 Backlog Priorizado

### 🔴 CRÍTICO (P0) - Bloqueadores

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-ANI-001 | 🔴 P0 | Integrar UnifiedSyncManager do core (remover NoOpSyncManager) | 8h | `data/repositories/animal_repository_impl.dart`, `presentation/providers/animals_providers.dart` |
| PET-ANI-002 | 🔴 P0 | Implementar testes de use cases (27 testes totais, ≥80% coverage) | 8h | `test/features/animals/domain/usecases/` |
| PET-ANI-003 | 🔴 P0 | Fix Logging Service (atualizar API calls) | 2h | `presentation/providers/animals_providers.dart:149` |

### 🟡 ALTA (P1) - Funcionalidades Core

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-ANI-004 | 🟡 P1 | Conectar search com SearchFilterStrategy + debounce 300ms | 2h | `presentation/widgets/animals_app_bar.dart:54,157` |
| PET-ANI-005 | 🟡 P1 | Implementar Filter Bottom Sheet (species, gender, size) | 8h | `presentation/widgets/animals_app_bar.dart:165` |
| PET-ANI-006 | 🟡 P1 | Adicionar filter badge e clear filters | 3h | `presentation/widgets/animals_app_bar.dart:30,39,119` |
| PET-ANI-007 | 🟡 P1 | Refatorar AddPetDialog (725→300 linhas, extrair seções) | 6h | `presentation/widgets/add_pet_dialog.dart` |
| PET-ANI-008 | 🟡 P1 | Implementar Image Upload (picker + crop + Firebase Storage) | 8h | `presentation/widgets/add_pet_dialog.dart` |

### 🟢 MÉDIA (P2) - Qualidade e Testes

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-ANI-009 | 🟢 P2 | Implementar testes de services (validation + error handling) | 8h | `test/features/animals/domain/services/` |
| PET-ANI-010 | 🟢 P2 | Implementar testes de repository | 8h | `test/features/animals/data/repositories/` |
| PET-ANI-011 | 🟢 P2 | Implementar widget tests (page, card, dialog) | 6h | `test/features/animals/presentation/widgets/` |
| PET-ANI-012 | 🟢 P2 | Implementar integration tests E2E (create, edit, delete, sync) | 6h | `integration_test/` |

### 🔵 BAIXA (P3) - Melhorias

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-ANI-013 | 🔵 P3 | Descomentar empty state de filtros | 1h | `presentation/widgets/animals_body.dart:87-94` |
| PET-ANI-014 | 🔵 P3 | Implementar Form Auto-save (draft persistence) | 4h | `presentation/widgets/add_pet_dialog.dart` |
| PET-ANI-015 | 🔵 P3 | Integrar cached_network_image para photos | 4h | `presentation/widgets/animal_card.dart` |
| PET-ANI-016 | 🔵 P3 | Adicionar índices Drift (userId performance) | 3h | `lib/database/tables/animals_table.dart` |
| PET-ANI-017 | 🔵 P3 | Remover código morto (animal_model_adapter.dart) | 30min | `data/models/animal_model_adapter.dart` |
| PET-ANI-018 | 🔵 P3 | Documentar public APIs com dartdoc | 4h | Todos arquivos públicos |

---

## ✅ Concluídas Recentemente

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 09/12 | Análise profunda da feature | ✅ Relatório completo com 35 arquivos analisados |
| 09/12 | Identificação de gaps críticos | ✅ 11 TODOs mapeados, sync blocker identificado |

---

## 📊 Métricas da Feature

| Métrica | Valor | Status |
|---------|-------|--------|
| **Arquivos .dart** | 35 | - |
| **Linhas de código** | ~4,500 | - |
| **Test Coverage** | 0% | ❌ CRÍTICO |
| **Analyzer Errors** | 0 | ✅ |
| **Analyzer Warnings** | 0 | ✅ |
| **TODOs no código** | 11 | ⚠️ |
| **Health Score** | 8.5/10 | ⚠️ |

---

## 📝 Notas Técnicas

### Arquitetura
- ✅ Clean Architecture rigorosa (3 camadas)
- ✅ SOLID Principles aplicados (SRP: specialized services)
- ✅ Strategy Pattern (filters)
- ✅ Riverpod 3.0 com code generation
- ✅ Either<Failure, T> em toda domain layer

### Gaps Críticos
- ❌ **NoOpSyncManager**: Sync não funciona (blocker P0)
- ❌ **Zero testes**: Blocker para produção
- ❌ **Search não conectado**: UI implementada mas não funciona
- ❌ **Filters UI incompleto**: Strategies prontos, falta bottom sheet

### Próximos Passos Recomendados
1. **Sprint 1 (P0)**: Sync + Logging + Testes de use cases → 18h
2. **Sprint 2 (P1)**: Search + Filters UI → 14h
3. **Sprint 3 (P1)**: Refactor form + Image upload → 14h
4. **Sprint 4 (P2)**: Testes completos → 20h

**Estimativa total para 10/10**: ~66 horas (8-9 dias)

---

## 🔗 Links Relacionados

- [README Completo](./README.md) - Documentação técnica detalhada
- [ANALYSIS_REPORT.md](../../ANALYSIS_REPORT.md) - Relatório de migração Riverpod
- [Backlog Global](../../backlog/README.md) - Tarefas cross-feature

---

*Última análise: 2025-12-09 | Agente: code-intelligence (Sonnet 4.5)*
