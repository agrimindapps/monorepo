# 📋 Backlog Global - app-plantis

**Atualizado**: 2025-12-15

---

## 🔴 Alta Prioridade

(nenhuma tarefa crítica)

---

## 🟡 Média Prioridade

| ID | Tarefa | Estimativa | Localização |
|----|--------|------------|-------------|

| PLT-005 | Refatorar UnifiedFeedbackSystem (God Class) | M | `lib/shared/widgets/feedback/unified_feedback_system.dart` |


---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| PLT-004 | Resolver 71 TODOs | G | Análise e limpeza |
| PLT-008 | Corrigir 5 warnings do analyzer | P | Ver seção Analyzer |
| PLT-SYNC-002 | Completar estatísticas de conflitos | P | `lib/core/services/conflict_history_drift_service.dart` |
| PLT-SYNC-003 | Refatorar ConflictHistoryRepository | M | `lib/database/repositories/conflict_history_drift_repository.dart` |
| PLT-SYNC-004 | Implementar stream reativo de conflitos | P | `lib/core/services/conflict_history_drift_service.dart` |
| PLT-SETTINGS-001 | Remover código morto de device loading | P | `lib/features/settings/presentation/providers/settings_notifier.dart` |

---

## ⚠️ Analyzer Warnings (5)

| Arquivo | Tipo | Descrição |
|---------|------|-----------|
| `realtime_sync_service.dart:389` | warning | dead_null_aware_expression |
| `realtime_sync_service.dart:390` | warning | dead_null_aware_expression |
| `database_providers.dart:2` | warning | unused_import |
| `device_validation_interceptor.dart:132` | warning | unused_element |
| `space_selector_widget.dart:223` | warning | deprecated_member_use |

---

## ✅ Concluídas

### Dezembro 2025
| Data | Tarefa | Resultado |
| 15/12 | PLT-006: Implementar DI propriamente | ✅ Removido SolidDIFactory legacy (203 linhas) - todo DI via Riverpod |
| 15/12 | PLT-007: Implementar performance monitoring | ✅ PerformanceService integrado + startup tracking |
| 15/12 | PLT-ACCOUNT-001: Verificar status premium via RevenueCat | ✅ Integrado em AccountRepository |
| 15/12 | PLT-PLANTS-005: Implementar testes para plants | ✅ 23 testes (UseCases + Notifier) |
| 15/12 | PLT-TASKS-002: Implementar testes para tasks | ✅ 19 testes (Complete, Delete, Get) |
| 15/12 | PLT-PREMIUM-004: Implementar testes para premium | ✅ 60+ testes (Subscription, Purchase, Trial) |
| 15/12 | PLT-AUTH-007: Implementar testes para auth | ✅ 70+ testes (Sign In/Up, Reset, Google) |
|------|--------|-----------|| 15/12 | PLT-001: Migrar BackgroundSyncService | ✅ Serviço puro + Riverpod Notifier |
| 15/12 | PLT-002: Migrar FeedbackSystem | ✅ FeedbackNotifier com estado reativo |
| 15/12 | PLT-003: Migrar ProgressTracker | ✅ ProgressTrackerNotifier + providers || 06/12 | Criar sistema de gestão por feature | ✅ 12 features documentadas |
| 06/12 | Análise de features para novas tarefas | ✅ 8 novas tarefas identificadas |

---

## 📝 Notas

- 3 ChangeNotifiers restantes para migrar
- 333 @riverpod providers já implementados
- App considerado Gold Standard (10/10)
- 407 arquivos .dart em features
