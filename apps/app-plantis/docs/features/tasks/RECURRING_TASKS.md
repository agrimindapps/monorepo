# 🔄 Recurring Tasks - Documentação Técnica

**Feature**: tasks  
**Atualizado**: 13/12/2025

---

## 📖 Visão Geral

Recurring tasks (tarefas recorrentes) são tarefas que se repetem automaticamente após conclusão, como:
- 💧 Regar plantas (a cada 3 dias)
- ✂️ Podar galhos (mensal)
- 🌱 Fertilizar (quinzenal)

---

## 🔧 Implementação

### 1️⃣ Modelo de Dados

**Arquivo**: [domain/entities/task_entity.dart](../../../lib/features/tasks/domain/entities/task_entity.dart)

```dart
class TaskEntity {
  final bool isRecurring;              // Se é recorrente
  final RecurrenceType? recurrenceType; // Tipo: daily, weekly, monthly
  final int? recurrenceInterval;       // Intervalo: a cada X dias/semanas/meses
  final DateTime? nextDueDate;         // Próxima data de vencimento
  
  // Outros campos...
}

enum RecurrenceType {
  daily,    // Diária
  weekly,   // Semanal
  monthly,  // Mensal
}
```

**Campos Obrigatórios para Recurring Tasks**:
- `isRecurring = true`
- `recurrenceType` não-nulo (daily/weekly/monthly)
- `recurrenceInterval` > 0

**Campo Opcional**:
- `nextDueDate`: Se fornecido, usa esse valor. Se null, calcula automaticamente.

---

### 2️⃣ Criação de Recurring Task

**Arquivo**: [domain/usecases/create_recurring_task_usecase.dart](../../../lib/features/tasks/domain/usecases/create_recurring_task_usecase.dart)

```dart
Future<Either<Failure, TaskEntity>> call(CreateRecurringTaskParams params) async {
  // 1. Valida parâmetros
  if (!params.isValid) {
    return Left(ValidationFailure('Parâmetros inválidos'));
  }

  // 2. Calcula nextDueDate se não fornecido
  final nextDueDate = params.nextDueDate ?? 
    _calculateNextDueDate(params.dueDate, params.recurrenceType, params.interval);

  // 3. Cria task via repository
  return await repository.createTask(
    TaskEntity(
      isRecurring: true,
      recurrenceType: params.recurrenceType,
      recurrenceInterval: params.interval,
      nextDueDate: nextDueDate,
      // ... outros campos
    ),
  );
}
```

---

### 3️⃣ Conclusão e Regeneração Automática

**Arquivo**: [data/repositories/tasks_repository_impl.dart](../../../lib/features/tasks/data/repositories/tasks_repository_impl.dart) (linhas 602-609)

#### Comportamento Atual (Após Fix PLT-TASKS-001)

```dart
Future<Either<Failure, void>> completeTask(
  String id, {
  DateTime? nextDueDate,
}) async {
  // 1. Marca task atual como completada
  await localDatasource.completeTask(id);

  // 2. Se é recurring, regenera automaticamente
  final task = await getTaskById(id);
  
  if (task.isRecurring) {
    if (nextDueDate != null) {
      // Usa nextDueDate fornecido
      await _createNextRecurringTaskWithDate(task, nextDueDate);
    } else {
      // Calcula automaticamente baseado em recurrenceType/interval
      await createRecurringTask(task);
    }
  }

  return Right(null);
}
```

#### Antes do Fix (Bug)

```dart
// ❌ BUG: Só regenerava se nextDueDate fosse fornecido
if (nextDueDate != null) {
  await _createNextRecurringTaskWithDate(task, nextDueDate);
}
```

**Problema**: Tasks recorrentes não regeneravam automaticamente se `nextDueDate` não fosse passado.

**Solução**: Sempre verifica `task.isRecurring` e regenera com cálculo automático se necessário.

---

### 4️⃣ Cálculo de Próxima Data

**Método**: `_calculateNextDueDate()`

```dart
DateTime _calculateNextDueDate(
  DateTime currentDueDate,
  RecurrenceType type,
  int interval,
) {
  switch (type) {
    case RecurrenceType.daily:
      return currentDueDate.add(Duration(days: interval));
      
    case RecurrenceType.weekly:
      return currentDueDate.add(Duration(days: 7 * interval));
      
    case RecurrenceType.monthly:
      return DateTime(
        currentDueDate.year,
        currentDueDate.month + interval,
        currentDueDate.day,
      );
  }
}
```

**Exemplos**:
- `daily, interval=3`: Próxima task em 3 dias
- `weekly, interval=2`: Próxima task em 14 dias (2 semanas)
- `monthly, interval=1`: Próxima task em 1 mês (mesmo dia)

---

## 🔄 Fluxo Completo

```
1. User cria recurring task
   ↓
2. CreateRecurringTaskUseCase valida e cria
   ↓
3. Task fica "pending" até dueDate
   ↓
4. User completa task
   ↓
5. CompleteTaskUseCase marca como done
   ↓
6. ✨ REGENERAÇÃO AUTOMÁTICA
   - Cria nova task com nextDueDate calculado
   - Nova task fica "pending"
   ↓
7. Ciclo se repete infinitamente ♾️
```

---

## 📊 Estados de Recurring Task

### Lifecycle

```
[PENDING] → (user completa) → [DONE] → (regenera) → [PENDING (nova task)]
   ↑                                                         ↓
   └─────────────────── (ciclo infinito) ──────────────────┘
```

### Identificação

- **Task Original**: `id = original_id`, `isCompleted = true`
- **Task Regenerada**: `id = novo_id`, `isCompleted = false`, `dueDate = calculado`

**Nota**: Cada regeneração cria uma **nova task** com novo ID. A task original permanece no histórico como "done".

---

## 🎯 Queries e Filtros

### Listar Pending Recurring Tasks

```dart
Future<List<TaskEntity>> getPendingRecurringTasks() async {
  return repository.getTasks(
    filters: TaskFilters(
      isRecurring: true,
      isCompleted: false,
    ),
  );
}
```

### Listar Histórico de Recurring Task

```dart
Future<List<TaskEntity>> getRecurringTaskHistory(String plantId) async {
  return repository.getTasks(
    filters: TaskFilters(
      plantId: plantId,
      isRecurring: true,
      // Retorna todas (completed + pending)
    ),
  ).sortedBy((task) => task.dueDate);
}
```

---

## 🐛 Problemas Conhecidos e Soluções

### ✅ RESOLVIDO: PLT-TASKS-001

**Problema**: Tasks recorrentes não regeneravam automaticamente.

**Causa**: `completeTask()` só chamava regeneração se `nextDueDate` fosse fornecido manualmente.

**Fix**: Modificado para sempre verificar `task.isRecurring` e regenerar com cálculo automático.

**Status**: ✅ Corrigido em 11/12/2025

---

### ⚠️ PENDENTE: PLT-TASKS-004

**Problema**: Falta validação de `nextDueDate` em tasks recorrentes.

**Cenário**: Se `nextDueDate` for anterior a `dueDate`, cria inconsistência.

**Solução Proposta**:
```dart
// Em CreateRecurringTaskUseCase
if (params.nextDueDate != null && 
    params.nextDueDate!.isBefore(params.dueDate)) {
  return Left(ValidationFailure(
    'nextDueDate deve ser posterior a dueDate'
  ));
}
```

**Status**: 🟡 Alta prioridade, 4h estimadas

---

## 📱 UI/UX

### Criação de Recurring Task

```dart
// Em CreateTaskDialog
CheckboxListTile(
  title: Text('Tarefa recorrente'),
  value: isRecurring,
  onChanged: (value) => setState(() => isRecurring = value),
)

if (isRecurring) {
  DropdownButton<RecurrenceType>(
    items: [
      DropdownMenuItem(value: RecurrenceType.daily, child: Text('Diária')),
      DropdownMenuItem(value: RecurrenceType.weekly, child: Text('Semanal')),
      DropdownMenuItem(value: RecurrenceType.monthly, child: Text('Mensal')),
    ],
    onChanged: (value) => setState(() => recurrenceType = value),
  ),
  
  TextField(
    label: Text('A cada X dias/semanas/meses'),
    keyboardType: TextInputType.number,
    onChanged: (value) => setState(() => interval = int.parse(value)),
  ),
}
```

### Exibição na Lista

```dart
// Em TaskCard
if (task.isRecurring) {
  Icon(Icons.repeat, size: 16, color: Colors.blue),
  SizedBox(width: 4),
  Text(
    _formatRecurrence(task.recurrenceType, task.interval),
    style: TextStyle(fontSize: 12, color: Colors.grey),
  ),
}

// Exemplo: "🔄 A cada 3 dias"
```

---

## 🧪 Testes

### Cenários de Teste Importantes

1. **Criação com nextDueDate manual**
   - Input: `isRecurring=true`, `nextDueDate=+7 dias`
   - Output: Task criada com nextDueDate especificado

2. **Criação com cálculo automático**
   - Input: `isRecurring=true`, `recurrenceType=daily`, `interval=3`, `nextDueDate=null`
   - Output: Task criada com nextDueDate = dueDate + 3 dias

3. **Conclusão regenera automaticamente**
   - Input: Completa recurring task sem fornecer nextDueDate
   - Output: Nova task criada com nextDueDate calculado

4. **Conclusão com nextDueDate manual**
   - Input: Completa recurring task fornecendo nextDueDate
   - Output: Nova task criada com nextDueDate especificado

5. **Histórico mantém tasks antigas**
   - Input: Completa recurring task 3 vezes
   - Output: 3 tasks "done" + 1 task "pending" no banco

---

## 📚 Arquivos Relacionados

| Arquivo | Descrição |
|---------|-----------|
| [task_entity.dart](../../../lib/features/tasks/domain/entities/task_entity.dart) | Modelo de dados |
| [create_recurring_task_usecase.dart](../../../lib/features/tasks/domain/usecases/create_recurring_task_usecase.dart) | Criação de recurring task |
| [complete_task_usecase.dart](../../../lib/features/tasks/domain/usecases/complete_task_usecase.dart) | Conclusão com regeneração |
| [tasks_repository_impl.dart](../../../lib/features/tasks/data/repositories/tasks_repository_impl.dart) | Lógica de regeneração (linhas 602-609) |

---

## 🎓 Referências

- Bug Fix: [CHANGELOG_QUALITY_FIXES.md](../../CHANGELOG_QUALITY_FIXES.md#plt-tasks-001)
- Tarefas Pendentes: [TASKS.md](TASKS.md)
