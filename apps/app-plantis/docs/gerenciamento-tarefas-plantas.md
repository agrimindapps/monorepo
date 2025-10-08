# Gerenciamento de Tarefas de Plantas - Plantis

**Documento de Análise e Implementação**
**Versão:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Produção

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Modelo de Dados](#modelo-de-dados)
4. [CRUD Completo](#crud-completo)
5. [Geração Automática de Tarefas](#geração-automática-de-tarefas)
6. [Sistema de Regeneração](#sistema-de-regeneração)
7. [Vinculação com Plantas](#vinculação-com-plantas)
8. [Exclusão Cascata](#exclusão-cascata)
9. [Notificações](#notificações)
10. [Sincronização](#sincronização)
11. [Sistema Unificado PlantTask vs Task](#sistema-unificado)
12. [UI/UX](#uiux)
13. [Histórico de Tarefas](#histórico-de-tarefas)
14. [Estado da Implementação](#estado-da-implementação)
15. [Fluxos Críticos](#fluxos-críticos)
16. [Gaps e Pendências](#gaps-e-pendências)
17. [Recomendações](#recomendações)
18. [Roadmap](#roadmap)
19. [Atualizações e Tarefas](#atualizações-e-tarefas)

---

## 🎯 Visão Geral

O sistema de gerenciamento de tarefas do Plantis é responsável por **automatizar e facilitar o cuidado com plantas** através de lembretes inteligentes e tarefas recorrentes.

### Objetivos

- ✅ Automatizar criação de tarefas quando planta é cadastrada
- ✅ Regenerar tarefas automaticamente após conclusão
- ✅ Sincronizar tarefas entre Hive (local) e Firebase (remoto) em tempo real
- ✅ Notificar usuário sobre tarefas pendentes e atrasadas
- ✅ Manter histórico completo de cuidados realizados
- ✅ Suportar múltiplos tipos de cuidados (regar, adubar, podar, etc)

### Stack Tecnológica

```yaml
Local Storage: Hive (PlantisBoxes.tasks)
Remote Storage: Firebase Firestore (users/{userId}/tasks)
State Management: Riverpod + Provider
Architecture: Clean Architecture (Domain/Data/Presentation)
Sync Strategy: Offline-first with realtime sync
Notifications: flutter_local_notifications
```

### Tipos de Tarefas Suportadas

```dart
enum TaskType {
  watering,          // Regar - Intervalo padrão: 3 dias
  fertilizing,       // Adubar - Intervalo padrão: 14 dias
  pruning,           // Podar - Intervalo padrão: 30 dias
  repotting,         // Replantar - Intervalo padrão: 180 dias
  cleaning,          // Limpar folhas
  spraying,          // Pulverizar
  sunlight,          // Banho de sol - Intervalo padrão: 1 dia
  shade,             // Colocar na sombra
  pestInspection,    // Inspeção de pragas - Intervalo padrão: 7 dias
  custom,            // Personalizada
}
```

---

## 🏗️ Arquitetura

### Clean Architecture Aplicada

```
features/tasks/
├── domain/
│   ├── entities/
│   │   ├── task.dart                          # Entidade Task (extends BaseSyncEntity)
│   │   └── task_history.dart                  # Histórico de conclusões
│   ├── repositories/
│   │   └── tasks_repository.dart              # Interface abstrata
│   └── usecases/
│       ├── get_tasks_usecase.dart             # Listar tarefas
│       ├── add_task_usecase.dart              # Criar tarefa
│       ├── update_task_usecase.dart           # Atualizar tarefa
│       ├── complete_task_usecase.dart         # Concluir simples
│       ├── complete_task_with_regeneration_usecase.dart  # ⭐ Concluir + Regenerar
│       └── generate_initial_tasks_usecase.dart           # Gerar ao criar planta
├── data/
│   ├── models/
│   │   └── task_model.dart                    # Model (extends Task entity)
│   ├── datasources/
│   │   ├── local/
│   │   │   └── tasks_local_datasource.dart    # Hive operations
│   │   └── remote/
│   │       └── tasks_remote_datasource.dart   # Firestore operations
│   └── repositories/
│       └── tasks_repository_impl.dart         # ⭐ Implementação concreta
└── presentation/
    ├── pages/
    │   └── tasks_list_page.dart               # Lista principal de tarefas
    ├── widgets/
    │   ├── task_completion_dialog.dart        # Dialog de conclusão
    │   ├── task_creation_dialog.dart          # Dialog de criação manual
    │   ├── tasks_list_view.dart               # ListView de tarefas
    │   ├── tasks_dashboard.dart               # Dashboard com resumo
    │   └── empty_tasks_widget.dart            # Estado vazio
    ├── providers/
    │   └── tasks_provider.dart                # State management (ChangeNotifier)
    └── notifiers/
        └── tasks_notifier.dart                # Riverpod notifiers (moderno)
```

### Fluxo de Dados

```
UI (Widget)
  ↓ [user action]
Provider/Notifier
  ↓ [calls usecase]
UseCase (business logic)
  ↓ [calls repository]
Repository (interface)
  ↓ [implementation]
TasksRepositoryImpl
  ↓ [checks network]
├─> Local Datasource (Hive) ← [Offline-first]
└─> Remote Datasource (Firestore) ← [Background sync]
```

---

## 📊 Modelo de Dados

### Entidade Task

```dart
class Task extends BaseSyncEntity {
  // Identificação e metadados
  final String id;              // UUID v4
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;         // Dono da tarefa

  // Dados da tarefa
  final String title;           // "Regar Samambaia"
  final String? description;    // Descrição opcional
  final String plantId;         // ID da planta (FK)
  final TaskType type;          // watering, fertilizing, etc
  final TaskStatus status;      // pending, completed, overdue, cancelled
  final TaskPriority priority;  // low, medium, high, urgent

  // Datas importantes
  final DateTime dueDate;       // Data prevista
  final DateTime? completedAt;  // Data de conclusão
  final String? completionNotes;// Observações ao concluir

  // Recorrência
  final bool isRecurring;       // Se é recorrente
  final int? recurringIntervalDays;  // Intervalo em dias
  final DateTime? nextDueDate;  // Próxima data (se recorrente)

  // Sincronização (de BaseSyncEntity)
  final DateTime? lastSyncAt;
  final bool isDirty;           // Precisa sincronizar
  final bool isDeleted;         // Soft delete
  final int version;            // Conflict resolution
}
```

### TaskStatus - Estados

```dart
enum TaskStatus {
  pending,      // Pendente - aguardando execução
  completed,    // Concluída - executada com sucesso
  overdue,      // Atrasada - passou da data sem conclusão
  cancelled,    // Cancelada - usuário cancelou
}
```

### TaskPriority - Prioridades

```dart
enum TaskPriority {
  low,          // Baixa - pode esperar
  medium,       // Média - padrão
  high,         // Alta - importante
  urgent,       // Urgente - crítico (ex: planta morrendo)
}
```

### Estrutura Firebase

**Collection Path:** `users/{userId}/tasks/{taskId}`

```json
{
  "id": "task_uuid_v4",
  "created_at": 1704672000000,
  "updated_at": 1704672000000,
  "user_id": "user123",

  "title": "Regar Samambaia",
  "description": "Regar com 200ml de água",
  "plant_id": "plant_abc123",
  "type": "regar",
  "status": "pendente",
  "priority": "media",

  "due_date": 1704758400000,
  "completed_at": null,
  "completion_notes": null,

  "is_recurring": true,
  "recurring_interval_days": 3,
  "next_due_date": 1705017600000,

  "last_sync_at": 1704672000000,
  "is_dirty": false,
  "is_deleted": false,
  "version": 1
}
```

### Estrutura Hive

**Box Name:** `tasks` (PlantisBoxes.tasks)

Armazenamento: Key-Value JSON serializado

```dart
// Key: task_id
// Value: JSON string
{
  "all_tasks": [
    {
      "id": "task_uuid",
      "title": "Regar Samambaia",
      "plant_id": "plant_abc",
      // ... todos os campos da entidade
    }
  ]
}
```

---

## 🔧 CRUD Completo

### 1. Create (Adicionar Tarefa)

**Manual:** Usuário cria tarefa customizada

```dart
// features/tasks/domain/usecases/add_task_usecase.dart
class AddTaskUseCase {
  Future<Either<Failure, Task>> call(AddTaskParams params) async {
    // 1. Valida parâmetros
    final validation = _validate(params);
    if (validation != null) return Left(validation);

    // 2. Cria entidade Task
    final task = Task(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: params.title,
      plantId: params.plantId,
      type: params.type,
      dueDate: params.dueDate,
      // ... outros campos
    );

    // 3. Salva no repositório
    return await tasksRepository.addTask(task);
  }
}
```

**Fluxo:**
```
User → UI Dialog → TasksProvider.addTask() → AddTaskUseCase
  → TasksRepositoryImpl.addTask()
    → LocalDataSource.cacheTask() [salva no Hive]
    → RemoteDataSource.addTask() [se online → Firebase]
  ← Task salva
```

**Automático:** Sistema gera tarefas ao criar planta

```dart
// features/tasks/domain/usecases/generate_initial_tasks_usecase.dart
class GenerateInitialTasksUseCase {
  Future<Either<Failure, List<Task>>> call(String plantId) async {
    // 1. Busca planta e configuração
    final plant = await plantsRepository.getPlantById(plantId);

    // 2. Gera tarefas baseado na config
    final tasks = [];
    if (plant.config.wateringIntervalDays > 0) {
      tasks.add(Task(
        type: TaskType.watering,
        dueDate: DateTime.now().add(Duration(days: plant.config.wateringIntervalDays)),
        // ...
      ));
    }
    // ... outras tarefas (fertilizing, pruning, etc)

    // 3. Salva todas as tarefas
    for (final task in tasks) {
      await tasksRepository.addTask(task);
    }

    return Right(tasks);
  }
}
```

### 2. Read (Listar Tarefas)

**Queries Suportadas:**

```dart
// Todas as tarefas
Future<Either<Failure, List<Task>>> getTasks();

// Por planta específica
Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId);

// Por status
Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status);

// Tarefas atrasadas
Future<Either<Failure, List<Task>>> getOverdueTasks();

// Tarefas de hoje
Future<Either<Failure, List<Task>>> getTodayTasks();

// Próximas 7 dias
Future<Either<Failure, List<Task>>> getUpcomingTasks();
```

**Estratégia Offline-First:**

```dart
// features/tasks/data/repositories/tasks_repository_impl.dart
Future<Either<Failure, List<Task>>> getTasks() async {
  // 1. Tenta cache local primeiro (rápido)
  final localTasks = await localDataSource.getTasks();

  if (localTasks.isNotEmpty) {
    // 2. Retorna cache imediatamente
    // 3. Sincroniza em background (se online)
    if (await networkInfo.isConnected) {
      _syncTasksInBackground();
    }
    return Right(localTasks);
  }

  // 4. Se cache vazio e online, busca remote
  if (await networkInfo.isConnected) {
    final remoteTasks = await remoteDataSource.getTasks();
    await localDataSource.cacheTasks(remoteTasks);
    return Right(remoteTasks);
  }

  // 5. Se offline e sem cache, retorna vazio
  return Right([]);
}
```

### 3. Update (Atualizar Tarefa)

**Use Cases:**
- Alterar data da tarefa
- Mudar prioridade
- Editar título/descrição
- Reagendar tarefa

```dart
// features/tasks/domain/usecases/update_task_usecase.dart
Future<Either<Failure, Task>> updateTask(Task updatedTask) async {
  // 1. Marca como dirty (precisa sync)
  final taskWithDirtyFlag = updatedTask.copyWith(
    isDirty: true,
    updatedAt: DateTime.now(),
    version: updatedTask.version + 1,
  );

  // 2. Atualiza local
  await localDataSource.updateTask(taskWithDirtyFlag);

  // 3. Atualiza remote (se online)
  if (await networkInfo.isConnected) {
    await remoteDataSource.updateTask(taskWithDirtyFlag);
  }
  // Se offline, fica na sync queue

  return Right(taskWithDirtyFlag);
}
```

### 4. Delete (Excluir Tarefa)

**Soft Delete:** Padrão (marca como deleted, mantém registro)

```dart
Future<Either<Failure, void>> deleteTask(String taskId) async {
  // 1. Busca tarefa
  final task = await getTaskById(taskId);

  // 2. Marca como deleted
  final deletedTask = task.copyWith(
    isDeleted: true,
    isDirty: true,
    updatedAt: DateTime.now(),
  );

  // 3. Atualiza (não remove fisicamente)
  await localDataSource.updateTask(deletedTask);

  if (await networkInfo.isConnected) {
    await remoteDataSource.updateTask(deletedTask);
  }

  return const Right(null);
}
```

**Hard Delete:** Apenas admin/limpeza (remove fisicamente)

```dart
Future<Either<Failure, void>> hardDeleteTask(String taskId) async {
  await localDataSource.deleteTask(taskId);  // Remove do Hive
  await remoteDataSource.deleteTask(taskId); // Remove do Firebase
  return const Right(null);
}
```

---

## 🤖 Geração Automática de Tarefas

### Quando Ocorre

1. **Ao criar planta** - `GenerateInitialTasksUseCase`
2. **Ao concluir tarefa recorrente** - `CompleteTaskWithRegenerationUseCase`
3. **Ao atualizar configuração de planta** - Regenera tarefas futuras

### Algoritmo de Geração

```dart
// core/services/task_generation_service.dart
class TaskGenerationService {
  List<Task> generateTasksForPlant(Plant plant) {
    final tasks = <Task>[];
    final config = plant.config;
    final now = DateTime.now();

    // 1. Regar (se ativo)
    if (config.wateringIntervalDays > 0) {
      tasks.add(Task(
        id: Uuid().v4(),
        title: 'Regar ${plant.name}',
        plantId: plant.id,
        type: TaskType.watering,
        dueDate: now.add(Duration(days: config.wateringIntervalDays)),
        isRecurring: true,
        recurringIntervalDays: config.wateringIntervalDays,
        priority: TaskPriority.high, // Regar é prioritário
      ));
    }

    // 2. Adubar (se ativo)
    if (config.fertilizingIntervalDays > 0) {
      tasks.add(Task(
        title: 'Adubar ${plant.name}',
        type: TaskType.fertilizing,
        dueDate: now.add(Duration(days: config.fertilizingIntervalDays)),
        // ...
      ));
    }

    // 3. Podar, Banho de Sol, Inspeção de Pragas...
    // (mesmo padrão)

    return tasks;
  }
}
```

### Frequências Padrão

```dart
const defaultIntervals = {
  TaskType.watering: 3,           // A cada 3 dias
  TaskType.fertilizing: 14,       // A cada 2 semanas
  TaskType.pruning: 30,           // A cada mês
  TaskType.repotting: 180,        // A cada 6 meses
  TaskType.sunlight: 1,           // Diariamente
  TaskType.pestInspection: 7,     // Semanalmente
};
```

---

## 🔄 Sistema de Regeneração

### CompleteTaskWithRegenerationUseCase

**Responsabilidades:**
1. Marcar tarefa atual como concluída
2. Calcular próxima data baseado em `recurringIntervalDays`
3. Gerar próxima tarefa automaticamente
4. Manter atomicidade (tudo ou nada)

**Fluxo Completo:**

```dart
// features/tasks/domain/usecases/complete_task_with_regeneration_usecase.dart
Future<Either<Failure, TaskCompletionWithRegenerationResult>> call(
  CompleteTaskWithRegenerationParams params,
) async {
  // 1. Valida parâmetros
  if (params.completionDate.isAfter(DateTime.now().add(Duration(days: 1)))) {
    return Left(ValidationFailure('Data não pode ser > 1 dia no futuro'));
  }

  // 2. Busca tarefa atual
  final currentTask = await tasksRepository.getTaskById(params.taskId);

  // 3. Busca planta (para pegar config)
  final plant = await plantsRepository.getPlantById(currentTask.plantId);

  // 4. Marca como concluída
  final completedTask = currentTask.copyWith(
    status: TaskStatus.completed,
    completedAt: params.completionDate,
    completionNotes: params.notes,
  );
  await tasksRepository.updateTask(completedTask);

  // 5. Gera próxima tarefa (SE recorrente E SE ativo na config)
  Task? nextTask;
  if (currentTask.isRecurring && plant.config.isCareTypeActive(currentTask.type)) {
    nextTask = await _generateNextTask(
      completedTask: completedTask,
      completionDate: params.completionDate,
      plant: plant,
    );
    await tasksRepository.addTask(nextTask);
  }

  // 6. Retorna resultado
  return Right(TaskCompletionWithRegenerationResult(
    completedTask: completedTask,
    nextTask: nextTask,
    regenerationSuccessful: nextTask != null,
  ));
}
```

**Cálculo da Próxima Data:**

```dart
DateTime calculateNextDueDate({
  required DateTime completionDate,
  required int intervalDays,
}) {
  // Adiciona intervalo à data de conclusão
  return completionDate.add(Duration(days: intervalDays));
}

// Exemplo:
// Tarefa: Regar a cada 3 dias
// Conclusão: 07/10/2025 15:30
// Próxima: 10/10/2025 15:30
```

### Validações na Regeneração

```dart
// 1. Data de conclusão não pode ser > 1 dia no futuro
if (completionDate.isAfter(DateTime.now().add(Duration(days: 1)))) {
  throw ValidationFailure('Data inválida');
}

// 2. Data não pode ser > 90 dias no passado
if (completionDate.isBefore(DateTime.now().subtract(Duration(days: 90)))) {
  throw ValidationFailure('Data muito antiga');
}

// 3. Notas não podem ter > 500 caracteres
if (notes != null && notes.length > 500) {
  throw ValidationFailure('Notas muito longas');
}
```

---

## 🔗 Vinculação com Plantas

### Relationship

```
Plant (1) ←──────→ (N) Tasks
  id               plantId (FK)
```

**Quando planta é criada:**

```dart
// Flow: Criar Planta
1. User creates Plant → PlantsRepository.addPlant()
2. Plant saved successfully
3. GenerateInitialTasksUseCase.call(plant.id)
   ↓
   For each active care type in plant.config:
     - Create Task with plantId = plant.id
     - Set dueDate based on interval
     - Set isRecurring = true
     - Save Task
4. Tasks vinculadas à planta criadas ✅
```

**Buscar tarefas de uma planta:**

```dart
final tasks = await tasksRepository.getTasksByPlantId(plantId);

// Firestore query:
users/{userId}/tasks
  .where('plant_id', isEqualTo: plantId)
  .where('is_deleted', isEqualTo: false)
  .orderBy('due_date', ascending: true)
```

---

## 🗑️ Exclusão Cascata

### Quando Planta é Deletada

**Cenário:** Usuário exclui uma planta

**O que deve acontecer com as tarefas?**

**Estratégia Atual:** Soft Delete em Cascata

```dart
// features/plants/domain/usecases/delete_plant_usecase.dart
Future<Either<Failure, void>> deletePlant(String plantId) async {
  // 1. Marca planta como deleted
  await plantsRepository.deletePlant(plantId);

  // 2. Busca todas as tarefas da planta
  final tasksResult = await tasksRepository.getTasksByPlantId(plantId);

  // 3. Marca todas as tarefas como deleted
  for (final task in tasksResult) {
    await tasksRepository.deleteTask(task.id);
  }

  // 4. Cancela notificações agendadas
  await notificationService.cancelNotificationsForPlant(plantId);

  return const Right(null);
}
```

**Desativação de Tarefas (Alternativa):**

```dart
// Em vez de deletar, cancela tarefas futuras
for (final task in pendingTasks) {
  final cancelledTask = task.copyWith(
    status: TaskStatus.cancelled,
    completionNotes: 'Planta removida',
  );
  await tasksRepository.updateTask(cancelledTask);
}
```

### Recuperação

**Se usuário restaura planta deletada:**

```dart
// 1. Restaura planta (isDeleted = false)
await plantsRepository.restorePlant(plantId);

// 2. Restaura tarefas pendentes
final deletedTasks = await tasksRepository.getDeletedTasksByPlantId(plantId);
for (final task in deletedTasks.where((t) => t.status == TaskStatus.pending)) {
  await tasksRepository.restoreTask(task.id);
}

// 3. Reagenda notificações
await notificationService.scheduleNotificationsForPlant(plantId);
```

---

## 🔔 Notificações

### Integração com Sistema de Notificações

```dart
// core/services/task_notification_service.dart
class TaskNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  // Agenda notificação para tarefa
  Future<void> scheduleTaskNotification(Task task) async {
    final scheduledDate = task.dueDate.subtract(Duration(hours: 2)); // 2h antes

    await _notifications.zonedSchedule(
      task.id.hashCode,  // Notification ID
      'Lembrete: ${task.title}',
      task.description ?? 'Hora de cuidar da sua planta!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancela notificação de tarefa
  Future<void> cancelTaskNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }
}
```

### Quando Notificar

```dart
// 1. Ao criar tarefa
onTaskCreated(Task task) {
  if (task.dueDate.isAfter(DateTime.now())) {
    taskNotificationService.scheduleTaskNotification(task);
  }
}

// 2. Ao concluir tarefa (cancela e agenda próxima)
onTaskCompleted(Task completedTask, Task? nextTask) {
  taskNotificationService.cancelTaskNotification(completedTask.id);

  if (nextTask != null) {
    taskNotificationService.scheduleTaskNotification(nextTask);
  }
}

// 3. Ao deletar tarefa
onTaskDeleted(Task task) {
  taskNotificationService.cancelTaskNotification(task.id);
}
```

### Configurações de Notificação

```dart
// Usuário pode controlar:
class NotificationSettings {
  bool taskRemindersEnabled = true;
  int reminderHoursBefore = 2;  // Notificar 2h antes
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  String? customSound;
}
```

---

## 🔄 Sincronização

### Estratégia: Offline-First + Realtime Sync

```
┌─────────────────────────────────────────────────┐
│                    USER ACTION                  │
└──────────────────┬──────────────────────────────┘
                   ↓
         ┌─────────────────────┐
         │  Local First (Hive) │ ← SEMPRE salva local primeiro
         └─────────┬───────────┘
                   ↓
         ┌─────────────────────┐
         │  Check Connectivity │
         └─────────┬───────────┘
                   ↓
            ┌──────┴──────┐
            │             │
         ONLINE        OFFLINE
            │             │
            ↓             ↓
    ┌───────────────┐  ┌─────────────────┐
    │ Sync Firebase │  │ Add to Queue    │
    │   Realtime    │  │ (retry later)   │
    └───────────────┘  └─────────────────┘
```

### Listeners Realtime

```dart
// features/tasks/data/datasources/remote/tasks_remote_datasource.dart
class TasksRemoteDataSourceImpl {
  StreamSubscription? _tasksListener;

  // Ouve mudanças em tempo real
  void listenToTasksChanges(String userId, Function(List<TaskModel>) onTasksChanged) {
    _tasksListener = _firestore
      .collection('users/$userId/tasks')
      .where('is_deleted', isEqualTo: false)
      .snapshots()
      .listen((snapshot) {
        final tasks = snapshot.docs.map((doc) => TaskModel.fromFirebaseMap({
          'id': doc.id,
          ...doc.data(),
        })).toList();

        onTasksChanged(tasks);
      });
  }

  void dispose() {
    _tasksListener?.cancel();
  }
}
```

### Sincronização Bidirecional

**Local → Remote:**

```dart
// Quando usuário cria/edita tarefa offline
1. Salva no Hive com isDirty = true
2. Adiciona à fila de sincronização
3. Quando volta online:
   - Processa fila
   - Envia para Firebase
   - Marca isDirty = false
```

**Remote → Local:**

```dart
// Quando outro dispositivo altera tarefa
1. Firebase snapshot detecta mudança
2. Compara versão local vs remote
3. Se remote.version > local.version:
   - Atualiza Hive com dados do Firebase
   - Notifica UI (via stream)
```

### Conflict Resolution

```dart
// BaseSyncEntity fornece versionamento
class Task extends BaseSyncEntity {
  final int version;
}

// Ao detectar conflito:
if (remoteTask.version > localTask.version) {
  // Remote wins (mais recente)
  await localDataSource.updateTask(remoteTask);
} else if (localTask.isDirty) {
  // Local has unsaved changes, increment version and push
  final updated = localTask.copyWith(version: remoteTask.version + 1);
  await remoteDataSource.updateTask(updated);
}
```

---

## 🔀 Sistema Unificado: PlantTask vs Task

### Contexto Histórico

```
LEGACY:  PlantTask (antigo sistema específico)
CURRENT: Task (sistema genérico unificado)
```

### UnifyPlantTasksUseCase

**Objetivo:** Migrar PlantTasks legadas para o sistema Task unificado

```dart
// features/plants/domain/usecases/unify_plant_tasks_usecase.dart
class UnifyPlantTasksUseCase {
  Future<Either<Failure, UnificationResult>> call(UnifyPlantTasksParams params) async {
    // 1. Carrega dados
    final plantTasks = await plantTasksRepository.getPlantTasks();
    final existingTasks = await tasksRepository.getTasks();
    final plants = await plantsRepository.getPlants();

    // 2. Detecta conflitos
    final conflicts = PlantTaskTaskAdapter.findConflictingTaskIds(
      plantTasks: plantTasks,
      existingTasks: existingTasks,
    );

    if (conflicts.isNotEmpty && !params.forceResolveConflicts) {
      return Right(UnificationResult.conflict(conflicts));
    }

    // 3. Merge (unifica)
    final unifiedTasks = PlantTaskTaskAdapter.mergePlantTasksWithTasks(
      plantTasks: plantTasks,
      existingTasks: existingTasks,
      plantsById: {for (var p in plants) p.id: p},
    );

    // 4. Sincroniza com TasksRepository (se solicitado)
    if (params.syncWithTasksRepository) {
      for (final task in unifiedTasks) {
        await tasksRepository.addTask(task);
      }

      // Marca PlantTasks como migradas
      for (final plantTask in plantTasks) {
        await plantTasksRepository.markAsMigrated(plantTask.id);
      }
    }

    // 5. Gera relatório
    final report = PlantTaskTaskAdapter.generateMigrationReport(
      plantTasks: plantTasks,
      existingTasks: existingTasks,
      plantsById: {for (var p in plants) p.id: p},
    );

    return Right(UnificationResult.success(
      unifiedTasks: unifiedTasks,
      report: report,
    ));
  }
}
```

### PlantTaskTaskAdapter

**Conversão PlantTask → Task:**

```dart
Task plantTaskToTask(PlantTask plantTask, Plant plant) {
  return Task(
    id: plantTask.id,
    title: _generateTitle(plantTask.type, plant.name),
    plantId: plant.id,
    type: _mapPlantTaskTypeToTaskType(plantTask.type),
    dueDate: plantTask.nextDate,
    isRecurring: true,
    recurringIntervalDays: plantTask.intervalDays,
    // ... outros campos mapeados
  );
}
```

---

## 🎨 UI/UX

### Páginas Principais

#### 1. TasksListPage

**Localização:** `features/tasks/presentation/pages/tasks_list_page.dart`

**Layout:**

```
┌────────────────────────────────────────┐
│  Tarefas                        🔍 ⚙️ │
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐ │
│  │  📊 Dashboard                    │ │
│  │  - 5 pendentes                   │ │
│  │  - 2 atrasadas                   │ │
│  │  - 12 concluídas esta semana     │ │
│  └──────────────────────────────────┘ │
├────────────────────────────────────────┤
│  📅 Hoje (2)                          │
│  ┌──────────────────────────────────┐ │
│  │ 💧 Regar Samambaia               │ │
│  │ 15:00 · Prioridade Alta      [✓]│ │
│  └──────────────────────────────────┘ │
│  ┌──────────────────────────────────┐ │
│  │ ☀️ Banho de Sol - Suculenta      │ │
│  │ 09:00 · Prioridade Média     [✓]│ │
│  └──────────────────────────────────┘ │
├────────────────────────────────────────┤
│  ⚠️ Atrasadas (1)                     │
│  ┌──────────────────────────────────┐ │
│  │ 🌱 Adubar Violeta                │ │
│  │ Há 2 dias · URGENTE          [✓]│ │
│  └──────────────────────────────────┘ │
├────────────────────────────────────────┤
│  📆 Próximos 7 dias (3)               │
│  ...                                  │
└────────────────────────────────────────┘
        [+] Criar Tarefa
```

#### 2. Task Completion Dialog

**Quando:** Usuário clica em [✓] para concluir tarefa

```
┌───────────────────────────────────┐
│  Concluir Tarefa                  │
├───────────────────────────────────┤
│  💧 Regar Samambaia               │
│                                   │
│  ✅ Data de conclusão             │
│  [07/10/2025 15:30]               │
│                                   │
│  📝 Observações (opcional)        │
│  ┌─────────────────────────────┐ │
│  │ Regada com 200ml de água    │ │
│  │                             │ │
│  └─────────────────────────────┘ │
│                                   │
│  ℹ️ Próxima tarefa será criada:   │
│  10/10/2025 às 15:30              │
│                                   │
│  [Cancelar]        [Concluir ✓] │
└───────────────────────────────────┘
```

### Widgets Especializados

#### TaskTile

```dart
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(task.status),
      child: ListTile(
        leading: _getTaskIcon(task.type),
        title: Text(task.title),
        subtitle: Text('${_formatDate(task.dueDate)} · ${task.priority.displayName}'),
        trailing: IconButton(
          icon: Icon(Icons.check_circle_outline),
          onPressed: onComplete,
        ),
      ),
    );
  }

  Color _getCardColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.overdue:
        return Colors.red[50];
      case TaskStatus.pending:
        return Colors.blue[50];
      case TaskStatus.completed:
        return Colors.green[50];
      default:
        return Colors.white;
    }
  }
}
```

---

## 📈 Histórico de Tarefas

### TaskHistory Entity

```dart
class TaskHistory {
  final String id;
  final String taskId;
  final String plantId;
  final TaskType type;
  final DateTime completedAt;
  final String? notes;
  final String userId;

  // Métricas
  final Duration? timeTaken;  // Quanto tempo levou
  final bool wasOverdue;      // Foi concluída atrasada?
}
```

### Armazenamento

**Firebase:**

```
users/{userId}/task_history/{historyId}
```

**Hive:**

```
Box: task_history
```

### Analytics

```dart
// Estatísticas por planta
class PlantTaskStatistics {
  int totalTasksCompleted;
  int tasksCompletedOnTime;
  int tasksCompletedLate;
  double averageCompletionTime;  // Em dias
  Map<TaskType, int> tasksByType;

  // Compliance rate
  double get complianceRate => tasksCompletedOnTime / totalTasksCompleted;
}
```

### UI de Histórico

```
┌────────────────────────────────────────┐
│  Histórico - Samambaia                │
├────────────────────────────────────────┤
│  📊 Resumo                             │
│  - 45 tarefas concluídas              │
│  - 92% concluídas no prazo            │
│  - Última: Regar (07/10/2025)         │
├────────────────────────────────────────┤
│  📅 Outubro 2025                       │
│  ┌──────────────────────────────────┐ │
│  │ 07/10 💧 Regar                   │ │
│  │ 15:32 · No prazo                 │ │
│  └──────────────────────────────────┘ │
│  ┌──────────────────────────────────┐ │
│  │ 05/10 🌱 Adubar                  │ │
│  │ 11:20 · 2 dias de atraso         │ │
│  │ "Esqueci no final de semana"     │ │
│  └──────────────────────────────────┘ │
└────────────────────────────────────────┘
```

---

## ✅ Estado da Implementação

### 100% Implementado (Produção)

#### 1. CRUD Completo ✅

- [x] Create - Adicionar tarefas manuais e automáticas
- [x] Read - Listar com múltiplos filtros (status, planta, data)
- [x] Update - Atualizar tarefas existentes
- [x] Delete - Soft delete com sync

**Arquivos:**
- `features/tasks/domain/usecases/add_task_usecase.dart`
- `features/tasks/domain/usecases/get_tasks_usecase.dart`
- `features/tasks/domain/usecases/update_task_usecase.dart`
- `features/tasks/data/repositories/tasks_repository_impl.dart`

#### 2. Geração Automática ao Criar Planta ✅

- [x] Algoritmo de geração baseado em configuração
- [x] Suporte a múltiplos tipos de cuidado
- [x] Intervalos customizáveis
- [x] Tarefas recorrentes automáticas

**Arquivos:**
- `features/tasks/domain/usecases/generate_initial_tasks_usecase.dart`
- `core/services/task_generation_service.dart`

#### 3. Sistema de Regeneração ✅

- [x] CompleteTaskWithRegenerationUseCase implementado
- [x] Cálculo automático de próxima data
- [x] Validações completas
- [x] Atomicidade garantida

**Arquivos:**
- `features/tasks/domain/usecases/complete_task_with_regeneration_usecase.dart` (339 linhas)

#### 4. Sincronização Offline-First ✅

- [x] Local datasource (Hive) funcional
- [x] Remote datasource (Firebase) funcional
- [x] Estratégias adaptativas (Aggressive/Conservative/Minimal)
- [x] Conflict resolution baseado em versão
- [x] Sync queue para offline

**Arquivos:**
- `features/tasks/data/datasources/local/tasks_local_datasource.dart`
- `features/tasks/data/datasources/remote/tasks_remote_datasource.dart`
- `features/tasks/data/repositories/tasks_repository_impl.dart` (598 linhas)

#### 5. UI Completa ✅

- [x] TasksListPage com dashboard
- [x] Task completion dialog
- [x] Task creation dialog
- [x] Filtros e buscas
- [x] Empty states

**Arquivos:**
- `features/tasks/presentation/pages/tasks_list_page.dart`
- `features/tasks/presentation/widgets/` (11 widgets especializados)

### 85% Implementado (Funcional, mas incompleto)

#### 6. Exclusão Cascata ⚠️

**Implementado:**
- [x] Soft delete de tarefas ao deletar planta
- [x] Cancelamento de notificações

**Pendente:**
- [ ] UI de confirmação específica
- [ ] Opção de manter tarefas (em vez de deletar)
- [ ] Restauração de tarefas ao desfazer delete de planta

#### 7. Histórico de Tarefas ⚠️

**Implementado:**
- [x] Entidade TaskHistory definida
- [x] Estrutura de armazenamento

**Pendente:**
- [ ] Use cases completos (salvar histórico ao concluir)
- [ ] Analytics e estatísticas
- [ ] UI de visualização de histórico

#### 8. Sistema Unificado PlantTask→Task ⚠️

**Implementado:**
- [x] UnifyPlantTasksUseCase completo (326 linhas)
- [x] PlantTaskTaskAdapter funcional
- [x] Detecção de conflitos
- [x] Relatório de migração

**Pendente:**
- [ ] Executar migração em produção
- [ ] Deprecar PlantTask completamente
- [ ] Remover código legado

### 70% Implementado (Parcial)

#### 9. Notificações 🟡

**Implementado:**
- [x] Serviço de notificações definido
- [x] Agendamento básico
- [x] Cancelamento de notificações

**Pendente:**
- [ ] Notificações para tarefas atrasadas (diárias)
- [ ] Configurações de notificação (horário preferido)
- [ ] Snooze de notificações
- [ ] Deep linking ao clicar em notificação

**Arquivo:** `core/services/task_notification_service.dart`

### Não Implementado (0%)

#### 10. Templates de Tarefas Predefinidos ❌

**Objetivo:** Biblioteca de tarefas comuns para diferentes tipos de plantas

```dart
class TaskTemplate {
  final String name;  // "Cactos - Baixa manutenção"
  final List<TaskTemplateItem> tasks;
}

const cactusTemplate = TaskTemplate(
  name: 'Cactos',
  tasks: [
    TaskTemplateItem(type: TaskType.watering, intervalDays: 14),
    TaskTemplateItem(type: TaskType.fertilizing, intervalDays: 60),
  ],
);
```

**Estimativa:** 6-8 horas

---

## 🔄 Fluxos Críticos

### Fluxo 1: Criar Planta → Gerar Tarefas

```
User cria planta "Samambaia"
  ↓
PlantsRepository.addPlant()
  ↓ [planta salva com config]
Plant saved successfully
  ↓
GenerateInitialTasksUseCase.call(plantId)
  ↓
For each care type in config:
  ├─ watering (3 dias) → Task criada [dueDate: hoje + 3 dias]
  ├─ fertilizing (14 dias) → Task criada
  ├─ pruning (30 dias) → Task criada
  └─ pestInspection (7 dias) → Task criada
  ↓
4 tarefas criadas e salvas (Hive + Firebase)
  ↓
Notificações agendadas para cada tarefa
  ↓
✅ Planta cadastrada com tarefas automáticas
```

### Fluxo 2: Concluir Tarefa → Regenerar

```
User marca "Regar Samambaia" como concluída (07/10/2025 15:30)
  ↓
CompleteTaskWithRegenerationUseCase.call(taskId, completionDate)
  ↓
1. Busca tarefa atual
   Task(id: task123, type: watering, dueDate: 07/10/2025, recurringIntervalDays: 3)
  ↓
2. Busca planta (para config)
   Plant(id: plant456, config: {...})
  ↓
3. Marca como concluída
   Task(..., status: completed, completedAt: 07/10/2025 15:30)
  ↓
4. Atualiza tarefa no repositório
   ✅ Tarefa salva (Hive + Firebase)
  ↓
5. Verifica se deve regenerar
   ✓ isRecurring = true
   ✓ Config tem wateringIntervalDays = 3
  ↓
6. Gera próxima tarefa
   nextDueDate = 07/10/2025 + 3 dias = 10/10/2025 15:30
   Task(
     id: task789,  // Novo ID
     title: "Regar Samambaia",
     type: watering,
     dueDate: 10/10/2025 15:30,
     recurringIntervalDays: 3,
   )
  ↓
7. Salva próxima tarefa
   ✅ Nova tarefa criada
  ↓
8. Agenda notificação
   📲 Notificação: 10/10/2025 às 13:30 (2h antes)
  ↓
9. Retorna resultado
   TaskCompletionWithRegenerationResult(
     completedTask: task123,
     nextTask: task789,
     regenerationSuccessful: true,
   )
  ↓
✅ Ciclo completo: Concluída + Próxima criada
```

### Fluxo 3: Deletar Planta → Cascata

```
User deleta planta "Violeta" (plant789)
  ↓
DeletePlantUseCase.call(plantId)
  ↓
1. Marca planta como deleted
   Plant(..., isDeleted: true)
  ↓
2. Busca tarefas da planta
   tasks = await tasksRepository.getTasksByPlantId('plant789')
   [task101, task102, task103, task104]  // 4 tarefas
  ↓
3. Para cada tarefa:
   ├─ task101 (pending) → Marca como deleted
   ├─ task102 (pending) → Marca como deleted
   ├─ task103 (completed) → Mantém (histórico)
   └─ task104 (pending) → Marca como deleted
  ↓
4. Cancela notificações
   notificationService.cancelNotificationsForPlant('plant789')
  ↓
5. Sincroniza com Firebase
   ✅ Planta e tarefas marcadas como deleted
  ↓
✅ Planta removida + Tarefas inativadas
```

---

## ❗ Gaps e Pendências

### 🔴 Críticos (Bloqueadores ou Alto Impacto)

#### GAP-001: Histórico não está sendo salvo automaticamente

**Problema:** Ao concluir tarefa, histórico não é gravado

**Impacto:** Alto - Perde dados de compliance e analytics

**Solução:**

```dart
// Adicionar no CompleteTaskWithRegenerationUseCase
Future<void> _saveToHistory(Task completedTask, String? notes) async {
  final history = TaskHistory(
    id: Uuid().v4(),
    taskId: completedTask.id,
    plantId: completedTask.plantId,
    type: completedTask.type,
    completedAt: completedTask.completedAt!,
    notes: notes,
    userId: completedTask.userId,
    wasOverdue: completedTask.status == TaskStatus.overdue,
  );

  await taskHistoryRepository.saveHistory(history);
}
```

**Estimativa:** 4 horas
**Arquivos:** `complete_task_with_regeneration_usecase.dart`, novo repository

#### GAP-002: Notificações não tratam timezone corretamente

**Problema:** Usuários em fusos diferentes recebem notificações no horário errado

**Impacto:** Médio/Alto - UX ruim, notificações inoportunas

**Solução:**

```dart
// Usar flutter_timezone para detectar timezone
import 'package:flutter_timezone/flutter_timezone.dart';

Future<tz.TZDateTime> _getScheduledDateInUserTimezone(DateTime dueDate) async {
  final String timezone = await FlutterTimezone.getLocalTimezone();
  final location = tz.getLocation(timezone);
  return tz.TZDateTime.from(dueDate, location);
}
```

**Estimativa:** 3 horas
**Arquivo:** `task_notification_service.dart:50`

#### GAP-003: Tasks de plantas deletadas aparecem na lista

**Problema:** Filtro `isDeleted` não está sendo aplicado consistentemente

**Impacto:** Alto - Confunde usuário, mostra dados inconsistentes

**Solução:**

```dart
// Garantir filtro em TODAS as queries
Future<List<Task>> getTasks() async {
  final tasks = await localDataSource.getTasks();
  return tasks.where((task) =>
    !task.isDeleted &&
    !await _isPlantDeleted(task.plantId)
  ).toList();
}
```

**Estimativa:** 2 horas
**Arquivos:** `tasks_repository_impl.dart`, `tasks_local_datasource.dart`

### 🟡 Importantes (Melhoram qualidade/UX significativamente)

#### GAP-004: Sem UI para editar tarefas existentes

**Problema:** Usuário não consegue mudar data ou descrição de tarefa criada

**Impacto:** Médio - Limita flexibilidade

**Solução:**

```dart
// Adicionar dialog de edição
class TaskEditDialog extends StatelessWidget {
  final Task task;

  // Permite editar: title, description, dueDate, priority
}

// Adicionar botão de editar no TaskTile
trailing: Row(
  children: [
    IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
    IconButton(icon: Icon(Icons.check), onPressed: onComplete),
  ],
)
```

**Estimativa:** 4-6 horas
**Arquivos:** Novo `task_edit_dialog.dart`

#### GAP-005: Notificações não possuem ações (Concluir/Adiar)

**Problema:** Usuário precisa abrir app para marcar como concluída

**Impacto:** Médio - UX poderia ser melhor

**Solução:**

```dart
// Adicionar actions às notificações
final androidDetails = AndroidNotificationDetails(
  'tasks',
  'Tarefas de Plantas',
  actions: [
    AndroidNotificationAction('complete', 'Concluir'),
    AndroidNotificationAction('snooze', 'Adiar 1h'),
  ],
);

// Handle action
void onNotificationAction(String? action) {
  if (action == 'complete') {
    completeTaskUseCase.call(taskId);
  } else if (action == 'snooze') {
    rescheduleTask(taskId, Duration(hours: 1));
  }
}
```

**Estimativa:** 6-8 horas
**Arquivo:** `task_notification_service.dart`

#### GAP-006: Analytics de compliance não implementado

**Problema:** Usuário não vê estatísticas de cuidados

**Impacto:** Médio - Gamificação e motivação perdidas

**Solução:**

```dart
class TaskAnalyticsUseCase {
  Future<PlantTaskStatistics> getStatistics(String plantId) async {
    final history = await taskHistoryRepository.getHistoryByPlant(plantId);

    return PlantTaskStatistics(
      totalTasksCompleted: history.length,
      tasksCompletedOnTime: history.where((h) => !h.wasOverdue).length,
      complianceRate: // cálculo
      tasksByType: // agrupamento
    );
  }
}
```

**Estimativa:** 8-10 horas
**Arquivos:** Novo use case, UI de analytics

### 🟢 Desejáveis (Nice-to-Have)

#### GAP-007: Templates de tarefas predefinidos

**Problema:** Usuário precisa configurar manualmente para cada tipo de planta

**Solução:** Biblioteca de templates (Cactos, Suculentas, Samambaias, etc)

**Estimativa:** 6-8 horas

---

## 💡 Recomendações

### Performance

1. **Índices Firebase otimizados**

```javascript
// Firestore indexes
{
  collectionGroup: "tasks",
  fields: [
    { fieldPath: "user_id", order: "ASCENDING" },
    { fieldPath: "plant_id", order: "ASCENDING" },
    { fieldPath: "due_date", order: "ASCENDING" },
  ]
}
```

2. **Cache de 5 minutos em memória**

```dart
class TasksLocalDatasourceImpl {
  List<Task>? _cachedTasks;
  DateTime? _cacheTimestamp;
  static const _cacheValidity = Duration(minutes: 5);

  Future<List<Task>> getTasks() async {
    if (_isCacheValid()) return _cachedTasks!;
    // ... fetch from Hive
  }
}
```

3. **Lazy loading para histórico grande**

```dart
Future<List<TaskHistory>> getHistory({
  required String plantId,
  int limit = 20,
  DateTime? startAfter,
}) async {
  // Pagination com cursor
}
```

### UX

1. **Indicador visual de sync**

```dart
// Mostrar ícone quando tarefa está esperando sync
if (task.isDirty) {
  Icon(Icons.cloud_upload, size: 12, color: Colors.orange);
}
```

2. **Undo após exclusão (3 segundos)**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Tarefa excluída'),
    action: SnackBarAction(
      label: 'Desfazer',
      onPressed: () => tasksRepository.restoreTask(taskId),
    ),
    duration: Duration(seconds: 3),
  ),
);
```

3. **Arrastar para concluir (swipe to complete)**

```dart
Dismissible(
  key: Key(task.id),
  direction: DismissDirection.endToStart,
  onDismissed: (_) => _completeTask(task),
  background: Container(
    color: Colors.green,
    child: Icon(Icons.check, color: Colors.white),
  ),
  child: TaskTile(task: task),
)
```

### Segurança

1. **Validação server-side (Cloud Functions)**

```javascript
// Firebase Cloud Function
exports.validateTaskCompletion = functions.firestore
  .document('users/{userId}/tasks/{taskId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();

    // Validar que data de conclusão não é no futuro
    if (after.completed_at > Date.now()) {
      throw new Error('Invalid completion date');
    }
  });
```

2. **Security Rules restritivas**

```javascript
match /users/{userId}/tasks/{taskId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId
               && request.resource.data.user_id == userId;
}
```

### Testes

**Coverage Target:** ≥80% para use cases críticos

```dart
// test/features/tasks/domain/usecases/complete_task_with_regeneration_usecase_test.dart
void main() {
  group('CompleteTaskWithRegenerationUseCase', () {
    test('should complete task and generate next', () async {
      // Arrange
      final params = CompleteTaskWithRegenerationParams(
        taskId: 'task123',
        completionDate: DateTime(2025, 10, 7, 15, 30),
      );

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isRight(), true);
      final value = result.getOrElse(() => throw Exception());
      expect(value.regenerationSuccessful, true);
      expect(value.nextTask, isNotNull);
      expect(value.nextTask!.dueDate, DateTime(2025, 10, 10, 15, 30));
    });

    test('should fail if completion date > 1 day in future', () async {
      // ...
    });

    test('should not regenerate if care type is inactive', () async {
      // ...
    });
  });
}
```

---

## 🗺️ Roadmap

### Fase 1: Estabilização (1-2 semanas)

**Prioridade:** Crítica
**Objetivo:** Corrigir gaps bloqueadores

- [ ] **[GAP-001]** Implementar salvamento de histórico (4h)
- [ ] **[GAP-002]** Corrigir timezone em notificações (3h)
- [ ] **[GAP-003]** Filtrar tarefas de plantas deletadas (2h)
- [ ] Adicionar testes para use cases críticos (8h)
- [ ] Documentação inline de código complexo (4h)

**Estimativa Total:** 21 horas (~3 dias úteis)

### Fase 2: UX Essencial (1 semana)

**Prioridade:** Alta
**Objetivo:** Melhorar experiência básica

- [ ] **[GAP-004]** UI para editar tarefas (6h)
- [ ] **[GAP-005]** Ações em notificações (8h)
- [ ] Indicadores visuais de sync (3h)
- [ ] Undo após exclusão (2h)
- [ ] Swipe to complete (4h)

**Estimativa Total:** 23 horas (~3 dias úteis)

### Fase 3: Analytics e Gamificação (1-2 semanas)

**Prioridade:** Média
**Objetivo:** Aumentar engajamento

- [ ] **[GAP-006]** Analytics de compliance (10h)
- [ ] Dashboard com gráficos (8h)

**Estimativa Total:** 18 horas (~2 dias úteis)

### Fase 4: Recursos Avançados (2-3 semanas)

**Prioridade:** Baixa/Média
**Objetivo:** Diferenciais competitivos

- [ ] **[GAP-007]** Templates predefinidos (8h)
- [ ] AI para sugerir frequências de cuidado (16h)

**Estimativa Total:** 24 horas (~3 dias úteis)

---

## 📝 Atualizações e Tarefas

### Log de Atualizações

#### v1.0 - 07/10/2025
- ✅ Documento inicial criado
- ✅ Análise completa da implementação
- ✅ Identificação de 6 gaps principais
- ✅ Roadmap de 4 fases definido
- ✅ Recomendações de excelência documentadas

---

### Tarefas Prioritárias

#### 🔴 Imediato (Esta Semana)

1. **[TASK-001] Implementar salvamento de histórico**
   - **Estimativa:** 4 horas
   - **Responsável:** TBD
   - **Arquivo:** `complete_task_with_regeneration_usecase.dart`
   - **Critério de Aceite:**
     - [ ] TaskHistory salvo ao concluir tarefa
     - [ ] Dados persistidos em Hive e Firebase
     - [ ] Testes unitários adicionados

2. **[TASK-002] Corrigir timezone em notificações**
   - **Estimativa:** 3 horas
   - **Responsável:** TBD
   - **Arquivo:** `task_notification_service.dart`
   - **Critério de Aceite:**
     - [ ] Notificações no timezone correto do usuário
     - [ ] Testado em múltiplos fusos
     - [ ] Funciona após mudança de fuso

3. **[TASK-003] Filtrar tarefas de plantas deletadas**
   - **Estimativa:** 2 horas
   - **Responsável:** TBD
   - **Arquivos:** `tasks_repository_impl.dart`, datasources
   - **Critério de Aceite:**
     - [ ] Lista não mostra tarefas de plantas deletadas
     - [ ] Filtro aplicado em todas as queries
     - [ ] Testes de integração passando

#### 🟡 Próximas 2 Semanas

4. **[TASK-004] UI para editar tarefas**
   - **Estimativa:** 6 horas
   - **Responsável:** TBD
   - **Deliverable:** `task_edit_dialog.dart`

5. **[TASK-005] Ações em notificações**
   - **Estimativa:** 8 horas
   - **Responsável:** TBD
   - **Features:** Concluir, Adiar diretamente da notificação

6. **[TASK-006] Analytics de compliance**
   - **Estimativa:** 10 horas
   - **Responsável:** TBD
   - **Features:** Estatísticas, gráficos, taxa de compliance

#### 🟢 Backlog (Próximo Mês)

7. **[TASK-007]** Templates de tarefas predefinidos

---

### Métricas de Sucesso

#### KPIs Técnicos

| Métrica | Atual | Meta |
|---------|-------|------|
| Cobertura de testes | ~40% | ≥80% |
| Tempo de carregamento de tarefas | ~300ms | <150ms |
| Taxa de sync bem-sucedida | ~92% | ≥98% |
| Latência de notificações | ~2s | <1s |
| Crashes relacionados a tasks | 3/semana | 0 |

#### KPIs de Produto

| Métrica | Atual | Meta |
|---------|-------|------|
| Taxa de conclusão de tarefas | ~65% | ≥80% |
| Tarefas criadas por usuário | ~8 | ≥15 |
| Retention de 7 dias | ~55% | ≥70% |
| NPS (satisfação) | - | ≥8 |

#### KPIs de Negócio

| Métrica | Atual | Meta |
|---------|-------|------|
| Conversão free→premium via tasks | 0% | ≥5% |
| DAU (Daily Active Users) | - | Monitorar |
| Engagement (tarefas/dia) | ~1.2 | ≥2.5 |

---

## 📚 Referências

### Documentação Oficial

- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Riverpod State Management](https://riverpod.dev/)
- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Arquivos do Projeto

- `features/tasks/domain/usecases/complete_task_with_regeneration_usecase.dart` - Use case crítico (339 linhas)
- `features/tasks/data/repositories/tasks_repository_impl.dart` - Repositório (598 linhas)
- `features/tasks/domain/entities/task.dart` - Entidade principal
- `core/services/task_generation_service.dart` - Algoritmo de geração
- `features/plants/domain/usecases/unify_plant_tasks_usecase.dart` - Unificação (326 linhas)

### Documentos Relacionados

- `sincronia-hive-firebase.md` - Detalhes de sincronização offline-first
- `gerenciamento-dispositivos.md` - Multi-device support
- `implementacao-in-app-purchase.md` - Sistema premium

---

**Documento Vivo:** Este documento será atualizado conforme o sistema evolui.
**Última Atualização:** 07/10/2025
**Próxima Revisão:** 14/10/2025
