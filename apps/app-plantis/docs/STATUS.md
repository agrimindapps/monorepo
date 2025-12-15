# 📊 Dashboard - app-plantis

**Atualizado**: 2025-12-15
**Status**: 🌱 Gold Standard (10/10)

---

## 🎯 Visão Geral por Feature

### Features Principais
| Feature | Health | Backlog | Status |
|---------|--------|---------|--------|
| [plants](./features/plants/) | 10/10 | 2 | ✅ Estável |
| [tasks](./features/tasks/) | 8/10 | 0 | ✅ Estável |
| [home](./features/home/) | 9/10 | 1 | ✅ Estável |

### Features de Usuário
| Feature | Health | Backlog | Status |
|---------|--------|---------|--------|
| [auth](./features/auth/) | 9/10 | 0 | ✅ Estável |
| [premium](./features/premium/) | 9/10 | 1 | ✅ Estável |
| [settings](./features/settings/) | 8/10 | 0 | ✅ Estável |
| [account](./features/account/) | 8/10 | 0 | ✅ Estável |

### Infraestrutura
| Feature | Health | Backlog | Status |
|---------|--------|---------|--------|
| [sync](./features/sync/) | 9/10 | 0 | ✅ Estável |
| [data_export](./features/data_export/) | 7/10 | 0 | ✅ Estável |
| [device_management](./features/device_management/) | 8/10 | 0 | ✅ Estável |
| [license](./features/license/) | 8/10 | 0 | ✅ Estável |
| [legal](./features/legal/) | 8/10 | 0 | ✅ Estável |

---

## 🔥 Em Andamento

| Feature | ID | Tarefa | Progresso |
|---------|-----|--------|-----------|
| core | PLT-QUALITY-001 | Remover prints em produção | 🆕 Novo |

---

## 📋 Próximas Prioridades

| Prioridade | Feature | ID | Tarefa |
|------------|---------|-----|--------|
| 🔴 Alta | core | PLT-QUALITY-001 | Remover 516 prints sem proteção |
| 🔴 Alta | core | PLT-QUALITY-002 | Corrigir 124 only_throw_errors |
| 🟡 Média | home | PLT-HOME-001 | Implementar Firebase Remote Config |
| 🟡 Média | core | PLT-QUALITY-003 | Refatorar 55 classes estáticas |
| 🟡 Média | core | PLT-REFACTOR-001 | Refatorar 15 God Classes (>700L) |

---

## 📈 Métricas do Projeto

| Métrica | Valor | Status |
|---------|-------|--------|
| **Features** | 12 | ✅ |
| **Arquivos .dart** | 609 | - |
| **Health Score** | 10/10 | ✅ |
| **Erros de análise** | 0 | ✅ |
| **Issues (info)** | 307 | ⚠️ |
| **@riverpod providers** | 336 | ✅ |
| **ChangeNotifiers** | 0 | ✅ |
| **TODOs pendentes** | 7 | ✅ (↓64) |
| **Prints sem proteção** | 516 | 🔴 |
| **Throws incorretos** | 124 | 🔴 |
| **God Classes** | 15 | ⚠️ |

---

## 📅 Histórico Recente

### Dezembro 2025
| Data | Feature | Tarefa | Resultado |
| 15/12 | core | PLT-006: Implementar DI propriamente | ✅ Removido SolidDIFactory (203 linhas) |
| 15/12 | core | PLT-007: Implementar performance monitoring | ✅ PerformanceService integrado |
| 15/12 | account | PLT-ACCOUNT-001: Verificar status premium via RevenueCat | ✅ Integrado PremiumRepository |
| 15/12 | tests | Implementação de testes (PLT-PLANTS-005, PLT-TASKS-002, PLT-PREMIUM-004, PLT-AUTH-007) | ✅ 70+ testes criados em 4 módulos |
|------|---------|--------|-----------|| 15/12 | core | Migração Riverpod (PLT-001, 002, 003) | ✅ 3 serviços migrados (Background, Feedback, Progress) || 06/12 | docs | Análise de features para novas tarefas | ✅ 8 novas tarefas identificadas |
| 06/12 | docs | Criar sistema de gestão por feature | ✅ Estrutura criada |
| 12/12 | settings | Correção de erros críticos em SettingsPage | ✅ Fixed missing provider |

---

## 🔗 Links Rápidos

- [Backlog Global](./backlog/)
- [Guias de Desenvolvimento](./guides/)
