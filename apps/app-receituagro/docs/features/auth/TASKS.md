# 🔐 Auth - Tarefas

**Feature**: auth
**Atualizado**: 2025-12-05

---

## 🔄 Em Andamento

| ID | Tarefa | Progresso | Início |
|----|--------|-----------|--------|
| - | Nenhuma | - | - |

---

## 📋 Backlog

### 🔴 Alta Prioridade
(nenhuma)

### 🟡 Média Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| AUTH-001 | Implementar refresh token | M | Auto-renovação de sessão |
| AUTH-002 | Melhorar tratamento de erros | P | Mensagens mais amigáveis |

### 🟢 Baixa Prioridade
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| AUTH-003 | Adicionar login biométrico | G | FaceID/TouchID |

---

## ✅ Concluídas

### Dezembro 2025
| ID | Tarefa | Data | Resultado |
|----|--------|------|-----------|
| AUTH-M02 | Migrar AuthNotifier → AsyncNotifier | 05/12 | ✅ Zero erros, padrão Riverpod 3.0 |
| AUTH-M01 | Remover StateNotifier/legacy imports | 05/12 | ✅ 100% code generation |
| AUTH-M00 | Atualizar consumidores (AsyncValue.when) | 05/12 | ✅ 5 arquivos atualizados |

---

## 📝 Notas

- Migração Riverpod 100% completa
- Usar `authProvider.notifier` para ações
- Usar `authProvider` (AsyncValue) para UI
