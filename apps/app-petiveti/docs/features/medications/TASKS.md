# 💊 medications - Tarefas

**Feature**: medications
**Atualizado**: 2025-12-09
**Quality Score**: 7.5/10 (bloqueado por testes)

---

## 📋 Backlog Priorizado

### 🔴 CRÍTICO (P0) - Bloqueadores Produção

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-MED-001 | 🔴 P0 | Implementar testes de use cases (40 testes, ≥60% coverage) | 16h | `test/features/medications/domain/usecases/` |
| PET-MED-002 | 🔴 P0 | Implementar testes de validation service (15 testes) | 4h | `test/features/medications/domain/services/` |
| PET-MED-003 | 🔴 P0 | Completar métodos pendentes no local datasource (watchMedications, getActiveMedications, etc) | 8h | `data/datasources/medication_local_datasource.dart` (10 TODOs) |

### 🟡 ALTA (P1) - Funcionalidades Core

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-MED-004 | 🟡 P1 | Integrar UnifiedSyncManager do core (substituir placeholders) | 8h | `data/repositories/medication_repository_impl.dart` (3 TODOs de sync) |
| PET-MED-005 | 🟡 P1 | Implementar hard delete e cleanup automático | 6h | Repository + DAO |
| PET-MED-006 | 🟡 P1 | Adicionar paginação (lazy loading) | 8h | Repository + UI |
| PET-MED-007 | 🟡 P1 | Implementar testes de widgets e notifier (20 testes) | 8h | `test/features/medications/presentation/` |

### 🟢 MÉDIA (P2) - Qualidade e Melhorias

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-MED-008 | 🟢 P2 | Implementar emergency sync logic (isCritical = true) | 8h | Sync service |
| PET-MED-009 | 🟢 P2 | Implementar conflict resolution UI | 8h | Nova feature |
| PET-MED-010 | 🟢 P2 | Adicionar índices compostos Drift (performance) | 2h | Schema |
| PET-MED-011 | 🟢 P2 | Implementar export/import (CSV, PDF) | 6h | Nova feature |

### 🔵 BAIXA (P3) - Polish e Otimizações

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-MED-012 | 🔵 P3 | Otimizar MedicationsPage (memoization, lazy loading) | 4h | `presentation/pages/medications_page.dart` |
| PET-MED-013 | 🔵 P3 | Implementar cache de queries | 3h | Repository |
| PET-MED-014 | 🔵 P3 | Adicionar analytics tracking | 4h | Notifier |
| PET-MED-015 | 🔵 P3 | Documentar APIs públicas com dartdoc | 4h | Todos arquivos |

---

## ✅ Concluídas Recentemente

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 09/12 | Análise profunda da feature | ✅ Relatório completo de 3,500+ linhas |
| 09/12 | Identificação de 13 TODOs no código | ✅ 10 no local datasource, 3 em sync |

---

## 📊 Métricas da Feature

| Métrica | Valor | Status |
|---------|-------|--------|
| **Arquivos .dart** | 25 | - |
| **Linhas de código** | ~3,000 | - |
| **Use Cases** | 9 | ✅ |
| **Providers** | 20+ | ✅ |
| **Test Coverage** | 0% | ❌ CRÍTICO |
| **TODOs no código** | 13 | 🔴 |
| **Health Score** | 7.5/10 | ⚠️ |

---

## 📝 Notas Técnicas

### Arquitetura
- ✅ Clean Architecture (95% adherence)
- ✅ SOLID Principles (100%)
- ✅ Rich Domain Model (8 getters computados, 9 tipos, 4 status)
- ✅ Offline-first strategy bem definida
- ✅ Pure Riverpod com code generation
- ✅ UI rica e performática (accessibility, optimization)

### Gaps Críticos
- ❌ **ZERO Test Coverage**: Blocker absoluto para produção
- ❌ **10 TODOs no Local DataSource**: Funcionalidades offline incompletas
- ❌ **3 TODOs de Sync**: UnifiedSyncManager não integrado
- ❌ **Hard Delete Ausente**: Banco crescerá infinitamente

### Sprints Recomendados

**Sprint 1 (CRITICAL - 1 semana):**
1. Testes de use cases (40 testes) - 2 dias
2. Testes de validation service (15 testes) - 4h
3. Completar local datasource - 1 dia
4. **Target: 60% test coverage**

**Sprint 2 (Performance - 1 semana):**
1. Completar métodos restantes do datasource - 2 dias
2. Adicionar paginação - 1 dia
3. Testes de widgets/notifier (20 testes) - 1 dia
4. **Target: 80% test coverage**

**Sprint 3 (Sync - 1 semana):**
1. Integrar UnifiedSyncManager - 1 dia
2. Implementar emergency sync logic - 1 dia
3. Conflict resolution UI - 1 dia

**Estimativa total para 10/10**: ~80 horas (10 dias)

---

## 🔗 Links Relacionados

- [README Completo](./README.md) - Documentação técnica detalhada
- [ANALYSIS_REPORT.md](../../ANALYSIS_REPORT.md) - Relatório de migração Riverpod
- [Backlog Global](../../backlog/README.md) - Tarefas cross-feature

---

*Última análise: 2025-12-09 | Agente: code-intelligence (Sonnet 4.5)*
