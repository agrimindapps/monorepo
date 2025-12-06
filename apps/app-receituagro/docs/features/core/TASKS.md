# 🔧 Core - Tarefas

**Feature**: core
**Atualizado**: 2025-12-05

---

## 🔄 Em Andamento

| ID | Tarefa | Progresso | Início |
|----|--------|-----------|--------|
| - | Nenhuma | - | - |

---

## 📋 Backlog

### 🔴 Alta Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| ~~CORE-001~~ | ~~Finalizar migração Hive→Drift~~ | ~~G~~ | ✅ Já concluída |
| ~~CORE-002~~ | ~~Remover data_integrity_service.dart~~ | ~~P~~ | ✅ Concluída 05/12 |

### 🟡 Média Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| CORE-003 | Limpar premium_service.dart | M | Migrar para Riverpod DI |
| CORE-004 | Resolver TODOs em injection_container.dart | P | 3 TODOs |
| CORE-005 | Implementar sync de perfil | M | TODO em receituagro_auth_notifier |

### 🟢 Baixa Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| ~~CORE-006~~ | ~~Integrar analytics com crash reporting~~ | ~~M~~ | Movido para ANA-001 |
| ~~CORE-007~~ | ~~Limpar imports não utilizados~~ | ~~P~~ | ✅ Concluída 05/12 |

---

## ✅ Concluídas

### Dezembro 2025
| ID | Tarefa | Data | Resultado |
|----|--------|------|-----------|
| CORE-007 | Limpar imports não utilizados | 05/12 | ✅ 17 arquivos corrigidos |
| CORE-002 | Remover data_integrity_service.dart | 05/12 | ✅ 2 arquivos deletados (não utilizados) |
| CORE-M06 | Migrar AuthNotifier → AsyncNotifier | 05/12 | ✅ Zero erros |
| CORE-M05 | Migração Riverpod 100% | 05/12 | ✅ 6 notifiers |
| CORE-D01 | Reorganizar pasta docs | 05/12 | ✅ Estrutura por feature |

### Novembro 2025
| ID | Tarefa | Data | Resultado |
|----|--------|------|-----------|
| CORE-M04 | Migrar subscription notifiers | 24/11 | ✅ 4 notifiers |
| CORE-M03 | Setup Drift database | 15/11 | ✅ Tabelas criadas |
| CORE-001 | Migração Hive→Drift | - | ✅ Já concluída |

---

## 📝 Notas

- Migração Riverpod 100% completa
- Priorizar limpeza de deprecated antes de novas features
- Ver [RIVERPOD_MIGRATION_PROGRESS.md](./RIVERPOD_MIGRATION_PROGRESS.md) para detalhes
