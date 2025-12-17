# Listas Coloridas - Implementação

## 📋 Status: ✅ 95% IMPLEMENTADO - Em Integração

**Última atualização**: 17/12/2024

## 🎯 Objetivo
Permitir que os usuários escolham cores para suas listas de tarefas, facilitando a organização visual e identificação rápida.

## 🏗️ Arquitetura Atualizada

### 1. Core - Paleta de Cores
**Arquivo**: `lib/shared/constants/task_list_colors.dart`

Classe central que gerencia todas as cores disponíveis:
- **12 cores pré-definidas** (Azul, Verde, Vermelho, Roxo, Laranja, Rosa, Ciano, Índigo, Lima, Âmbar, Marrom, Cinza)
- Estrutura `TaskListColorOption` com nome, valor hex e Color
- Métodos helper: `fromHex()`, `getOptionByValue()`
- Cor padrão: `#2196F3` (Azul)

### 2. Data Layer - Firebase & Repository

#### TaskListModel
**Arquivo**: `lib/features/tasks/data/task_list_model.dart`
- Conversão de/para Firestore
- Suporte a campo `color` (String hex)
- Factory methods: `fromFirestore()`, `fromMap()`, `fromEntity()`

#### TaskListFirebaseDatasource
**Arquivo**: `lib/features/tasks/data/task_list_firebase_datasource_impl.dart`
- CRUD completo para listas no Firestore
- Stream de listas em tempo real
- Filtros por usuário (owner/member), arquivadas
- Ordenação por position + createdAt

#### TaskListRepository
**Arquivo**: `lib/features/tasks/data/task_list_repository_impl.dart`
- Implementa padrão Either (dartz) para error handling
- Converte exceptions em Failures

### 3. State Management - Riverpod

**Arquivo**: `lib/features/task_lists/providers/task_list_providers.dart`

Providers implementados:
- `taskListsProvider` - Stream de listas ativas
- `archivedTaskListsProvider` - Stream de listas arquivadas  
- `taskListByIdProvider` - Busca lista específica
- `createTaskListProvider` - Notifier para criar lista
- `updateTaskListProvider` - Notifier para atualizar lista
- `deleteTaskListProvider` - Notifier para deletar lista
- `shareTaskListProvider` - Notifier para compartilhar lista
- `archiveTaskListProvider` - Notifier para arquivar lista

### 4. Widgets de UI

#### ColorPicker
**Arquivo**: `lib/shared/widgets/color_picker.dart`

Widget Wrap com grid de cores:
- Círculos de 48x48 com as 12 cores disponíveis
- Indicador visual da cor selecionada (check icon + border + shadow)
- Callback `onColorSelected(String hexColor)`

**Uso**:
```dart
ColorPicker(
  selectedColor: _selectedColor,
  onColorSelected: (color) {
    setState(() => _selectedColor = color);
  },
)
```

#### CreateEditTaskListPage
**Arquivo**: `lib/features/task_lists/presentation/create_edit_task_list_page.dart`

Página completa para criar/editar listas:
- Campo título (obrigatório, max 50 chars)
- Campo descrição (opcional, max 200 chars)
- Seletor de cor (ColorPicker)
- Preview em tempo real com cor selecionada
- Validação e feedback visual
- Integração com providers Riverpod
- Loading states

## 🔗 Integração com Entidade

A entidade `TaskListEntity` já possui o campo `color`:
```dart
class TaskListEntity {
  final String color; // Key da cor (ex: 'blue', 'red')
  // ...
}
```

## 📝 Próximos Passos

### ✅ CONCLUÍDO
- [x] Criar paleta de cores centralizada (`TaskListColors`)
- [x] Criar widget de seleção (`ColorPicker`)
- [x] Criar TaskListModel com suporte a cor
- [x] Implementar TaskListFirebaseDatasource completo
- [x] Implementar TaskListRepository com Either
- [x] Criar providers Riverpod (CRUD + Streams)
- [x] Criar CreateEditTaskListPage completa
- [x] Preview em tempo real da cor selecionada
- [x] Documentar implementação

### 🔄 EM ANDAMENTO

#### 1. Integração com Navegação
- [ ] Adicionar rota para CreateEditTaskListPage
- [ ] Adicionar botão FAB na home para criar lista
- [ ] Implementar navegação do drawer/sidebar

#### 2. Exibir Listas com Cores
- [ ] Criar TaskListsPage para exibir todas as listas
- [ ] Criar TaskListCard com indicador de cor
- [ ] Adicionar cor no cabeçalho de detalhes da lista
- [ ] Mostrar cor nas tarefas (badge com cor da lista)

#### 3. Melhorias UX
- [ ] Animação ao selecionar cor
- [ ] Confirmação antes de deletar lista
- [ ] Pull-to-refresh nas listas
- [ ] Empty states

### 🎯 ROADMAP

#### Fase 2: Recursos Avançados
- [ ] Compartilhamento de listas (share_task_list)
- [ ] Gerenciar membros compartilhados
- [ ] Notificações de listas compartilhadas
- [ ] Arquivar/desarquivar listas

#### Fase 3: Personalização
- [ ] Permitir cores customizadas (color picker completo)
- [ ] Salvar paleta de cores favoritas do usuário
- [ ] Temas de cores (preset de paletas)
- [ ] Ícones personalizados para listas

## 🎨 Paleta de Cores Disponível

| Cor     | Nome PT   | Hex     | Color Code    |
|---------|-----------|---------|---------------|
| 🔵 Blue | Azul      | #2196F3 | Color(0xFF2196F3) |
| 🟢 Green| Verde     | #4CAF50 | Color(0xFF4CAF50) |
| 🔴 Red  | Vermelho  | #F44336 | Color(0xFFF44336) |
| 🟣 Purple | Roxo    | #9C27B0 | Color(0xFF9C27B0) |
| 🟠 Orange | Laranja | #FF9800 | Color(0xFFFF9800) |
| 🌸 Pink | Rosa      | #E91E63 | Color(0xFFE91E63) |
| 🔷 Cyan | Ciano     | #00BCD4 | Color(0xFF00BCD4) |
| 🔹 Indigo | Índigo  | #3F51B5 | Color(0xFF3F51B5) |
| 💛 Yellow | Lima    | #CDDC39 | Color(0xFFCDDC39) |
| 🟡 Amber | Âmbar    | #FFC107 | Color(0xFFFFC107) |
| 🟤 Brown | Marrom   | #795548 | Color(0xFF795548) |
| ⚫ Grey | Cinza     | #9E9E9E | Color(0xFF9E9E9E) |

## 💡 Exemplos de Uso

### Criar Lista com Cor
```dart
final newList = TaskListEntity(
  id: const Uuid().v4(),
  title: 'Trabalho',
  color: '#2196F3', // Usa hex string
  ownerId: currentUserId,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Via provider
final listId = await ref.read(createTaskListProvider.notifier).call(newList);
```

### Atualizar Cor da Lista
```dart
final updatedList = existingList.copyWith(
  color: '#4CAF50', // Muda para verde
  updatedAt: DateTime.now(),
);

await ref.read(updateTaskListProvider.notifier).call(updatedList);
```

### Exibir Listas com Stream
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final listsAsync = ref.watch(taskListsProvider);

  return listsAsync.when(
    data: (lists) => ListView.builder(
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return ListTile(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: TaskListColors.fromHex(list.color),
              shape: BoxShape.circle,
            ),
          ),
          title: Text(list.title),
          // ...
        );
      },
    ),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => Text('Erro: $err'),
  );
}
```

### Buscar Lista Específica
```dart
final listAsync = ref.watch(taskListByIdProvider('list-id-123'));

listAsync.when(
  data: (list) => list != null ? Text(list.title) : Text('Not found'),
  loading: () => CircularProgressIndicator(),
  error: (err, _) => Text('Error'),
);
```

## 🔧 Customização

Para adicionar mais cores, edite `lib/shared/constants/task_list_colors.dart`:
```dart
static const List<TaskListColorOption> options = [
  // ... cores existentes
  TaskListColorOption(
    name: 'Turquesa',
    value: '#1ABC9C',
    color: Color(0xFF1ABC9C),
  ),
];
```

## 🏗️ Arquivos Criados/Modificados

### Novos Arquivos
1. `lib/shared/constants/task_list_colors.dart` - Paleta de cores
2. `lib/shared/widgets/color_picker.dart` - Widget seletor
3. `lib/features/tasks/data/task_list_model.dart` - Model
4. `lib/features/tasks/data/task_list_firebase_datasource.dart` - Interface
5. `lib/features/tasks/data/task_list_firebase_datasource_impl.dart` - Implementação
6. `lib/features/tasks/data/task_list_repository_impl.dart` - Repository
7. `lib/features/task_lists/providers/task_list_providers.dart` - State management
8. `lib/features/task_lists/presentation/create_edit_task_list_page.dart` - UI

### Arquivos Existentes (já tinham estrutura)
- `lib/features/tasks/domain/task_list_entity.dart` - Já tinha campo `color`
- `lib/features/tasks/domain/task_list_repository.dart` - Interface já existia

## 🧪 Testes Necessários

### Unit Tests
- [ ] `TaskListColors.fromHex()` - conversão hex para Color
- [ ] `TaskListColors.getOptionByValue()` - busca por valor
- [ ] `TaskListModel.fromFirestore()` - parsing Firestore
- [ ] `TaskListModel.toMap()` - conversão para Map

### Integration Tests  
- [ ] Criar lista com cor no Firestore
- [ ] Atualizar cor de lista existente
- [ ] Stream de listas retorna cores corretas
- [ ] Deletar lista remove do Firestore

### Widget Tests
- [ ] `ColorPicker` renderiza 12 cores
- [ ] `ColorPicker` marca cor selecionada
- [ ] `ColorPicker` chama callback ao clicar
- [ ] `CreateEditTaskListPage` salva cor selecionada

## 📊 Performance

### Otimizações Implementadas
- ✅ Cores definidas como `const` (zero overhead)
- ✅ Stream do Firestore com filtros no servidor
- ✅ Providers Riverpod com cache automático
- ✅ Widget ColorPicker com Wrap (layout eficiente)

### Considerações
- Firestore query com compound index (ownerId/memberIds + isArchived + position)
- Stream rebuilds apenas quando dados mudam (Riverpod)
- Color parsing acontece apenas uma vez (const values)

## 📚 Referências
- Microsoft To Do: Usa cores para categorizar listas
- Wunderlist (legado): Sistema de cores similar
- Material Design: Paleta de cores base
