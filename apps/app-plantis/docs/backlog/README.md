# 📋 Backlog Global - app-plantis

**Atualizado**: 2025-12-06

---

## 🔴 Alta Prioridade

(nenhuma tarefa crítica)

---

## 🟡 Média Prioridade

| ID | Tarefa | Estimativa | Localização |
|----|--------|------------|-------------|
| PLT-001 | Migrar BackgroundSyncService para Riverpod | P | `lib/core/services/background_sync_service.dart` |
| PLT-002 | Migrar FeedbackSystem para Riverpod | P | `lib/shared/widgets/feedback/feedback_system.dart` |
| PLT-003 | Migrar ProgressTracker para Riverpod | P | `lib/shared/widgets/feedback/progress_tracker.dart` |
| PLT-005 | Refatorar UnifiedFeedbackSystem (30+ TODOs) | M | `lib/shared/widgets/feedback/unified_feedback_system.dart` |
| PLT-006 | Implementar DI propriamente | P | `lib/core/di/solid_di_factory.dart` |
| PLT-007 | Implementar performance monitoring | P | `lib/core/providers/core_di_providers.dart` |

---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| PLT-004 | Resolver 71 TODOs | G | Análise e limpeza |
| PLT-008 | Corrigir 5 warnings do analyzer | P | Ver seção Analyzer |

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
|------|--------|-----------|
| 06/12 | Criar sistema de gestão por feature | ✅ 12 features documentadas |
| 06/12 | Análise de features para novas tarefas | ✅ 8 novas tarefas identificadas |

---

## 📝 Notas

- 3 ChangeNotifiers restantes para migrar
- 333 @riverpod providers já implementados
- App considerado Gold Standard (10/10)
- 407 arquivos .dart em features
