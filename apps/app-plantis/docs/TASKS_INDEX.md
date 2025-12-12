# 📋 Índice Global de Tarefas - App Plantis

**Última atualização**: 13/12/2025 12:00  
**Sistema de tracking**: Feature-based (cada feature tem seu TASKS.md)

---

## 🎯 Visão Geral

### 📊 Estatísticas Globais

| Métrica | Valor |
|---------|-------|
| **Features com tarefas** | 4 |
| **Tarefas críticas** | 3 |
| **Tarefas de alta prioridade** | 1 |
| **Tarefas de média/baixa** | 1 |
| **Total de tarefas** | 5 |
| **Horas estimadas** | ~76h |

---

## 🔥 Top 10 Tarefas Críticas (Prioridade Máxima)

| # | Feature | ID | Tarefa | Estimativa | Impacto |
|---|---------|----|----- --|------------|---------|
| 1 | **plants** | PLT-PLANTS-005 | Testes plants (0% → 70%) | 40h | 🧪 TESTES |
| 2 | **tasks** | PLT-TASKS-002 | Testes tasks (0% → 60%) | 12h | 🧪 TESTES |
| 3 | **premium** | PLT-PREMIUM-004 | Testes premium (0% → 60%) | 12h | 🧪 TESTES |

**Total Crítico**: 64h (~1.5 semanas com 1 dev)

---

## 📁 Tarefas por Feature

### 🔐 Auth (1 tarefa, 16h)

**Arquivos**: [features/auth/TASKS.md](features/auth/TASKS.md) | [ARCHITECTURE.md](features/auth/ARCHITECTURE.md)

**Altas (1)**:
- PLT-AUTH-007: Testes (16h)

**✅ Concluídas (7)**:
- ✅ PLT-AUTH-002: Refatorar AuthPage (2.5h vs 24h) - 13/12/2025 ⚡ 90% mais rápido
- ✅ PLT-AUTH-004: Implementar AuthSubmissionManager (0.15h vs 12h) - 13/12/2025
- ✅ PLT-AUTH-005: Consolidar validações (0.1h vs 8h) - 13/12/2025
- ✅ PLT-AUTH-009: Documentar fluxo (0.15h vs 4h) - 13/12/2025
- ✅ PLT-AUTH-006: Usar CredentialsPersistenceManager (0.1h vs 4h) - 13/12/2025
- ✅ PLT-AUTH-003: Remover código duplicado (0.05h vs 8h) - 13/12/2025
- ✅ PLT-AUTH-008: Remover auto-login debug (0.05h vs 0.5h) - 13/12/2025
- ✅ PLT-AUTH-001: Criar camada data (0.3h vs 24h) - 13/12/2025

---

### 🌱 Plants (1 tarefa, 40h)

**Arquivos**: [features/plants/TASKS.md](features/plants/TASKS.md)

**Críticas (1)**:
- PLT-PLANTS-005: Testes (40h)

**✅ Concluídas (7)**:
- ✅ PLT-PLANTS-003: PlantsCacheManager (3h vs 56h) - 23/01/2025 ⚡ 95% mais rápido
- ✅ PLT-PLANTS-004: Refatorar Plant.fromPlantaModel (1h vs 12h) - 23/01/2025 ⚡ 92% mais rápido
- ✅ PLT-PLANTS-006: PlantsDomainOrchestrator (2h vs 16h) - 13/12/2025 ⚡ 88% mais rápido
- ✅ PLT-PLANTS-007: Tratamento de erro tasks/comentários (0.1h vs 8h) - 13/12/2025
- ✅ PLT-PLANTS-001: Implementar update no CommentsDriftRepository (0.05h vs 4h) - 13/12/2025
- ✅ PLT-PLANTS-008: Documentar soft delete (0.1h vs 2h) - 13/12/2025
- ✅ PLT-PLANTS-002: Inicializar repository (0.05h vs 2h) - 13/12/2025

---

### ✅ Tasks (2 tarefas, 16h)

**Arquivos**: [features/tasks/TASKS.md](features/tasks/TASKS.md)

**Críticas (1)**:
- PLT-TASKS-002: Testes (12h)

**Altas (1)**:
- PLT-TASKS-004: Validação nextDueDate (4h)

**✅ Concluídas (3)**:
- ✅ PLT-TASKS-003: TasksCacheManager (2.5h vs 32h) - 23/01/2025 ⚡ 92% mais rápido
- ✅ PLT-TASKS-005: Documentar recurring tasks (0.15h vs 2h) - 13/12/2025
- ✅ PLT-TASKS-001: Bug recurring tasks (0.5h vs 8h) - 11/12/2025

---

### 💎 Premium (1 tarefa, 12h)

**Arquivos**: [features/premium/TASKS.md](features/premium/TASKS.md)

**Críticas (1)**:
- PLT-PREMIUM-004: Testes (12h)

**✅ Concluídas (6)**:
- ✅ PLT-PREMIUM-003: Criar domain layer completo (2.5h vs 24h) - 23/01/2025 ⚡ 90% mais rápido
- ✅ PLT-PREMIUM-005: UseCases (0.2h vs 8h) - 13/12/2025
- ✅ PLT-PREMIUM-006: Validation service (0.15h vs 6h) - 13/12/2025
- ✅ PLT-PREMIUM-001: Inject via Riverpod (0.05h vs 4h) - 13/12/2025
- ✅ PLT-PREMIUM-002: Remove adapter (0.1h vs 16h) - 11/12/2025

---

## 🗓️ Roadmap Recomendado

### Sprint 1-2 (Semana 1-2) - CRÍTICO

**Foco**: Code smell grave + Quick wins

```
✅ PLT-AUTH-008: Remover auto-login (0.5h)
✅ PLT-PREMIUM-002: Remover PremiumAdapter (16h)
✅ PLT-AUTH-003: Remover duplicação dialogs (8h)
```

**Total Sprint 1-2**: 24.5h (3 dias)

---

### Sprint 3-4 (Semana 3-4) - ARQUITETURA

**Foco**: Camadas ausentes + God Classes

```
✅ PLT-AUTH-001: Criar camada data auth (24h)
✅ PLT-PREMIUM-003: Criar domain layer premium (24h)
✅ PLT-AUTH-002: Refatorar AuthPage (24h)
```

**Total Sprint 3-4**: 72h (9 dias)

---

### Sprint 5-7 (Semana 5-9) - REFATORAÇÃO CORE

**Foco**: God Classes + Orchestrators

```
✅ PLT-PLANTS-003: Refatorar PlantsNotifier (56h)
✅ PLT-TASKS-003: Refatorar TasksNotifier (32h)
✅ PLT-PLANTS-006: PlantsDomainOrchestrator (16h)
✅ PLT-PLANTS-004: Refatorar Plant.fromPlantaModel (12h)
```

**Total Sprint 5-7**: 116h (14.5 dias)

---

### Sprint 8-10 (Semana 10-13) - TESTES

**Foco**: Cobertura de testes

```
✅ PLT-PLANTS-005: Testes plants (40h)
✅ PLT-AUTH-007: Testes auth (16h)
✅ PLT-TASKS-002: Testes tasks (12h)
✅ PLT-PREMIUM-004: Testes premium (12h)
```

**Total Sprint 8-10**: 80h (10 dias)

---

## 📈 Métricas de Sucesso

### Antes da Refatoração

| Métrica | Valor Atual |
|---------|-------------|
| God Classes (500+L) | 8 |
| Cobertura Testes | 13% |
| Camadas Incompletas | 2 |
| Código Duplicado | 3+ instâncias |
| Score Geral | 7.3/10 |

### Após Refatoração (Meta)

| Métrica | Meta |
|---------|------|
| God Classes | 0 |
| Cobertura Testes | 85%+ |
| Camadas Incompletas | 0 |
| Código Duplicado | 0 |
| Score Geral | 8.5/10 |

---

## 🔗 Links Relacionados

- [Changelog de Correções](CHANGELOG_QUALITY_FIXES.md) - Veja o que já foi feito
- [Análise de Qualidade Executiva](quality-analysis/00_EXECUTIVE_SUMMARY.md)
- [Análises Arquivadas](archive/README.md)

---

**Manutenção**: Atualize este arquivo manualmente ao concluir ou adicionar tarefas. Mantenha o Top 10 sempre atualizado.
