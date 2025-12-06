# 📋 Backlog Global - app-gasometer

**Atualizado**: 2025-12-06

---

## 🔴 Alta Prioridade

(nenhuma tarefa crítica)

---

## 🟡 Média Prioridade

| ID | Tarefa | Estimativa | Localização |
|----|--------|------------|-------------|
| GAS-001 | Migrar AuthStateNotifier para Riverpod | P | `lib/core/router/auth_state_notifier.dart` |
| GAS-003 | Usar Riverpod provider para AuthRepository | P | `lib/app.dart` |
| GAS-004 | Corrigir @override em non-overriding members (2) | P | expense/fuel sync adapters |

---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| GAS-002 | Resolver 15 TODOs | M | Análise e limpeza |
| GAS-005 | Corrigir 30 warnings do analyzer | M | Ver seção Analyzer |

---

## ⚠️ Analyzer Warnings (30)

### Por Categoria:
| Tipo | Qtd | Arquivos Afetados |
|------|-----|-------------------|
| dead_null_aware_expression | 17 | gasometer_sync_orchestrator.dart, gasometer_sync_service.dart |
| deprecated_member_use | 7 | call_to_action.dart, features_carousel.dart, clear_data_dialog.dart, financial_conflict_dialog.dart |
| undefined_hidden_name | 3 | error_reporter.dart |
| override_on_non_overriding_member | 2 | expense_drift_sync_adapter.dart, fuel_supply_drift_sync_adapter.dart |

### Arquivos Críticos:
- `lib/core/error/error_reporter.dart` - hidden names não existem no core
- `lib/features/sync/domain/services/` - dead null aware expressions

---

## ✅ Concluídas

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 06/12 | Criar sistema de gestão por feature | ✅ 21 features documentadas |
| 06/12 | Análise de features para novas tarefas | ✅ 5 tarefas identificadas |

---

## 📝 Notas

- 1 ChangeNotifier restante para migrar (AuthStateNotifier)
- 182 @riverpod providers já implementados
- 99% Riverpod
- 578 arquivos .dart em features
