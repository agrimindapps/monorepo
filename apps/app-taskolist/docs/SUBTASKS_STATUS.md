# 📊 Status - Sistema de Subtarefas

**Data**: 18/12/2025 - 17:56  
**Status**: ✅ **60% IMPLEMENTADO** (MVP Funcional)

---

## ✅ O que JÁ está implementado

### 1. **Domain Layer** (100%)
- ✅ `TaskEntity.parentTaskId` - Campo para hierarquia
- ✅ `TaskEntity.isSubtask` - Helper method
- ✅ `GetSubtasks` use case - Buscar subtarefas
- ✅ `GetSubtasksParams` - Parâmetros do use case

### 2. **Data Layer** (100%)
- ✅ Drift table com campo `parentTaskId`
- ✅ Repository methods implementados
- ✅ `getSubtasks(parentTaskId)` funcionando

### 3. **Presentation Layer** (80%)
- ✅ `SubtaskListWidget` - Widget principal
- ✅ `CreateSubtaskDialog` - Dialog de criação/edição
- ✅ `subtasksProvider` - Provider Riverpod
- ✅ CRUD completo:
  - ✅ Create subtask
  - ✅ Update subtask
  - ✅ Delete subtask (com confirmação)
  - ✅ Toggle completion (checkbox)

### 4. **UI Implementada** (70%)
- ✅ Lista de subtarefas no TaskDetailPage
- ✅ Checkbox para marcar conclusão
- ✅ LineThrough em tarefas completadas
- ✅ Botão "Adicionar Subtarefa"
- ✅ Empty state
- ✅ Loading/Error states
- ✅ PopupMenu (editar/deletar)
- ✅ Confirmação de exclusão

---

## ⚠️ O que está FALTANDO

### 1. **Barra de Progresso** (Prioridade: Alta)
- [ ] Contador "X/Y subtarefas concluídas"
- [ ] Barra de progresso visual
- [ ] Exibir na TaskCard (lista principal)
- [ ] Exibir no TaskDetailPage (header)

### 2. **Reordenação** (Prioridade: Média)
- [ ] Drag to reorder subtarefas
- [ ] Persistir ordem (campo `position`)
- [ ] Feedback visual durante drag

### 3. **UI/UX Melhorias** (Prioridade: Média)
- [ ] Swipe to delete gesture
- [ ] Animações de add/remove
- [ ] Inline text field (quick add)
- [ ] Skeleton loading

### 4. **Lógica Avançada** (Prioridade: Baixa)
- [ ] Auto-complete parent task
- [ ] Setting para habilitar/desabilitar auto-complete
- [ ] Notificação ao completar todas

### 5. **Analytics** (Prioridade: Baixa)
- [ ] Event: subtask_created
- [ ] Event: subtask_completed
- [ ] Event: all_subtasks_completed

---

## 🎯 PLANO DE IMPLEMENTAÇÃO

### Fase 1: Barra de Progresso (1-1.5h) 🎯 **PRIORIDADE**

#### Backend (15min)
1. Helper method no TaskEntity:
   ```dart
   int get completedSubtasksCount
   int get totalSubtasksCount
   double get subtasksProgress // 0.0 - 1.0
   ```

2. Provider para contadores:
   ```dart
   @riverpod
   Future<SubtaskProgress> subtaskProgress(Ref ref, String taskId)
   ```

#### UI - TaskCard (30min)
3. Badge com contador:
   ```
   [✓ 3/5]
   ```

4. Mini barra de progresso:
   ```
   ████████░░ 80%
   ```

#### UI - TaskDetailPage (30min)
5. Header com progresso:
   ```
   Subtarefas (3 de 5 concluídas)
   ████████████░░░░ 60%
   ```

---

### Fase 2: Inline Quick Add (30min) 🎯 **QUICK WIN**

1. TextField inline no fim da lista
2. Pressionar Enter = criar subtask
3. Sem abrir dialog
4. UX rápida e fluida

**Exemplo:**
```
[✓] Subtask 1
[✓] Subtask 2
[ ] Subtask 3
[____________] + Adicionar subtask...
```

---

### Fase 3: Swipe to Delete (30min)

1. Dismissible widget
2. Background vermelho
3. Confirmação opcional
4. Animação suave

---

### Fase 4: Reordenação (1h)

1. ReorderableListView
2. Handle de drag (⋮⋮)
3. Persistir position
4. Feedback visual

---

### Fase 5: Auto-Complete (30min)

1. Verificar ao marcar última subtask
2. Dialog de confirmação (opcional)
3. Marcar parent task como completed
4. Analytics event

---

## 📋 CRITÉRIOS DE ACEITE

### MVP Atual (60%):
- [x] Criar subtarefa
- [x] Editar subtarefa
- [x] Deletar subtarefa
- [x] Marcar como concluída
- [x] Ver lista de subtarefas

### MVP Completo (100%):
- [ ] Ver progresso "3/5" na TaskCard
- [ ] Ver barra de progresso no detalhe
- [ ] Adicionar subtask inline (sem dialog)
- [ ] Reordenar subtasks (drag)
- [ ] Auto-complete parent task (opcional)

---

## 🔧 ARQUIVOS PRINCIPAIS

### Existentes:
- `lib/features/tasks/domain/task_entity.dart` - Entity
- `lib/features/tasks/domain/get_subtasks.dart` - Use case
- `lib/shared/widgets/subtask_list_widget.dart` - Widget principal (232 linhas)
- `lib/shared/widgets/create_subtask_dialog.dart` - Dialog (182 linhas)
- `lib/features/tasks/presentation/providers/task_notifier.dart` - Providers

### A Criar:
- `lib/features/tasks/domain/subtask_progress.dart` - Model de progresso
- `lib/features/tasks/presentation/widgets/subtask_progress_indicator.dart` - Widget
- `lib/features/tasks/presentation/widgets/quick_add_subtask_field.dart` - Inline field

---

## 🚀 DECISÕES TÉCNICAS

### Estrutura de Dados:
- ✅ Usar mesmo TaskEntity (não criar SubtaskEntity)
- ✅ Campo `parentTaskId` para hierarquia
- ✅ Campo `position` para ordenação
- ✅ Filtrar subtasks via repository

### UI/UX:
- ✅ Checkbox circular (consistente)
- ✅ Card style para cada subtask
- ✅ PopupMenu para ações
- 🔜 Inline field para quick add
- 🔜 Barra de progresso no header

### Performance:
- ✅ Provider separado por parentTaskId
- ✅ Cache automático do Riverpod
- ✅ Invalidação ao criar/atualizar

---

## 📊 ESTIMATIVAS

| Fase | Tempo | Complexidade | Impacto |
|------|-------|--------------|---------|
| 1. Barra de Progresso | 1-1.5h | 🟡 Média | 🟢 Alto |
| 2. Inline Quick Add | 30min | 🟢 Baixa | 🟢 Alto |
| 3. Swipe to Delete | 30min | 🟢 Baixa | 🟡 Médio |
| 4. Reordenação | 1h | 🟡 Média | 🟡 Médio |
| 5. Auto-Complete | 30min | 🟢 Baixa | 🟡 Médio |
| **TOTAL** | **3.5-4h** | - | - |

---

## 🎯 RECOMENDAÇÃO

**Implementar HOJE:**
1. ✅ Barra de Progresso (1.5h) - Alto impacto
2. ✅ Inline Quick Add (30min) - Quick win

**Implementar DEPOIS:**
3. Swipe to Delete (30min)
4. Reordenação (1h)
5. Auto-Complete (30min)

**Total para MVP 100%: ~2h**

---

**Decisão do usuário**: Qual fase implementar primeiro?
