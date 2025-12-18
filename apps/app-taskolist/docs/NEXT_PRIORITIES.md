# 🚀 Próximas Prioridades - Taskolist

**Última atualização:** 18 de Dezembro de 2025 - 12:14  
**Status:** Sistema de Listas + Recorrência Completos | Preparando Build Web

---

## ✅ Status Atual

### Features Completas (100%)
- ✅ **CRUD de Tarefas** - TaskEntity completo com todos os campos
- ✅ **Estados/Status** - pending, inProgress, completed, cancelled
- ✅ **Prioridades** - low, medium, high, urgent
- ✅ **Favoritar** - Campo isStarred implementado
- ✅ **Notas** - Campo notes para descrições longas
- ✅ **Data de Vencimento** - Campo dueDate com helpers (isOverdue, isDueToday)
- ✅ **Tags** - Campo tags: List<String>
- ✅ **Posicionamento** - Campo position para ordenação customizada
- ✅ **Soft Delete** - Campo isDeleted do BaseSyncEntity
- ✅ **Versionamento** - Campo version para resolução de conflitos
- ✅ **Meu Dia (My Day)** - Planejador diário completo (100% funcional)
- ✅ **Listas com Cores** - Sistema de cores implementado (exibição funcional)
- ✅ **Lembretes Recorrentes** - Sistema completo de recorrência (MVP: daily, weekly, monthly, yearly com UI integrada)
- ✅ **Sistema de Listas Completo** - CRUD, drawer com listas, edição, arquivamento, cores personalizadas
- ✅ **Gerenciamento de Listas** - CreateTaskListDialog, EditTaskListDialog, ListOptionsBottomSheet implementados

### Features Parcialmente Implementadas
- 🟡 **Subtarefas** - Estrutura existe (parentTaskId), falta UI completa
- 🟡 **Lembretes** - Campo reminderDate existe, falta implementar notificações
- 🟡 **Integração Meu Dia** - Core funcional, falta botão "Adicionar ao Meu Dia" nas listas e badge no drawer

---

## 🎯 PRIORIDADES PARA HOJE (18/12/2025)

### ✅ Opção 1: Quick Wins - Melhorias Imediatas (2-3h) - **COMPLETO**
**Objetivo:** Completar integrações pendentes da feature "Meu Dia"

#### ✅ Tarefas Completadas:
1. **✅ Badge no drawer mostrando quantidade** (20min)
   - Contador em tempo real (Stream)
   - Badge visual destacado
   - Atualização automática

2. **✅ Pull to Refresh** (30min)
   - RefreshIndicator implementado
   - Feedback visual suave
   - Invalidação de provider

3. **✅ Analytics Firebase** (1h)
   - AnalyticsService criado
   - 5 events implementados
   - Integração completa
   - Source tracking

**Critérios de Aceite:**
- [x] Badge no drawer mostra quantidade correta
- [x] Gestos funcionam suavemente
- [x] Events sendo logados no console
- [x] Sem erros de build

**Status**: ✅ **100% COMPLETO** (Ver `docs/QUICK_WINS_COMPLETE.md`)

---

### Opção 2: Sistema de Listas Completo (4-6h) 📋 ✅ **COMPLETO**
**Objetivo:** Implementar CRUD completo de listas com personalização visual

#### ✅ Fase 0: Listas Coloridas (IMPLEMENTADO)
1. **Core Theme System**
   - [x] Criado `ListColors` com 12 cores pré-definidas
   - [x] Helper methods para conversão String ↔ Color
   
2. **Widgets de Seleção**
   - [x] `ColorSelector` - Widget inline horizontal
   - [x] `ColorPickerDialog` - Modal com grid de cores
   - [x] `ListColorIndicator` - Badge visual de cor
   
3. **Documentação**
   - [x] Criado `docs/features/listas-coloridas.md`
   - [x] Exemplos de uso e integração

#### ✅ Fase 1: Backend & Repository (IMPLEMENTADO)
1. **TaskListRepository Implementation**
   - [x] Criado `TaskListLocalDataSource` (Drift)
   - [x] Criado `TaskListRepositoryImpl`
   - [x] Criado Riverpod providers

2. **Use Cases**
   - [x] `CreateTaskList`
   - [x] `UpdateTaskList`
   - [x] `DeleteTaskList`
   - [x] `GetAllTaskLists`
   - [x] `WatchTaskLists` (Stream)
   - [x] `ArchiveTaskList`

#### ✅ Fase 2: UI/UX (IMPLEMENTADO)
3. **Sidebar com Lista de Listas**
   - [x] ModernDrawer section "Minhas Listas"
   - [x] Lista de todas as listas ativas
   - [x] Botão "Nova Lista"
   - [x] Long press para opções (editar, arquivar, deletar)

4. **Dialog de Criar/Editar Lista**
   - [x] TextField para nome da lista
   - [x] Color picker (paleta cores predefinidas)
   - [x] Preview em tempo real
   - [x] Validações

#### ✅ Fase 3: Polish (IMPLEMENTADO)
5. **Features Adicionais**
   - [x] Modal bottom sheet com opções
   - [x] Confirmação ao deletar lista
   - [x] Empty state para listas vazias
   - [x] Loading states

**Critérios de Aceite:**
- [x] Criar nova lista em <5 toques
- [x] Mudar cor de lista e ver refletido imediatamente
- [x] Ver listas no drawer
- [x] Editar/Arquivar/Deletar lista com long press
- [x] Deletar lista mostra confirmação

**Estrutura de Dados:**
```dart
// TaskListEntity já existe em:
// lib/features/tasks/domain/task_list_entity.dart
class TaskListEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String color;              // Hex: "#FF5733"
  final String? iconCodePoint;     // Icon codepoint (opcional)
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final bool isArchived;
  final int position;
}
```

---

### ✅ Opção 3: Subtarefas/Steps Completo (3-4h) - **COMPLETO**
**Objetivo:** Implementar sistema completo de etapas (steps) dentro de tarefas

**Status**: ✅ **100% MVP IMPLEMENTADO** (Ver `docs/SUBTASKS_IMPLEMENTATION_COMPLETE.md`)

#### ✅ Fase 1: Backend (Já estava pronto)
1. **SubTask Entity & Model**
   - [x] TaskEntity com parentTaskId
   - [x] SubtaskProgress model
   - [x] Providers Riverpod

2. **Repository & Use Cases**
   - [x] GetSubtasks
   - [x] CreateSubtask
   - [x] UpdateSubtask
   - [x] DeleteSubtask

#### ✅ Fase 2: Barra de Progresso (IMPLEMENTADO)
- [x] SubtaskProgressBadge widget
- [x] SubtaskProgressHeader widget
- [x] Integração na TaskCard
- [x] Integração no TaskDetailPage
- [x] Contador "3/5 concluídas"
- [x] Barra visual de progresso
- [x] Porcentagem exibida

#### ✅ Fase 3: Quick Add Inline (IMPLEMENTADO)
- [x] QuickAddSubtaskField widget
- [x] TextField inline
- [x] Botão send ao digitar
- [x] Enter para criar
- [x] Loading indicator
- [x] Auto-limpa após criar

**Critérios de Aceite:**
- [x] Adicionar step em 1 toque (inline)
- [x] Progresso visual "3/5 etapas"
- [x] Ver progresso na lista
- [x] Ver progresso no detalhe
- [x] UX fluida e rápida

**Funcionalidades Opcionais (Não Implementadas):**
- [ ] Reordenar steps (drag)
- [ ] Swipe to delete
- [ ] Auto-complete parent task

---

### Opção 4: Notificações e Lembretes (6-8h) 🔔
**Objetivo:** Implementar sistema completo de notificações locais

**⚠️ COMPLEXIDADE ALTA - Recomendado fazer em dia separado**

#### Fase 1: Setup (2h)
1. **Dependências**
   - [ ] Adicionar `flutter_local_notifications: ^17.0.0`
   - [ ] Adicionar `timezone: ^0.9.0`
   - [ ] Configurar permissões Android (manifest)
   - [ ] Configurar permissões iOS (Info.plist)
   - [ ] Inicializar no main.dart

2. **Service Layer**
   - [ ] Criar `NotificationService` (core/services)
   - [ ] Método `scheduleNotification()`
   - [ ] Método `cancelNotification()`
   - [ ] Método `cancelAllNotifications()`
   - [ ] Método `getBadgeCount()`

#### Fase 2: Backend Integration (2h)
3. **Repository & Use Cases**
   - [ ] Adicionar campo `notificationId` ao TaskEntity
   - [ ] `ScheduleReminderUseCase`
   - [ ] `CancelReminderUseCase`
   - [ ] Sincronizar com TaskRepository

4. **Background Scheduler**
   - [ ] WorkManager para Android (opcional)
   - [ ] Background Fetch para iOS (opcional)

#### Fase 3: UI (2h)
5. **Date/Time Picker**
   - [ ] Botão "Lembrar-me" em Task Detail
   - [ ] Date Picker nativo
   - [ ] Time Picker nativo
   - [ ] Preview: "Amanhã às 14:00"

6. **Quick Actions**
   - [ ] Preset buttons: "Daqui 1h", "Amanhã 9h", "Segunda 14h"
   - [ ] Custom date/time

#### Fase 4: Notificação (2h)
7. **Payload & Actions**
   - [ ] Ao tocar: abrir TaskDetailPage
   - [ ] Action buttons: "Concluir", "Adiar 10min", "Adiar 1h"
   - [ ] Badge count no ícone do app

**Critérios de Aceite:**
- [ ] Receber notificação na hora exata
- [ ] Tocar na notificação abre a tarefa
- [ ] Snooze funciona e reagenda
- [ ] Badge mostra tarefas pendentes de hoje
- [ ] Cancelar lembrete remove notificação

---

## 📊 Matriz de Decisão

| Opção | Tempo | Complexidade | Impacto UX | Dependências | Status |
|-------|-------|--------------|-----------|--------------|--------|
| **1. Quick Wins** | 2-3h | 🟢 Baixa | 🟡 Médio | Nenhuma | ✅ **COMPLETO** |
| **2. Sistema de Listas** | 4-6h | 🟡 Média | 🟢 Alto | Nenhuma | ✅ **COMPLETO** |
| **3. Subtarefas** | 3-4h | 🟡 Média | 🟢 Alto | Nenhuma | 🎯 **PRÓXIMA** |
| **4. Notificações** | 6-8h | 🔴 Alta | 🟢 Alto | Permissões | 🔜 **DEPOIS** |

---

## 🗓️ Plano Sugerido para Hoje

### Manhã (4h)
1. ✅ **Quick Wins** (2-3h)
   - Integrações do Meu Dia
   - Analytics
   - Melhorias de UX

2. 🎯 **Sistema de Listas - Fase 1** (1-2h)
   - Repository completo
   - Use cases

### Tarde (4h)
3. 🎯 **Sistema de Listas - Fase 2** (2-3h)
   - UI completa
   - Color picker
   - Icon picker

4. 🎯 **Sistema de Listas - Fase 3** (1h)
   - Polish
   - Testes manuais

**Resultado esperado:** Sistema de Listas 100% funcional ao final do dia

---

## 📝 Próximos Dias (Roadmap Semana)

### Dia 2 (18/12)
- ✅ **Subtarefas/Steps** completo (3-4h)
- 🎨 **UI/UX Polish** - Animações e gestos (2-3h)

### Dia 3 (19/12)
- 🔔 **Notificações e Lembretes** (6-8h)

### Dia 4 (20/12)
- 🔄 **Recorrência de Tarefas** (início)
- 📊 **Testes unitários** das features implementadas

### Dia 5 (21/12)
- 🔄 **Recorrência de Tarefas** (conclusão)
- 🎨 **Tema escuro** e personalização

---

## 🎯 Critérios de Sucesso da Semana

Ao final da semana (21/12), o app deve ter:
- [x] ✅ Meu Dia funcional (COMPLETO)
- [x] ✅ Sistema de Listas completo (COMPLETO)
- [ ] ✅ Subtarefas/Steps funcionando
- [ ] ✅ Notificações básicas
- [ ] 🟡 Recorrência de tarefas (MVP - JÁ IMPLEMENTADO)
- [ ] 🎨 UI polida (tema escuro)
- [ ] 📊 70%+ de cobertura de testes

**Meta:** App utilizável no dia-a-dia como substituto do Microsoft To Do para uso pessoal.

---

## 📚 Referências Técnicas

### Exemplos no Monorepo
- **Sistema de Sync**: `app-gasometer` e `app-plantis` (referência de UnifiedSyncManager)
- **Drift Migrations**: `app-taskolist/lib/core/database/drift_database.dart`
- **Riverpod Patterns**: `app-receituagro` (100% Riverpod 3.0)
- **UI/UX Components**: `app-nebulalist` (ModernDrawer, Animations)

### Documentação
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Best Practices](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)

---

**👤 Decisão do Usuário:** Qual opção vamos implementar agora?

---

## 📝 SESSÃO 2025-12-18 - RESUMO

### ✅ Implementado:
1. **Feature Meu Dia (My Day)** - MVP 95% completo
   - Database schema (MyDayTasks table)
   - Domain layer completo
   - Data layer completo  
   - Providers Riverpod
   - MyDayPage UI com sugestões

2. **Listas Coloridas** - 30% completo
   - Database migration (coluna color)
   - TaskListColors constants

### ⚠️ Bugs Conhecidos (Build Web):
- Conflito Failure (core vs local)
- ServerException não existe
- task_list_providers precisa regenerar .g.dart
- Métodos faltando implementação

### 🎯 Próxima Sessão:
1. Corrigir erros de build (30min)
2. Completar Listas Coloridas (1h)
3. Iniciar Sistema de Recorrência (2h)

**Horas Investidas Hoje**: ~4h  
**Progresso**: Meu Dia funcional, mas precisa correções de build antes de testar
