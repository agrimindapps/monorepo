# 📊 Análise Comparativa: Taskolist vs Microsoft To Do

**Documento de Planejamento Estratégico**  
**Data:** 17 de Dezembro de 2025  
**Objetivo:** Transformar o Taskolist em um clone funcional do Microsoft To Do

---

## 🎯 Visão Geral

O **Microsoft To Do** é um aplicativo de gerenciamento de tarefas focado em **simplicidade** e **produtividade diária**. Seu diferencial é o conceito de **"Meu Dia"** - um planejador diário que ajuda o usuário a focar no que realmente importa hoje.

### Filosofia do Produto
- **Simplicidade sobre complexidade**
- **Foco diário** (My Day)
- **Personalização visual** (cores, temas)
- **Multiplataforma** com sincronização
- **Gratuito** com recursos premium opcionais

---

## ✅ Estado Atual do Taskolist

### Arquitetura Implementada
- ✅ **Clean Architecture** completa (Presentation/Domain/Data)
- ✅ **Riverpod** para gerenciamento de estado (100% migrado)
- ✅ **Drift (SQLite)** para persistência local
- ✅ **Offline-first** com suporte a sincronização futura
- ✅ **BaseSyncEntity** do core package (versioning, dirty tracking)

### Funcionalidades Já Implementadas

| Feature | Status | Detalhes Técnicos |
|---------|--------|-------------------|
| **CRUD de Tarefas** | ✅ 100% | TaskEntity completo com todos os campos |
| **Estados/Status** | ✅ 100% | `pending`, `inProgress`, `completed`, `cancelled` |
| **Prioridades** | ✅ 100% | `low`, `medium`, `high`, `urgent` |
| **Favoritar** | ✅ 100% | Campo `isStarred` implementado |
| **Notas** | ✅ 100% | Campo `notes` para descrições longas |
| **Data de Vencimento** | ✅ 100% | Campo `dueDate` com helpers (isOverdue, isDueToday) |
| **Data de Lembrete** | ✅ 100% | Campo `reminderDate` (falta implementar notificações) |
| **Tags** | ✅ 100% | Campo `tags: List<String>` |
| **Subtarefas** | ✅ Estrutura | Campo `parentTaskId` (falta UI) |
| **Múltiplas Listas** | ✅ Estrutura | `TaskListEntity` existe, falta CRUD completo |
| **Posicionamento** | ✅ 100% | Campo `position` para ordenação customizada |
| **Soft Delete** | ✅ 100% | Campo `isDeleted` do BaseSyncEntity |
| **Versionamento** | ✅ 100% | Campo `version` para resolução de conflitos |

### Estrutura de Dados Atual

```dart
// TaskEntity (apps/app-taskolist/lib/features/tasks/domain/task_entity.dart)
class TaskEntity extends BaseSyncEntity {
  // Campos de Negócio
  final String title;                    // ✅ Título da tarefa
  final String? description;             // ✅ Descrição detalhada
  final String listId;                   // ✅ ID da lista (TaskList)
  final String createdById;              // ✅ ID do criador
  final String? assignedToId;            // ✅ ID do responsável (futuro)
  final DateTime? dueDate;               // ✅ Data de vencimento
  final DateTime? reminderDate;          // ✅ Data do lembrete
  final TaskStatus status;               // ✅ Estado atual
  final TaskPriority priority;           // ✅ Prioridade
  final bool isStarred;                  // ✅ Favorita
  final int position;                    // ✅ Ordem na lista
  final List<String> tags;               // ✅ Etiquetas
  final String? parentTaskId;            // ✅ Tarefa pai (subtask)
  final String? notes;                   // ✅ Anotações adicionais
  
  // Herdado de BaseSyncEntity
  // - id, createdAt, updatedAt
  // - version, isDirty, isDeleted
  // - lastSyncAt, userId, moduleName
}

// TaskListEntity (apps/app-taskolist/lib/features/tasks/domain/task_list_entity.dart)
class TaskListEntity extends Equatable {
  final String id;                       // ✅ ID único
  final String title;                    // ✅ Nome da lista
  final String? description;             // ✅ Descrição
  final String color;                    // ✅ Cor (hex)
  final String ownerId;                  // ✅ Dono da lista
  final List<String> memberIds;          // ✅ Membros (compartilhamento futuro)
  final DateTime createdAt;              // ✅ Data de criação
  final DateTime updatedAt;              // ✅ Última atualização
  final bool isShared;                   // ✅ Lista compartilhada (futuro)
  final bool isArchived;                 // ✅ Arquivada
  final int position;                    // ✅ Ordem no sidebar
}
```

---

## 🔍 Análise Funcional: Microsoft To Do

### Funcionalidades Core (Essenciais)

#### 1. **Meu Dia (My Day)** 🌟 DIFERENCIAL
**Descrição:**  
Planejador diário que redefine a cada dia. O usuário adiciona manualmente tarefas que quer focar hoje. À meia-noite, a lista é resetada.

**Comportamento:**
- Lista especial "Meu Dia" sempre visível
- Tarefas vencidas/com prazo hoje aparecem como "Sugeridas"
- Usuário clica em "+" para adicionar tarefa ao dia
- Tarefas concluídas saem automaticamente
- Tarefas não concluídas NÃO rolam para o próximo dia (reset manual)

**Dados Necessários:**
```dart
class MyDayTaskEntity {
  final String taskId;           // Referência para TaskEntity
  final DateTime addedAt;        // Quando foi adicionado ao Meu Dia
  final DateTime dayDate;        // Data do dia (para filtrar histórico)
  final bool isCompleted;        // Se foi concluída naquele dia
}
```

**UI/UX:**
- Tela inicial do app
- Header: "Meu Dia - Terça, 17 de dezembro"
- Seção "Sugeridas" (colapsável)
- Lista de tarefas do dia
- FAB para adicionar nova tarefa diretamente ao dia

---

#### 2. **Listas Personalizadas**
**Descrição:**  
Organização por contextos (Trabalho, Casa, Compras, etc). Cada lista tem cor, ícone e pode ser reordenada.

**Funcionalidades:**
- ✅ Criar/Editar/Deletar listas
- ✅ Cores personalizadas (paleta de ~20 cores)
- ✅ Ícones predefinidos (opcional)
- ✅ Reordenar listas (drag-and-drop)
- ✅ Contar tarefas por lista (total / pendentes)
- ✅ Lista padrão "Tarefas" (não pode ser deletada)

**Dados Necessários:**
```dart
// Já temos TaskListEntity, adicionar:
final String? icon;            // Nome do ícone (MaterialIcons)
final int taskCount;           // Total de tarefas (computed)
final int pendingCount;        // Tarefas pendentes (computed)
```

**UI/UX:**
- Sidebar/Drawer com todas as listas
- Card de lista: nome + cor + contador (5)
- Botão "Nova Lista" no rodapé
- Dialog de criação: nome, cor picker, ícone picker
- Menu contextual: editar, arquivar, deletar

---

#### 3. **Tarefas com Etapas (Steps/Subtasks)**
**Descrição:**  
Quebrar tarefas grandes em etapas menores. Mostra progresso (2/5 etapas concluídas).

**Funcionalidades:**
- Adicionar/Remover steps dentro de uma tarefa
- Marcar step como concluída (checkbox)
- Progresso visual (barra ou texto "2 de 5")
- Auto-completar tarefa pai quando todas steps estiverem done (opcional)

**Dados Necessários:**
```dart
// Usar parentTaskId existente
// Subtask é uma TaskEntity com parentTaskId preenchido
// UI diferente: não mostrar certos campos (lista, prioridade herdada)

// Computed properties:
int get completedStepsCount => subtasks.where((s) => s.isCompleted).length;
int get totalStepsCount => subtasks.length;
double get progress => totalStepsCount > 0 ? completedStepsCount / totalStepsCount : 0;
```

**UI/UX:**
- Dentro do detalhe da tarefa, seção "Etapas"
- Lista com checkbox + texto editável
- Botão "+ Adicionar etapa"
- Barra de progresso no card da tarefa (se tem steps)

---

#### 4. **Lembretes e Notificações**
**Descrição:**  
Notificações para não esquecer tarefas. Podem ser únicas ou recorrentes.

**Tipos:**
- **Lembrete Único:** Data + hora específica
- **Lembrete Recorrente:** Repetir (diariamente, semanalmente, etc)
- **Notificação de Vencimento:** Avisar quando tarefa vencer

**Dados Necessários:**
```dart
// Campo já existe: reminderDate
// Adicionar recorrência:
class TaskRecurrence {
  final RecurrenceType type;      // daily, weekly, monthly, yearly, custom
  final int interval;             // a cada X (ex: a cada 2 semanas)
  final List<int>? daysOfWeek;    // para weekly: [1,3,5] (seg, qua, sex)
  final int? dayOfMonth;          // para monthly: dia 15
  final DateTime? endDate;        // parar de repetir após essa data
  final int? occurrences;         // ou após X ocorrências
}

enum RecurrenceType { daily, weekly, monthly, yearly, custom }
```

**Tecnologia:**
- `flutter_local_notifications` para notificações nativas
- `timezone` para agendamento preciso
- Persistir notificações agendadas (sincronizar com tasks)

**UI/UX:**
- Date/Time picker nativo
- Botão "Lembrar-me" na edição da tarefa
- Selector de recorrência: "Diariamente", "Semanalmente", "Mensalmente", "Personalizado"
- Preview: "Repete toda segunda-feira às 09:00"

---

#### 5. **Datas de Vencimento + Recorrência**
**Descrição:**  
Tarefas que se repetem automaticamente após conclusão.

**Exemplos:**
- "Ir à academia" - Repete de segunda a sexta
- "Pagar aluguel" - Repete todo dia 5
- "Reunião semanal" - Repete toda terça às 14h

**Comportamento:**
- Ao marcar como concluída, cria nova instância para próxima data
- Ou: tarefa reabre automaticamente na próxima data
- Editar série: altera todas futuras
- Editar instância: altera só aquela

**Dados Necessários:**
```dart
// Adicionar ao TaskEntity:
final TaskRecurrence? recurrence;
final String? recurrenceParentId;  // ID da tarefa mãe da série
final bool isRecurrenceException;  // Se foi editada individualmente
```

**UI/UX:**
- Ao editar tarefa recorrente: dialog "Editar esta tarefa ou toda a série?"
- Badge visual "🔄" em tarefas recorrentes
- Histórico de ocorrências (opcional)

---

### Funcionalidades Secundárias

#### 6. **Compartilhamento de Listas**
**Descrição:**  
Compartilhar listas com amigos/família/colegas. Todos veem e editam em tempo real.

**Complexidade:** 🔴 ALTA (requer Firebase, autenticação, sync em tempo real)

**Fora do Escopo Inicial:** Monousuário é o foco. Implementar apenas se houver demanda.

---

#### 7. **Anexar Arquivos**
**Descrição:**  
Adicionar fotos, PDFs, links a uma tarefa.

**Complexidade:** 🟡 MÉDIA

**Implementação Futura:**
- Storage local para arquivos pequenos (<5MB)
- Ou Firebase Storage para cloud
- Visualizador integrado de imagens/PDFs

---

#### 8. **Temas e Personalização**
**Descrição:**  
Tema claro, escuro, cores de acento.

**Status:** ✅ Estrutura existe (`theme_provider.dart`)

**Falta Implementar:**
- Persistir escolha do tema
- Cores de acento personalizadas
- Wallpapers/backgrounds (opcional)

---

#### 9. **Estatísticas e Produtividade**
**Descrição:**  
Gráficos de tarefas concluídas, streaks, metas.

**Complexidade:** 🟡 MÉDIA

**Exemplos:**
- "Você concluiu 47 tarefas esta semana!"
- Streak: "15 dias consecutivos completando Meu Dia"
- Gráfico de produtividade por lista

---

## 🗺️ Roadmap de Desenvolvimento

### FASE 1: Fundação da Experiência (2 semanas) 🔴 PRIORIDADE ALTA

#### Sprint 1.1: Meu Dia (3-5 dias)
**Objetivo:** Implementar o planejador diário.

**Tarefas:**
- [ ] Criar `MyDayTaskEntity` e model Drift
- [ ] Criar `MyDayRepository` (add, remove, listToday, reset)
- [ ] Criar `MyDayNotifier` (Riverpod)
- [ ] Criar `MyDayPage` (UI completa)
- [ ] Implementar "Tarefas Sugeridas" (vencidas + com prazo hoje)
- [ ] Job de reset à meia-noite (background task)
- [ ] Testes unitários dos use cases

**Critérios de Aceite:**
- [x] Tela "Meu Dia" é a inicial do app
- [x] Adicionar/remover tarefas do dia com um toque
- [x] Sugestões aparecem automaticamente
- [x] Reset funciona à meia-noite
- [x] Contador "X tarefas pendentes"

---

#### Sprint 1.2: Sistema de Listas Completo (2-3 dias)
**Objetivo:** CRUD completo de listas com personalização.

**Tarefas:**
- [ ] Implementar `TaskListRepository` (CRUD completo)
- [ ] Criar `TaskListNotifier` (Riverpod)
- [ ] UI: Sidebar com lista de listas
- [ ] UI: Dialog de criar/editar lista (nome, cor, ícone)
- [ ] Color picker (paleta predefinida)
- [ ] Icon picker (grid de ícones Material)
- [ ] Reordenar listas (drag-and-drop com `reorderable_list`)
- [ ] Contador de tarefas por lista (badge)
- [ ] Lista padrão "Tarefas" (não deletável)
- [ ] Arquivar listas (isArchived)

**Critérios de Aceite:**
- [x] Criar nova lista em <5 toques
- [x] Mudar cor de lista e ver refletido imediatamente
- [x] Reordenar listas e persistir ordem
- [x] Ver contador de tarefas (5 pendentes / 12 total)
- [x] Arquivar lista move para seção separada

---

### FASE 2: Produtividade Avançada (3 semanas) 🟡 PRIORIDADE MÉDIA

#### Sprint 2.1: Subtarefas (Steps) (2-3 dias)
**Tarefas:**
- [ ] UI para adicionar steps dentro do detalhe da tarefa
- [ ] Lista de steps com checkbox (marcar como concluída)
- [ ] Campo de texto inline para editar step
- [ ] Deletar step (swipe)
- [ ] Barra de progresso no card da tarefa (se tem steps)
- [ ] Auto-completar tarefa pai (configuração opcional)
- [ ] Reordenar steps

**Critérios de Aceite:**
- [x] Adicionar step em 2 toques
- [x] Progresso visual "3/5 etapas"
- [x] Tarefa pai completa automaticamente quando steps finalizarem

---

#### Sprint 2.2: Notificações e Lembretes (4-6 dias)
**Tarefas:**
- [ ] Integrar `flutter_local_notifications`
- [ ] Configurar permissões (Android/iOS)
- [ ] Implementar agendamento de notificação única
- [ ] UI: Date/Time picker para lembrete
- [ ] Notificação ao vencer tarefa (opcional)
- [ ] Snooze de notificações (adiar 10min, 1h)
- [ ] Badge count no ícone do app
- [ ] Testes de notificação

**Critérios de Aceite:**
- [x] Receber notificação na hora exata
- [x] Tocar na notificação abre a tarefa
- [x] Snooze funciona e reagenda
- [x] Badge mostra tarefas pendentes de hoje

---

#### Sprint 2.3: Recorrência de Tarefas (5-7 dias)
**Tarefas:**
- [ ] Criar `TaskRecurrence` entity
- [ ] Implementar lógica de cálculo de próxima data
- [ ] UI: Selector de recorrência (diária, semanal, mensal, customizada)
- [ ] Preview de recorrência ("Repete toda segunda-feira")
- [ ] Criar nova instância ao completar tarefa recorrente
- [ ] Editar série vs editar instância (dialog)
- [ ] Badge visual "🔄" em tarefas recorrentes
- [ ] Testes de cálculo de datas

**Critérios de Aceite:**
- [x] Criar tarefa "Academia" que repete seg-sex
- [x] Ao completar hoje, cria nova para amanhã
- [x] Editar série altera todas futuras
- [x] Editar instância afeta só aquela

---

### FASE 3: Polimento Visual (1 semana) 🎨

#### Sprint 3.1: UI/UX Microsoft To Do Style (3-4 dias)
**Tarefas:**
- [ ] Tema claro + escuro (persistir escolha)
- [ ] Animações de conclusão (check animado)
- [ ] Swipe actions (completar, deletar, adiar)
- [ ] Transições de página suaves
- [ ] Skeleton loaders
- [ ] Empty states ilustrados
- [ ] Feedback visual (haptic, ripple)
- [ ] Ícones Fluent Design (similaridade visual)

**Critérios de Aceite:**
- [x] App parece "profissional" e moderno
- [x] Tema escuro funciona perfeitamente
- [x] Animações são fluidas (60fps)
- [x] Gestos são intuitivos

---

### FASE 4: Features Premium (Futuro) 🟢 PRIORIDADE BAIXA

#### 4.1 Anexar Arquivos (4-5 dias)
- Implementar quando houver demanda real

#### 4.2 Compartilhamento/Colaboração (10-15 dias)
- Fora do escopo monousuário inicial
- Considerar apenas se app ganhar tração

#### 4.3 Sincronização Cloud (7-10 dias)
- Firebase Firestore para backup
- Estrutura `BaseSyncEntity` já suporta
- Implementar quando necessário multiplataforma

---

## 📐 Especificações Técnicas

### Stack Tecnológica

| Categoria | Tecnologia | Versão | Justificativa |
|-----------|-----------|--------|---------------|
| **Framework** | Flutter | 3.24+ | UI nativa, performance |
| **Estado** | Riverpod | 3.x | Reativo, testável, type-safe |
| **Banco Local** | Drift (SQLite) | 2.x | Offline-first, queries tipadas |
| **Notificações** | flutter_local_notifications | 17.x | Suporte Android/iOS/Web |
| **Timezone** | timezone | 0.9.x | Agendamento preciso |
| **Funcional** | dartz | 0.10.x | Either, Option |
| **DI** | GetIt | 7.x | Service locator |
| **UUID** | uuid | 4.x | IDs únicos |

### Estrutura de Pastas (Expandida)

```
lib/
├── core/
│   ├── database/
│   │   └── drift_database.dart           # Configuração Drift
│   ├── di/
│   │   └── injection.dart                # GetIt setup
│   ├── errors/
│   │   └── failures.dart                 # Either<Failure, T>
│   └── utils/
│       └── date_helpers.dart             # Funções de data
├── features/
│   ├── tasks/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── task_entity.dart
│   │   │   │   ├── task_list_entity.dart
│   │   │   │   ├── task_recurrence.dart      # 🆕 NOVO
│   │   │   │   └── my_day_task_entity.dart   # 🆕 NOVO
│   │   │   ├── repositories/
│   │   │   │   ├── task_repository.dart
│   │   │   │   ├── task_list_repository.dart
│   │   │   │   └── my_day_repository.dart    # 🆕 NOVO
│   │   │   └── usecases/
│   │   │       ├── create_task.dart
│   │   │       ├── add_task_to_my_day.dart   # 🆕 NOVO
│   │   │       ├── get_my_day_tasks.dart     # 🆕 NOVO
│   │   │       └── schedule_reminder.dart    # 🆕 NOVO
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── task_model.dart
│   │   │   │   ├── task_list_model.dart
│   │   │   │   └── my_day_task_model.dart    # 🆕 NOVO
│   │   │   ├── datasources/
│   │   │   │   └── task_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── task_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── my_day_page.dart          # 🆕 NOVO
│   │       │   ├── task_lists_page.dart      # 🆕 NOVO
│   │       │   ├── task_detail_page.dart
│   │       │   └── home_page.dart
│   │       ├── widgets/
│   │       │   ├── task_card.dart
│   │       │   ├── task_list_selector.dart   # 🆕 NOVO
│   │       │   ├── color_picker.dart         # 🆕 NOVO
│   │       │   ├── recurrence_picker.dart    # 🆕 NOVO
│   │       │   └── step_list.dart            # 🆕 NOVO
│   │       └── providers/
│   │           ├── task_notifier.dart
│   │           ├── my_day_notifier.dart      # 🆕 NOVO
│   │           └── task_list_notifier.dart   # 🆕 NOVO
│   ├── notifications/
│   │   ├── domain/
│   │   │   └── notification_service.dart     # 🆕 NOVO
│   │   ├── data/
│   │   │   └── notification_service_impl.dart # 🆕 NOVO
│   │   └── presentation/
│   │       └── notification_settings_page.dart # 🆕 NOVO
│   └── settings/
│       └── ...
└── main.dart
```

---

## 🎨 Design System

### Paleta de Cores (Inspirada no Microsoft To Do)

```dart
// Cores para Listas (20 opções)
class ListColors {
  static const Color blue = Color(0xFF2196F3);        // Azul padrão
  static const Color red = Color(0xFFF44336);         // Vermelho
  static const Color green = Color(0xFF4CAF50);       // Verde
  static const Color orange = Color(0xFFF F9800);     // Laranja
  static const Color purple = Color(0xFF9C27B0);      // Roxo
  static const Color teal = Color(0xFF009688);        // Azul-verde
  static const Color pink = Color(0xFFE91E63);        // Rosa
  static const Color indigo = Color(0xFF3F51B5);      // Índigo
  static const Color yellow = Color(0xFFFFEB3B);      // Amarelo
  static const Color lime = Color(0xFFCDDC39);        // Lima
  static const Color cyan = Color(0xFF00BCD4);        // Ciano
  static const Color amber = Color(0xFFFFC107);       // Âmbar
  static const Color deepOrange = Color(0xFFFF5722);  // Laranja escuro
  static const Color lightBlue = Color(0xFF03A9F4);   // Azul claro
  static const Color lightGreen = Color(0xFF8BC34A);  // Verde claro
  static const Color deepPurple = Color(0xFF673AB7);  // Roxo escuro
  static const Color brown = Color(0xFF795548);       // Marrom
  static const Color blueGrey = Color(0xFF607D8B);    // Azul acinzentado
  static const Color grey = Color(0xFF9E9E9E);        // Cinza
  static const Color black = Color(0xFF212121);       // Preto
}
```

### Componentes de UI

#### Task Card
```dart
// Exibição compacta de tarefa
TaskCard(
  title: "Comprar leite",
  isCompleted: false,
  priority: TaskPriority.high,
  dueDate: DateTime.now(),
  hasSteps: true,
  stepsProgress: "2/5",
  isRecurring: true,
  onTap: () => openDetails(),
  onComplete: () => markComplete(),
  onSwipeDelete: () => delete(),
);
```

#### My Day Header
```dart
// Header da página Meu Dia
MyDayHeader(
  date: DateTime.now(),
  taskCount: 5,
  completedCount: 2,
  userName: "João",
);
// Resultado: "Bom dia, João! • Terça, 17 de dezembro • 2 de 5 concluídas"
```

#### Color Picker
```dart
// Seletor de cor para lista
ColorPicker(
  selectedColor: Colors.blue,
  colors: ListColors.all,
  onColorSelected: (color) => updateListColor(color),
);
```

### Animações

| Elemento | Animação | Duração |
|----------|----------|---------|
| **Completar Tarefa** | Check animado + fade out | 300ms |
| **Adicionar Tarefa** | Slide from bottom + fade in | 250ms |
| **Deletar Tarefa** | Swipe + slide out | 200ms |
| **Expandir Steps** | Height animation + opacity | 300ms |
| **Transição de Página** | Slide horizontal | 300ms |

---

## 🧪 Estratégia de Testes

### Cobertura Mínima

| Camada | Cobertura | Foco |
|--------|-----------|------|
| **Domain (Use Cases)** | 90%+ | Lógica de negócio crítica |
| **Data (Repositories)** | 80%+ | Persistência e conversões |
| **Presentation (UI)** | 50%+ | Widgets complexos |

### Casos de Teste Prioritários

#### Meu Dia
- [x] Adicionar tarefa ao Meu Dia
- [x] Remover tarefa do Meu Dia
- [x] Listar tarefas de hoje
- [x] Tarefas sugeridas aparecem corretamente
- [x] Reset à meia-noite limpa a lista

#### Recorrência
- [x] Calcular próxima data (diária, semanal, mensal)
- [x] Criar nova instância ao completar tarefa recorrente
- [x] Editar série vs editar instância
- [x] Parar recorrência após N ocorrências

#### Notificações
- [x] Agendar notificação única
- [x] Cancelar notificação ao deletar tarefa
- [x] Reagendar ao editar data de lembrete

---

## 📊 Métricas de Sucesso

### KPIs do Produto

| Métrica | Meta | Como Medir |
|---------|------|------------|
| **Engajamento Diário** | 60%+ usuários abrem "Meu Dia" | Analytics |
| **Tarefas Completadas/Dia** | Média de 5+ por usuário ativo | Database query |
| **Retenção 7 dias** | 40%+ | Analytics |
| **Tempo de Carregamento** | < 1s para abrir app | Performance monitoring |
| **Crash Rate** | < 0.5% | Crashlytics |

### Benchmarks Técnicos

| Métrica | Alvo | Status Atual |
|---------|------|--------------|
| **Análise de Código** | 0 erros, < 10 warnings | 41 warnings (Result deprecated) |
| **Build Time** | < 3 min (release) | - |
| **App Size** | < 20 MB (Android) | - |
| **FPS** | 60 fps constante | - |

---

## 🚧 Riscos e Mitigações

### Riscos Técnicos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| **Notificações não funcionam no iOS** | Média | Alto | Testar early, fallback para in-app alerts |
| **Performance com muitas tasks** | Baixa | Médio | Paginação, lazy loading |
| **Conflitos de sincronização** | Média | Alto | Já temos version/isDirty do BaseSyncEntity |
| **Recorrência complexa quebrando** | Alta | Médio | Testes exaustivos, edge cases documentados |

### Riscos de Produto

| Risco | Mitigação |
|-------|-----------|
| **Feature creep** (adicionar demais) | Seguir roadmap, validar com usuários |
| **UX confusa** | User testing, iterações rápidas |
| **Baixa adoção** | Lançamento beta, feedback contínuo |

---

## 📚 Referências

### Documentação Técnica
- [Microsoft To Do - Documentação Oficial](https://support.microsoft.com/pt-br/office/microsoft-to-do)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Riverpod Documentation](https://riverpod.dev/)

### Inspiração de Design
- [Microsoft To Do - Design Guidelines](https://www.microsoft.com/design/fluent/)
- [Material Design 3](https://m3.material.io/)

### Competidores
- **Microsoft To Do** - Referência principal
- **Todoist** - Recorrência avançada
- **TickTick** - Pomodoro, hábitos
- **Google Tasks** - Simplicidade extrema

---

## 📝 Notas de Desenvolvimento

### Decisões Arquiteturais

#### 1. Por que Drift em vez de Hive?
- **Resposta:** Drift oferece queries tipadas, migrações automáticas e melhor performance com grandes volumes de dados.

#### 2. Por que não usar Firebase desde o início?
- **Resposta:** Offline-first é prioridade. Firebase será adicionado apenas para backup/sync opcional.

#### 3. Como garantir reset do "Meu Dia" à meia-noite?
- **Resposta:** Background task com `workmanager` (Android) e `BackgroundTasks` (iOS). Fallback: checar timestamp ao abrir app.

#### 4. Recorrência: criar nova task ou reutilizar?
- **Resposta:** Criar nova instância mantém histórico. Alternativa: soft-reset (reabre a mesma task).

### Convenções de Código

```dart
// Nomenclatura
// - Entities: sufixo Entity (TaskEntity)
// - Models: sufixo Model (TaskModel)
// - Providers: sufixo Notifier (TaskNotifier)
// - Pages: sufixo Page (MyDayPage)
// - Use Cases: verbo + substantivo (GetMyDayTasks)

// Estrutura de Provider
@riverpod
class MyDayNotifier extends _$MyDayNotifier {
  @override
  Future<List<TaskEntity>> build() async {
    return await _loadMyDayTasks();
  }
  
  Future<void> addTaskToMyDay(String taskId) async {
    // Lógica
    ref.invalidateSelf(); // Recarregar
  }
}

// Either para erros
Either<Failure, TaskEntity> result = await createTask(task);
result.fold(
  (failure) => showError(failure.message),
  (task) => showSuccess(),
);
```

---

## ✅ Checklist de Implementação

### Antes de Começar Cada Feature
- [ ] Ler documentação desta análise
- [ ] Criar branch feature/nome-feature
- [ ] Escrever testes primeiro (TDD)
- [ ] Implementar camada Domain
- [ ] Implementar camada Data
- [ ] Implementar camada Presentation
- [ ] Testar manualmente (happy path + edge cases)
- [ ] Revisar código (linter, analyzer)
- [ ] Atualizar documentação
- [ ] Merge para develop

### Antes de Lançar Versão
- [ ] Todos os testes passando
- [ ] 0 erros no analyzer
- [ ] < 10 warnings
- [ ] Performance testada (devtools)
- [ ] Funciona offline
- [ ] Backup/restauração testado
- [ ] README.md atualizado
- [ ] CHANGELOG.md atualizado
- [ ] Screenshots atualizadas

---

## 🎯 Próximo Passo Imediato

**RECOMENDAÇÃO:** Começar pela **Feature "Meu Dia"**

**Motivos:**
1. É o diferencial do Microsoft To Do
2. Aumenta engajamento diário massivamente
3. Tecnicamente mais simples que notificações
4. Usa estrutura existente (apenas filtra/agrupa tarefas)
5. Entrega valor imediato ao usuário

**Estimativa:** 3-5 dias (20-30h de desenvolvimento)

**Preparação:**
1. Criar documento detalhado da feature "Meu Dia"
2. Definir schema do banco (MyDayTask table)
3. Escrever testes unitários dos use cases
4. Criar mockups da UI (Figma/Sketch)

---

**Documento criado por:** Análise AI  
**Data:** 17/12/2025  
**Versão:** 1.0  
**Status:** 📘 Planejamento Completo - Pronto para Execução
