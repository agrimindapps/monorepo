# 🔬 Diagnósticos - Tarefas

**Feature**: diagnosticos
**Atualizado**: 2025-12-06

---

## 📊 Análise dos Issues

| Métrica | Valor |
|---------|-------|
| Arquivos | 67 |
| TODOs | 7 |
| Deprecated | 4 |

### Deprecated Restantes
| Arquivo | Item | Motivo |
|---------|------|--------|
| i_diagnosticos_repository.dart | Interface | Deveria usar repositories especializados |
| diagnostico_entity.dart | 3 getters | displayDefensivo/displayCultura/displayPraga |

### TODOs em stats_service
- 7 TODOs de cálculo de estatísticas (placeholders)

---

## 📋 Backlog

### 🟡 Média Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| DIA-002 | Migrar usos de displayDefensivo/Cultura/Praga | M | Usar DiagnosticoEntityResolver |
| DIA-003 | Implementar cálculos de estatísticas | M | 7 TODOs em stats_service |

### 🟢 Baixa Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| DIA-004 | Remover i_diagnosticos_repository deprecated | P | Após migrar usages |

---

## ✅ Concluídas

| Data | Tarefa | Detalhes |
|------|--------|----------|
| 2025-12-06 | DIA-001: Migrar DiagnosticosNotifier | ✅ 718 linhas removidas, widgets migrados para diagnosticosByEntityProvider |

---

## 📝 Notas

- ✅ DiagnosticosNotifier deprecated REMOVIDO (718 linhas)
- Widgets migrados: filter_widget.dart, state_widgets.dart
- Novo provider: diagnosticosByEntityProvider (376 linhas, mais robusto)
- Feature ainda tem 4 deprecated de baixa prioridade
