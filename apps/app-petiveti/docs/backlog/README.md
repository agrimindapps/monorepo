# 📋 Backlog Global - app-petiveti

**Atualizado**: 2025-12-06

---

## 🔴 Alta Prioridade

(nenhuma tarefa crítica)

---

## 🟡 Média Prioridade

| ID | Tarefa | Estimativa | Localização |
|----|--------|------------|-------------|
| PET-CORE-001 | Integrar UnifiedSyncManager quando API disponível | M | `lib/core/services/auto_sync_service.dart` |
| PET-CORE-002 | Implementar verificações de integridade (Medications, etc) | M | `lib/core/services/data_integrity_service.dart` |
| PET-CORE-003 | Implementar subscription provider check | P | `lib/core/auth/auth_guard.dart` |

---

## 🟢 Baixa Prioridade

| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| PET-004 | Resolver 82 TODOs | G | Análise e limpeza |
| PET-005 | Migrar ChangeNotifier em calculators | P | `medication_dosage_provider.dart` |

---

## ✅ Concluídas

### Dezembro 2025
| Data | Tarefa | Resultado |
|------|--------|-----------|
| 06/12 | Criar sistema de gestão por feature | ✅ 16 features documentadas |
| 06/12 | Análise de features para novas tarefas | ✅ 13 tarefas identificadas |

---

## 📝 Notas

- 1 ChangeNotifier restante (calculators - medication_dosage_provider)
- 274 @riverpod providers já implementados
- 0 warnings no analyzer ✅
- 496 arquivos .dart em features
- 82 TODOs distribuídos principalmente em:
  - subscription (11 TODOs)
  - medications (10 TODOs)
  - auto_sync_service (9 TODOs)
  - animals (7 TODOs)
