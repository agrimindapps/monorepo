# 📅 appointments - Tarefas

**Feature**: appointments
**Atualizado**: 2025-12-09
**Quality Score**: 7.5/10 (bloqueado por 2 gaps críticos + testes)

---

## 📋 Backlog Priorizado

### 🔴 CRÍTICO (P0) - Bloqueadores Funcionais

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-APP-001 | 🔴 P0 | Implementar selectedAnimalProvider (AddAppointmentForm quebrado) | 2-3h | `core/providers/` ou criar provider |
| PET-APP-002 | 🔴 P0 | Criar Appointment Details Page (navegação quebrada) | 4-6h | `presentation/pages/appointment_details_page.dart` |

### 🟡 ALTA (P1) - Qualidade e Core

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-APP-003 | 🟡 P1 | Implementar testes de use cases (35-42 testes, ≥75% coverage) | 8-10h | `test/features/appointments/domain/usecases/` |
| PET-APP-004 | 🟡 P1 | Implementar testes de services (validation + error handling) | 4-5h | `test/features/appointments/domain/services/` |
| PET-APP-005 | 🟡 P1 | Completar integração UnifiedSyncManager (manual trigger + forceSync) | 3-4h | `data/repositories/appointment_repository_impl.dart` (2 TODOs) |

### 🟢 MÉDIA (P2) - Features Parciais

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-APP-006 | 🟢 P2 | Implementar Reminder System UI (infraestrutura pronta) | 6-8h | `presentation/widgets/` |
| PET-APP-007 | 🟢 P2 | Implementar Documents Upload (campos existem, implementação faltando) | 8-10h | Repository + UI |
| PET-APP-008 | 🟢 P2 | Implementar Emergency Priority UI (backend pronto) | 4-6h | `presentation/widgets/add_appointment_form.dart` |
| PET-APP-009 | 🟢 P2 | Implementar Clinic Information Form (campos existem) | 4-6h | `presentation/widgets/add_appointment_form.dart` |

### 🔵 BAIXA (P3) - Testes e Polish

| ID | Prioridade | Tarefa | Estimativa | Arquivo |
|----|------------|--------|------------|---------|
| PET-APP-010 | 🔵 P3 | Implementar testes de repositories | 6-8h | `test/features/appointments/data/repositories/` |
| PET-APP-011 | 🔵 P3 | Implementar testes de data sources (local + remote) | 6-8h | `test/features/appointments/data/datasources/` |
| PET-APP-012 | 🔵 P3 | Implementar testes de presentation (notifiers + widgets) | 8-10h | `test/features/appointments/presentation/` |
| PET-APP-013 | 🔵 P3 | Adicionar índices Drift compostos (animalId + date, status + date) | 2-3h | Schema |
| PET-APP-014 | 🔵 P3 | Implementar cache de queries frequentes | 3-4h | Repository |
| PET-APP-015 | 🔵 P3 | Documentar APIs públicas com dartdoc | 4h | Todos arquivos |

---

## ✅ Concluídas Recentemente

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 09/12 | Análise profunda da feature | ✅ Relatório completo com 22 arquivos analisados |
| 09/12 | Identificação de 2 bloqueadores críticos | ✅ selectedAnimalProvider ausente, Details Page faltando |

---

## 📊 Métricas da Feature

| Métrica | Valor | Status |
|---------|-------|--------|
| **Arquivos .dart** | 22 | - |
| **Use Cases** | 6 | ✅ |
| **Providers** | 17 | ✅ |
| **Test Coverage** | 0% | ❌ CRÍTICO |
| **TODOs Críticos** | 2 | 🔴 |
| **Features Parciais** | 4 | ⚠️ |
| **Health Score** | 7.5/10 | ⚠️ |

---

## 📝 Notas Técnicas

### Arquitetura
- ✅ Clean Architecture rigorosa (3 camadas)
- ✅ Offline-first com UnifiedSyncManager
- ✅ Pure Riverpod com code generation
- ✅ Soft delete pattern
- ✅ Emergency priority support
- ✅ Auto-reload on animal change

### Gaps Críticos
- ❌ **selectedAnimalProvider ausente**: AddAppointmentForm não funciona (TODOs linhas 79, 388)
- ❌ **Appointment Details Page faltando**: Navegação quebrada
- ❌ **Zero Testes**: 0% coverage (blocker produção)
- ⚠️ **4 Features Parciais**: Reminders, Documents, Emergency UI, Clinic Info

### Próximos Passos Recomendados
1. **Sprint 1 (P0)**: Fixes críticos → 6-9h
2. **Sprint 2 (P1)**: Testes + Sync → 15-19h
3. **Sprint 3 (P2)**: Features parciais → 22-30h

**Estimativa total para 10/10**: ~50 horas (6-7 dias)

---

## 🔍 Detalhes dos Bloqueadores

### Blocker #1: selectedAnimalProvider Ausente
**Localização**: `add_appointment_form.dart:79, 388`
```dart
// TODO: selectedAnimalProvider does not exist
final selectedAnimal = ref.watch(selectedAnimalProvider); // ❌ Error
```
**Impacto**: AddAppointmentForm não renderiza, impossível criar consultas
**Solução**: Criar provider global em `core/providers/selected_animal_provider.dart` ou em animals feature

### Blocker #2: Appointment Details Page Faltando
**Localização**: Navegação em `appointment_card.dart`
```dart
onTap: () => Navigator.pushNamed(context, '/appointment-details'); // ❌ Rota não existe
```
**Impacto**: Usuário não consegue ver detalhes completos da consulta
**Solução**: Criar `appointment_details_page.dart` com exibição completa + edit/delete

---

## 🎯 Estimativa de Testes Necessários

**Total estimado**: 167-174 testes para ≥80% coverage

**Breakdown**:
- Use cases: 35-42 testes (6 × 6-7 cada)
- Validation service: 10 testes
- Error handling service: 6 testes
- Repositories: 15 testes
- Data sources: 20 testes (local + remote)
- Notifiers: 12 testes
- Widgets: 40 testes (page, card, form, empty state)
- Integration: 10-15 testes E2E

---

## 🔗 Links Relacionados

- [README Completo](./README.md) - Documentação técnica detalhada
- [ANALYSIS_REPORT.md](../../ANALYSIS_REPORT.md) - Relatório de migração Riverpod
- [Backlog Global](../../backlog/README.md) - Tarefas cross-feature

---

*Última análise: 2025-12-09 | Agente: code-intelligence (Sonnet 4.5)*
