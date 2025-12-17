# 🌟 Feature Specification: Meu Dia (My Day)

**Feature ID:** MY-DAY-001  
**Prioridade:** 🔴 ALTA (Diferencial do produto)  
**Estimativa:** 3-5 dias  
**Status:** 📝 Planejamento

---

## 🎯 Conceito

"Meu Dia" é um planejador diário que reseta à meia-noite. O usuário escolhe conscientemente quais tarefas focar hoje.

**Diferencial:** Não acumula. Tarefas não concluídas não rolam automaticamente para o próximo dia.

---

## 📋 Funcionalidades Core

### 1. Adicionar ao Meu Dia
- **3 formas:** Da lista de tarefas, da página Meu Dia, das sugestões
- **Feedback:** Toast "Adicionado ao Meu Dia"

### 2. Tarefas Sugeridas
**Critérios (prioridade):**
1. Vencidas
2. Vencendo hoje
3. Estrelas
4. Em progresso

### 3. Reset à Meia-Noite
- Background task arquiva tarefas do dia anterior
- Nova lista vazia todo dia

### 4. Remover do Meu Dia
- Swipe left
- Completar tarefa
- Deletar tarefa

---

## 🗄️ Estrutura de Dados

```dart
class MyDayTaskEntity {
  final String id;
  final String taskId;           // FK para Task
  final DateTime dayDate;        // Data do dia (sem hora)
  final DateTime addedAt;
  final bool wasCompleted;
  final DateTime? completedAt;
  final bool wasRemoved;
  final DateTime? removedAt;
  final bool isArchived;         // Para dias passados
}

// Drift Table
class MyDayTasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get dayDate => dateTime()();
  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get wasCompleted => boolean().withDefault(Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get wasRemoved => boolean().withDefault(Constant(false))();
  DateTimeColumn get removedAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, dayDate}, // Única vez por dia
  ];
}
```

---

## 🏗️ Use Cases

### 1. AddTaskToMyDay
```dart
Future<Either<Failure, MyDayTaskEntity>> call(String taskId)
```
- Verifica se já está no Meu Dia
- Cria `MyDayTaskEntity` com dayDate = hoje
- Salva no repository

### 2. RemoveTaskFromMyDay
```dart
Future<Either<Failure, void>> call(String taskId)
```
- Marca `wasRemoved = true`
- Seta `removedAt`

### 3. GetMyDayTasks
```dart
Future<Either<Failure, List<TaskEntity>>> call()
```
- Busca `MyDayTask` onde `dayDate = hoje AND isActive`
- Popula com `Task` correspondente
- Ordena: incompletas primeiro, depois por addedAt

### 4. GetSuggestedTasks
```dart
Future<Either<Failure, List<TaskEntity>>> call()
```
- Filtra: vencidas, hoje, estrelas, em progresso
- Exclui: já no Meu Dia
- Ordena por score de relevância

### 5. CompleteMyDayTask
```dart
Future<Either<Failure, void>> call(String taskId)
```
- Marca `Task.status = completed`
- Marca `MyDayTask.wasCompleted = true`

---

## 🎨 UI Components

### MyDayPage
- **Header:** "Bom dia • Meu Dia • Terça, 17 de dezembro • 2 de 5 concluídas"
- **Seção Sugeridas:** Colapsável, com badge de quantidade
- **Lista de Tarefas:** Cards com swipe actions
- **FAB:** Adicionar tarefa

### SuggestedTaskCard
- Indicador de prioridade (cor na borda)
- Botão "+" para adicionar ao dia
- Badges: "Vencida", "Vence hoje", "⭐ Importante"

### EmptyState
- Ícone de sol ☀️
- Texto: "Planeje seu dia"

---

## ✅ Critérios de Aceite

**Funcional:**
- [ ] 3 formas de adicionar tarefa
- [ ] Sugestões aparecem automaticamente
- [ ] Reset à meia-noite funciona
- [ ] Swipe remove do dia
- [ ] Completar remove do Meu Dia
- [ ] Contador atualiza em tempo real

**Performance:**
- [ ] Carrega em < 500ms
- [ ] Feedback em < 100ms
- [ ] 60fps nas animações

**UX:**
- [ ] Saudação contextual (dia/tarde/noite)
- [ ] Data por extenso
- [ ] Empty state claro
- [ ] Toast de confirmação

---

## 📅 Plano de 5 Dias

**Dia 1:** Entity + Drift table + migrations  
**Dia 2:** Repository implementation + testes  
**Dia 3:** Use cases + testes  
**Dia 4:** Providers (Riverpod) + UI base  
**Dia 5:** UI polida + background task + testes finais

---

## 🔗 Ver Também

- [Análise Completa: Microsoft To Do](../../MICROSOFT_TODO_ANALYSIS.md)
- [Roadmap do Taskolist](../../README.md)

---

**Criado:** 17/12/2025  
**Versão:** 1.0  
**Status:** 📘 Pronto para Implementação

