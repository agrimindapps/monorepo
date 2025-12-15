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
| [settings](./features/settings/) | 8/10 | 1 | ✅ Estável |
| [account](./features/account/) | 8/10 | 1 | ✅ Estável |

### Infraestrutura
| Feature | Health | Backlog | Status |
|---------|--------|---------|--------|
| [sync](./features/sync/) | 8/10 | 1 | ✅ Estável |
| [data_export](./features/data_export/) | 7/10 | 0 | ✅ Estável |
| [device_management](./features/device_management/) | 8/10 | 1 | ✅ Estável |
| [license](./features/license/) | 8/10 | 0 | ✅ Estável |
| [legal](./features/legal/) | 8/10 | 0 | ✅ Estável |

---

## 🔥 Em Andamento

| Feature | ID | Tarefa | Progresso |
|---------|-----|--------|-----------||
| - | - | Nenhuma tarefa em andamento | - |

---

## 📋 Próximas Prioridades

| Prioridade | Feature | ID | Tarefa |
|------------|---------|-----|--------|

| 🟡 Média | shared | PLT-005 | Refatorar UnifiedFeedbackSystem (God Class 614L) |
| 🟡 Média | home | PLT-HOME-001 | Implementar Firebase Remote Config |
|  Baixa | - | PLT-008 | Corrigir 5 warnings do analyzer |

---

## 📈 Métricas do Projeto

| Métrica | Valor |
|---------|-------|
| **Features** | 12 |
| **Arquivos .dart** | 609 (407 em features) |
| **Health Score** | 10/10 |
| **Erros de análise** | 0 |
| **Warnings** | 5 |
| **@riverpod providers** | 336 ✅ (+3) |
| **ChangeNotifiers** | 0 ✅ (legacy removidos) |
| **TODOs pendentes** | 71 |

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
