# 📋 Backlog Global - app-plantis

**Atualizado**: 2025-12-15

---

## 🔴 Alta Prioridade

(nenhuma tarefa crítica)

---

## 🟡 Média Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| PLT-HOME-001 | Implementar Firebase Remote Config | 4-6h | `lib/features/home/` |
| PLT-QUALITY-004 | Corrigir unawaited_futures | 1-2h | 13 futures não aguardados |
| PLT-QUALITY-005 | Migrar deprecated_member_use | 2-3h | 20+ usos de APIs depreciadas |
| PLT-QUALITY-DI | Migrar DI Modules para @riverpod | 2-3h | 5 módulos com static factories |
| PLT-QUALITY-SERVICES | Tornar 6 services injetáveis | 3-4h | DataSanitization, NotificationConfig, etc |
| PLT-REFACTOR-001 | Refatorar God Classes (>700L) | 8-12h | 15 arquivos >700 linhas |

---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| PLT-004 | Resolver TODOs restantes | 2h | 7 TODOs reais (atualizado) |
| PLT-QUALITY-007 | Corrigir overridden_fields | 1-2h | 19 campos sobrescritos nos models |
| PLT-QUALITY-008 | Padronizar error handling | 6-8h | 747 `catch (e)` genéricos |
| PLT-QUALITY-009 | Auditar debugPrints | 2-3h | 396 debug|
| PLT-QUALITY-006 | Corrigir type_literal_in_constant_pattern | 1h | 12 ocorrências em error_adapter.dart |
| PLT-QUALITY-007 | Corrigir overridden_fields | 1-2h | 19 campos sobrescritos nos models |
| PLT-QUALITY-008 | Padronizar error handling | 6-8h | 747 `catch (e)` genéricos |
| PLT-QUALITY-009 | Auditar debugPrints | 2-3h | 396 debugPrints (verificar necessidade) |

---

## 📊 Métricas de Qualidade (15/12/2025)

| Métrica | Antes | Depois | Status |
|---------|-------|--------|--------|
| **Prints sem proteção** | 516 | 0 | ✅ Resolvido |
| **Issues do Analyzer** | 307 | 374 | ⚠️ (+67 por kDebugMode) |
| **TODOs** | 71 | 7 | ✅ -64 (90%) |
| **Classes estáticas** | 55 | 13 | ✅ 32 válidas, 10 pendentes |
| **only_throw_errors** | 124 | 120 | ✅ Decisão: manter Failures |
| **God Classes (>700L)** | 15 | 15 | ⏳ Pendente |
| **unawaited_futures** | 13 | 13 | ⏳ Pendente
## ✅ Concluídas

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|------QUALITY-001: Remover prints em produção | ✅ 495 prints corrigidos (script automático) |
| 15/12 | PLT-QUALITY-002: Análise only_throw_errors | ✅ 120 Failures válidos (decisão arquitetural) |
| 15/12 | PLT-QUALITY-003: Análise classes estáticas | ✅ 32 válidas, 13 para refatorar |
| 15/12 | PLT---|-----------|
| 15/12 | PLT-SYNC-004: Stream reativo de conflitos | ✅ watchUnresolvedConflicts(), watchAllConflicts(), watchConflictStats() |
| 15/12 | PLT-SETTINGS-001: Remover código morto | ✅ 4 métodos vazios removidos (~47 linhas) |
| 15/12 | PLT-008: Corrigir warnings do analyzer | ✅ 5 warnings removidos (unused imports/fields/elements) |
| 15/12 | PLT-SYNC-003: Refatorar ConflictHistoryRepository | ✅ Model alinhado com schema + stats completos (ConflictStats) |
| 15/12 | PLT-005: Refatorar UnifiedFeedbackSystem | ✅ God Class 614L → Facade 487L + SOLID architecture |
| 15/12 | PLT-006: Implementar DI propriamente | ✅ Removido SolidDIFactory legacy (203 linhas) - todo DI via Riverpod |
| 15/12 | PLT-007: Implementar performance monitoring | ✅ PerformanceService integrado + startup tracking |
| 15/12 | PLT-ACCOUNT-001: Verificar status premium via RevenueCat | ✅ Integrado em AccountRepository |
| 15/12 | PLT-PLANTS-005: Implementar testes para plants | ✅ 23 testes (UseCases + Notifier) |
| 15/12 | PLT-TASKS-002: Implementar testes para tasks | ✅ 19 testes (Complete, Delete, Get) |
| 15/12 | PLT-PREMIUM-004: Implementar testes para premium | ✅ 60+ testes (Subscription, Purchase, Trial) |
| 15/12 | PLT-AUTH-007: Implementar testes para auth | ✅ 70+ testes (Sign In/Up, Reset, Google) |
| 15/12 | PLT-001: Migrar BackgroundSyncService | ✅ Serviço puro + Riverpod Notifier |
| 15/12 | PLT-002: Migrar FeedbackSystem | ✅ FeedbackNotifier com estado reativo |
| 15/12 | PLT-003: Migrar ProgressTracker | ✅ ProgressTrackerNotifier + providers |
| 06/12 | Criar sistema de gestão por feature | ✅ 12 features documentadas |
| 06/12 | Análise de features para novas tarefas | ✅ 8 novas tarefas identificadas |

---

## 📝 Notas

- 336 @riverpod providers já implementados
- App considerado Gold Standard (10/10)
- 609 arquivos .dart total (407 em features)
- 0 ChangeNotifiers legacy restantes

