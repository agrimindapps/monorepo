# 📊 Dashboard - app-receituagro

**Atualizado**: 2025-12-06
**Mantido por**: Claude Code

---

## 🎯 Visão Geral por Feature

### Features Principais
| Feature | Health | Backlog | TODOs | Deprecated | Status |
|---------|--------|---------|-------|------------|--------|
| [defensivos](./features/defensivos/) | 10/10 | 2 | 4 | 0 | ✅ Limpo |
| [pragas](./features/pragas/) | 9/10 | 1 | 1 | 0 | ✅ Estável |
| [culturas](./features/culturas/) | 10/10 | 1 | 0 | 0 | ✅ Limpo |
| [diagnosticos](./features/diagnosticos/) | 8/10 | 0 | 7 | 5 | ⚠️ Cleanup |

### Features de Usuário
| Feature | Health | Backlog | TODOs | Deprecated | Status |
|---------|--------|---------|-------|------------|--------|
| [auth](./features/auth/) | 10/10 | 0 | 0 | 0 | ✅ Limpo |
| [favoritos](./features/favoritos/) | 9/10 | 2 | 2 | 0 | ✅ Estável |
| [comentarios](./features/comentarios/) | 8/10 | 1 | 0 | 1 | ✅ Estável |
| [settings](./features/settings/) | 7/10 | 5 | 22 | 5 | ⚠️ Cleanup |
| [subscription](./features/subscription/) | 6/10 | 7 | 45 | 0 | 🔴 Pendente |

### Features Auxiliares
| Feature | Health | Backlog | TODOs | Deprecated | Status |
|---------|--------|---------|-------|------------|--------|
| [busca_avancada](./features/busca_avancada/) | 8/10 | 2 | 3 | 0 | ✅ Estável |
| [pragas_por_cultura](./features/pragas_por_cultura/) | 10/10 | 0 | 0 | 0 | ✅ Limpo |
| [data_export](./features/data_export/) | 9/10 | 2 | 0 | 0 | ✅ Estável |
| [onboarding](./features/onboarding/) | 10/10 | 1 | 0 | 0 | ✅ Limpo |

### Infraestrutura
| Feature | Health | Backlog | TODOs | Deprecated | Status |
|---------|--------|---------|-------|------------|--------|
| [core](./features/core/) | 8/10 | 3 | - | - | ✅ Estável |
| [analytics](./features/analytics/) | 6/10 | 4 | 23 | 2 | 🔴 Pendente |
| [monitoring](./features/monitoring/) | 10/10 | 0 | 0 | 0 | ✅ Limpo |
| [navigation](./features/navigation/) | 10/10 | 0 | 0 | 0 | ✅ Limpo |
| [sync](./features/sync/) | 10/10 | 0 | 0 | 0 | ✅ Limpo |
| [release](./features/release/) | 8/10 | 0 | 0 | 1 | ✅ Estável |

---

## 📊 Resumo de Issues por Feature

| Métrica | Total |
|---------|-------|
| **TODOs** | 107 |
| **Deprecated** | 9 |
| **Features limpas (0 issues)** | 9/18 |
| **Features com issues** | 9/18 |

### 🔴 Top 3 Features para Cleanup
1. **subscription** - 45 TODOs (monetização)
2. **analytics** - 23 TODOs + 2 deprecated
3. **settings** - 22 TODOs + 1 deprecated

---

## 🔥 Em Andamento

| Feature | ID | Tarefa | Progresso |
|---------|-----|--------|-----------|
| - | - | Nenhuma tarefa em andamento | - |

---

## 📋 Próximas Prioridades

| Prioridade | Feature | ID | Tarefa |
|------------|---------|-----|--------|
| 🔴 Alta | core | CORE-001 | Finalizar migração Hive→Drift |
| 🔴 Alta | favoritos | FAV-001 | Limpar código deprecated |
| 🟡 Média | core | CORE-002 | Remover serviços deprecated |
| 🟡 Média | data_export | EXP-001 | Implementar export LGPD |
| 🟡 Média | subscription | SUB-001 | Limpar premium_service |

---

## 📈 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| **Features** | 18 |
| **Arquivos .dart** | 808 |
| **Linhas de código** | ~159.000 |
| **Erros de análise** | 0 |
| **Issues (info/warning)** | 164 |
| **Cobertura Riverpod** | 100% |

---

## 📅 Histórico Recente

### Dezembro 2025
| Data | Feature | Tarefa | Resultado |
|------|---------|--------|-----------|
| 06/12 | release | Remover ProductionReleaseDashboard deprecated | ✅ 1 arquivo deletado |
| 06/12 | defensivos | Remover todos UseCases deprecated | ✅ 7 classes + 6 providers (~105 linhas) |
| 06/12 | culturas | CUL-001: Remover UseCases deprecated | ✅ 4 classes (~70 linhas) |
| 06/12 | defensivos | DEF-001: Remover GetDefensivosUseCaseOld | ✅ 1 classe (~15 linhas) |
| 06/12 | docs | Análise feature-by-feature | ✅ 107 TODOs + 44 deprecated mapeados |
| 05/12 | core | CORE-007: Limpar imports | ✅ 17 arquivos, -17 issues |
| 05/12 | favoritos | FAV-001: Limpar código deprecated | ✅ 3 usecases + 12 métodos |
| 05/12 | core | CORE-002: Remover data_integrity_service | ✅ 2 arquivos deletados |
| 05/12 | auth | Migrar AuthNotifier → AsyncNotifier | ✅ Zero erros |
| 05/12 | core | Migração Riverpod 100% | ✅ 6 notifiers |
| 05/12 | docs | Criar sistema de gestão por feature | ✅ 18 features |
| 04/12 | pragas | Corrigir registro de acesso | ✅ Histórico OK |

---

## 🔗 Links Rápidos

- [Backlog Global](./backlog/)
- [Guias de Desenvolvimento](./guides/)
- [Core/Infraestrutura](./features/core/)
