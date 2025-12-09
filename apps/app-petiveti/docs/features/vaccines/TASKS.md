# 💉 vaccines - Tarefas

**Feature**: vaccines
**Atualizado**: 2025-12-09
**Quality Score**: 8/10 (bloqueado por testes + auth)

---

## 📋 Backlog Priorizado

### 🔴 CRÍTICO (P0) - Bloqueadores Produção

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-VAC-001 | 🔴 P0 | Integrar auth provider real (remover temp_user_id hardcoded) | 2h | `presentation/providers/vaccines_providers.dart`, `data/datasources/vaccines_remote_datasource.dart` |
| PET-VAC-002 | 🔴 P0 | Implementar testes de use cases (91+ testes, ≥75% coverage) | 20h | `test/features/vaccines/domain/usecases/` |
| PET-VAC-003 | 🔴 P0 | Sistema de notificações real (flutter_local_notifications) | 12h | `domain/services/vaccine_notification_service.dart` |

### 🟡 ALTA (P1) - Funcionalidades Core

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-VAC-004 | 🟡 P1 | Implementar sincronização reversa completa (Firebase → Drift) | 16h | `data/repositories/vaccine_repository_impl.dart` |
| PET-VAC-005 | 🟡 P1 | Implementar testes de repositories (CRUD + sync logic) | 15h | `test/features/vaccines/data/repositories/` |
| PET-VAC-006 | 🟡 P1 | Otimizar performance (índices Drift, queries batch) | 4h | Schema Drift + DAOs |
| PET-VAC-007 | 🟡 P1 | Implementar filtros avançados UI (veterinarian, manufacturer) | 8h | `presentation/widgets/vaccine_filters.dart` |

### 🟢 MÉDIA (P2) - Qualidade e Melhorias

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-VAC-008 | 🟢 P2 | Implementar Export/Import UI (CSV, PDF) | 6h | Nova feature |
| PET-VAC-009 | 🟢 P2 | Implementar testes de presentation (notifiers, widgets) | 20h | `test/features/vaccines/presentation/` |
| PET-VAC-010 | 🟢 P2 | Refatorar VaccineCard (536→300 linhas, extrair componentes) | 3h | `presentation/widgets/vaccine_card.dart` |
| PET-VAC-011 | 🟢 P2 | Implementar testes de data sources (local + remote) | 10h | `test/features/vaccines/data/datasources/` |

### 🔵 BAIXA (P3) - Polish e Cleanup

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-VAC-012 | 🔵 P3 | Remover arquivos duplicados (vaccine_scheduling_interface vs _refactored) | 30min | `domain/services/` |
| PET-VAC-013 | 🔵 P3 | Adicionar índices compostos Drift (animalId + date) | 2h | Schema Drift |
| PET-VAC-014 | 🔵 P3 | Implementar cache de queries frequentes | 3h | Repositories |
| PET-VAC-015 | 🔵 P3 | Documentar APIs públicas com dartdoc | 4h | Todos arquivos públicos |

---

## ✅ Concluídas Recentemente

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 09/12 | Análise profunda da feature | ✅ Relatório completo com 40 arquivos (~5,500 LOC) |
| 09/12 | Identificação de 3 gaps críticos | ✅ Auth hardcoded, zero testes, notificações mockadas |

---

## 📊 Métricas da Feature

| Métrica | Valor | Status |
|---------|-------|--------|
| **Arquivos .dart** | 40 | - |
| **Linhas de código** | ~5,500 | - |
| **Use Cases** | 13 | ✅ |
| **Providers** | 20+ | ✅ |
| **Test Coverage** | 0% | ❌ CRÍTICO |
| **TODOs Críticos** | 3 | 🔴 |
| **Health Score** | 8/10 | ⚠️ |

---

## 📝 Notas Técnicas

### Arquitetura
- ✅ Clean Architecture rigorosa (3 camadas isoladas)
- ✅ SOLID Principles em todos services
- ✅ Pure Riverpod 100% com code generation
- ✅ Offline-first com Drift + Firebase
- ✅ Either<Failure, T> em toda domain layer

### Gaps Críticos
- ❌ **Auth Provider Hardcoded**: `temp_user_id` mockado (blocker P0)
- ❌ **Zero Testes**: 0% coverage (blocker produção)
- ❌ **Notificações Mockadas**: Observer pattern pronto, implementação faltando
- ⚠️ **Sync Reversa Incompleta**: Firebase → Drift pode perder dados offline

### Próximos Passos Recomendados
1. **Sprint 1 (P0)**: Auth + Testes use cases + Notificações → 34h
2. **Sprint 2 (P1)**: Sync reversa + Testes repositories + Performance → 35h
3. **Sprint 3 (P2)**: Testes presentation + Melhorias → 33h

**Estimativa total para 10/10**: ~102 horas (13 dias)

---

## 🔗 Links Relacionados

- [README Completo](./README.md) - Documentação técnica detalhada (254 linhas)
- [ANALYSIS_REPORT.md](../../ANALYSIS_REPORT.md) - Relatório de migração Riverpod
- [Backlog Global](../../backlog/README.md) - Tarefas cross-feature

---

*Última análise: 2025-12-09 | Agente: code-intelligence (Sonnet 4.5)*
