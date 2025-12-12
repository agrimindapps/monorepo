# 📚 Documentação - app-plantis

**Sistema de Gestão por Feature** | 🌱 Gold Standard (10/10)  
**Última atualização**: 11/12/2025 15:30

---

## 🚀 Quick Start

### Para Desenvolvedores
1. **Ver todas as tarefas**: [TASKS_INDEX.md](TASKS_INDEX.md) - 30 tarefas catalogadas
2. **Iniciar uma tarefa**: Consulte `features/<feature>/TASKS.md`
3. **Acompanhar progresso**: [CHANGELOG_QUALITY_FIXES.md](CHANGELOG_QUALITY_FIXES.md)

### Para Tech Leads
1. **Visão geral**: [quality-analysis/00_EXECUTIVE_SUMMARY.md](quality-analysis/00_EXECUTIVE_SUMMARY.md)
2. **Roadmap**: [TASKS_INDEX.md#roadmap](TASKS_INDEX.md)
3. **Métricas**: Score 7.3/10, 0.6% progresso

---

## 📋 Sistema de Tarefas (NOVO!)

### 🎯 [TASKS_INDEX.md](TASKS_INDEX.md) - Índice Global
- ✅ 30 tarefas catalogadas (11 críticas, 12 altas)
- 📊 ~350h estimadas (10-13 sprints)
- 🔥 Top 10 prioridades identificadas
- 📈 Roadmap detalhado

### 📁 Por Feature
- 🔐 [auth/TASKS.md](features/auth/TASKS.md) - 9 tarefas, 110.5h
- 🌱 [plants/TASKS.md](features/plants/TASKS.md) - 8 tarefas, 140h
- ✅ [tasks/TASKS.md](features/tasks/TASKS.md) - 5 tarefas, 58h (1 BLOQUEADOR!)
- 💎 [premium/TASKS.md](features/premium/TASKS.md) - 6 tarefas, 70h

---

## 📊 Status Rápido

| Feature | Health | Status |
|---------|--------|--------|
| [plants](./features/plants/) | 10/10 | ✅ Estável |
| [auth](./features/auth/) | 9/10 | ✅ Estável |
| [premium](./features/premium/) | 9/10 | ✅ Estável |
| [settings](./features/settings/) | 8/10 | ✅ Estável |
| [tasks](./features/tasks/) | 8/10 | ✅ Estável |
| [sync](./features/sync/) | 8/10 | ✅ Estável |

👉 **[Ver Dashboard Completo](./STATUS.md)**

---

## 🤖 Como usar com IA

Este sistema de documentação foi projetado para ser consumido por agentes de IA.

**Exemplos de Prompts:**

- "Verifique se tenho tarefas pendentes no app-plantis." -> A IA deve ler `docs/TASKS_INDEX.md`.
- "Quais são as tarefas críticas de Auth?" -> A IA deve ler `docs/features/auth/TASKS.md`.
- "Gere um relatório de análise para a feature X." -> A IA deve criar um arquivo em `docs/quality-analysis/` e atualizar o índice.
- "Marque a tarefa PLT-AUTH-001 como concluída." -> A IA deve atualizar `docs/features/auth/TASKS.md`, `docs/TASKS_INDEX.md` e criar uma entrada em `docs/CHANGELOG_QUALITY_FIXES.md`.

---

## 📁 Estrutura de Diretórios

Esta pasta organiza toda a documentação, análise e gestão de tarefas do projeto.

| Diretório | Descrição |
|-----------|-----------|
| `features/` | **Principal**. Contém documentação específica por feature (ex: `auth`, `plants`). Cada pasta deve ter seu `README.md` e `TASKS.md`. |
| `quality-analysis/` | Relatórios detalhados de análise de código, métricas de qualidade e dívida técnica. |
| `adr/` | **Architecture Decision Records**. Registros de decisões importantes de arquitetura. |
| `planning/` | Planejamento de novas funcionalidades, RFCs e roadmaps. |
| `guides/` | Guias de desenvolvimento, padrões de código e tutoriais. |
| `archive/` | Arquivo morto de relatórios antigos e tarefas concluídas. |
| `backlog/` | Ideias e tarefas futuras ainda não priorizadas. |

### Arquivos na Raiz
- **[TASKS_INDEX.md](TASKS_INDEX.md)**: O índice mestre de todas as tarefas pendentes. Consulte este arquivo para saber o que fazer.
- **[CHANGELOG_QUALITY_FIXES.md](CHANGELOG_QUALITY_FIXES.md)**: Log de correções de qualidade e refatorações realizadas.
- **[STATUS.md](STATUS.md)**: Dashboard de saúde do projeto.

---

## 🎯 Sobre o App

**Plantis** é o app de cuidados com plantas, considerado o **Gold Standard** do monorepo.

### Características
- 🌱 Gerenciamento de plantas
- ⏰ Lembretes de rega/cuidados
- 📊 Histórico de cuidados
- 💎 Features premium via RevenueCat
- 🔄 Sync offline-first com Drift

---

## 🔗 Links Úteis

- [Monorepo CLAUDE.md](../../../CLAUDE.md) - Padrões globais
- [Core Package](../../packages/core/) - Serviços compartilhados

---

*Mantido por: Claude Code | Atualizado: 2025-12-05*
