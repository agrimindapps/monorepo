# ⚙️ Settings - Tarefas

**Feature**: settings
**Atualizado**: 2025-12-06

---

## 📊 Análise dos Issues

| Métrica | Valor |
|---------|-------|
| Arquivos | 81 |
| Deprecated | 1 (SettingsNotifier - wrapper) |
| TODOs | 20+ |

### Status da Migração

| Provider | Status | Notas |
|----------|--------|-------|
| ThemeSettingsNotifier | ✅ Migrado | Riverpod nativo |
| NotificationSettingsNotifier | ✅ Migrado | Riverpod nativo |
| UserSettingsNotifier | ✅ Migrado | Riverpod nativo |
| DeviceNotifier | ✅ Migrado | Riverpod nativo |
| ProfileNotifier | ✅ Migrado | Riverpod nativo |
| TtsNotifier | ✅ Migrado | Riverpod nativo |
| **SettingsNotifier** | ⚠️ Deprecated | Wrapper para backward compat |

### Usos do SettingsNotifier (2 arquivos)
- `settings_page.dart` - initialize, watch, refresh
- `profile_page.dart` - initialize, watch

---

## 📋 Backlog

### 🟢 Baixa Prioridade (Opcional)
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| SET-001 | Migrar settings_page para userSettingsProvider | M | Eliminar uso de SettingsNotifier |
| SET-002 | Migrar profile_page para userSettingsProvider | P | Simplificar initialize |
| SET-003 | Remover SettingsNotifier wrapper | P | Após SET-001 e SET-002 |
| SET-004 | Implementar TODOs de persistência | G | ~20 TODOs de storage |

### ⏳ Aguardando
| ID | Tarefa | Dependência |
|----|--------|-------------|
| SET-005 | Implementar AnalyticsDebugProvider | Core analytics |
| SET-006 | Implementar NotificationServiceProvider | Core notifications |

---

## ✅ Concluídas

| Data | Tarefa | Detalhes |
|------|--------|----------|
| 2025-12-05 | Migrar ThemeNotifier | ✅ Usa @riverpod |
| 2025-12-05 | Migrar NotificationNotifier | ✅ Usa @riverpod |
| 2025-12-05 | Migrar DeviceNotifier | ✅ Usa @riverpod |
| 2025-12-05 | Migrar ProfileNotifier | ✅ Usa @riverpod |

---

## 📝 Notas

- **SettingsNotifier** é um wrapper para backward compatibility
- Todos os notifiers especializados já usam `@riverpod`
- A migração de SET-001/002/003 é OPCIONAL - o wrapper funciona bem
- TODOs são principalmente placeholders de persistência (baixa criticidade)
