# 💎 Subscription - Tarefas

**Feature**: subscription
**Atualizado**: 2025-12-06

---

## 📊 Análise dos TODOs

| Categoria | Qtd | Descrição |
|-----------|-----|-----------|
| Backend/API | 16 | Chamadas a backend ainda não implementadas |
| Log/Analytics | 14 | Eventos de tracking pendentes |
| UI/Navegação | 6 | Ações de UI incompletas |
| Notificações | 3 | Alertas ao usuário |

### Arquivos com mais TODOs
| Arquivo | TODOs | Prioridade |
|---------|-------|------------|
| subscription_status_notifier.dart | 11 | 🔴 Alta |
| trial_notifier.dart | 10 | 🔴 Alta |
| purchase_notifier.dart | 9 | 🟡 Média |
| billing_notifier.dart | 8 | 🟡 Média |
| subscription_status_section.dart | 4 | 🟢 Baixa |
| trial_section.dart | 2 | 🟢 Baixa |

---

## 📋 Backlog

### 🔴 Alta Prioridade (Funcionalidade Core)
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| SUB-001 | Implementar notificação de expiração | M | subscription_status_notifier:180 |
| SUB-002 | Implementar limitações parciais | M | subscription_status_notifier:186 |
| SUB-003 | Implementar remoção de acesso premium | M | subscription_status_notifier:192 |
| SUB-004 | Integrar APIs de upgrade/downgrade/cancel | G | 6 endpoints backend |

### 🟡 Média Prioridade (Analytics/Tracking)
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| SUB-005 | Implementar log events (14 TODOs) | M | Tracking de conversão |
| SUB-006 | Integrar RevenueCat para método pagamento | P | subscription_financial_details_card:164 |

### 🟢 Baixa Prioridade (UI/UX)
| ID | Tarefa | Estimativa | Detalhes |
|----|--------|------------|----------|
| SUB-007 | Implementar navegação para upgrade | P | 3 TODOs de navegação |
| SUB-008 | Implementar seleção de plano | P | subscription_status_section:233 |

---

## ✅ Concluídas

(histórico será registrado aqui)

---

## 📝 Notas

- ✅ Zero deprecated
- 52 arquivos .dart
- 45 TODOs (maioria são placeholders de implementação futura)
- Feature crítica para monetização
- Maioria dos TODOs são de integração backend (não bugs)
- Notifiers bem estruturados, prontos para receber implementação real
