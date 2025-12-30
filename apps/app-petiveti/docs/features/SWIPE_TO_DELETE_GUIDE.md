# Guia de Uso: Swipe-to-Delete com Undo

## 📋 Visão Geral

O sistema de **Swipe-to-Delete** implementado no app-petiveti permite que usuários excluam itens de listas deslizando para a esquerda, com a possibilidade de desfazer a ação por 5 segundos.

### Benefícios
- ✅ **UX Superior**: Remove da UI imediatamente (sem esperar backend)
- ✅ **Segurança**: Permite desfazer por 5 segundos
- ✅ **Performance**: Otimização via delete otimista
- ✅ **Feedback Visual**: Background vermelho com ícone de lixeira
- ✅ **Consistência**: Padrão único em todo o app

---

## 🏗️ Arquitetura

### Componentes Criados

1. **`SwipeToDeleteWrapper`** (`lib/core/widgets/swipe_to_delete_wrapper.dart`)
   - Widget reutilizável que envolve itens de lista
   - Gerencia o Dismissible e SnackBar
   - Trigger: Swipe para a esquerda (endToStart)
   - Threshold: 40% da largura

2. **`OptimisticDeleteMixin`** (`lib/core/mixins/optimistic_delete_mixin.dart`)
   - Mixin para Riverpod Notifiers
   - Gerencia cache de itens deletados
   - Timer automático de 5 segundos
   - Métodos de restore e flush

3. **Extensão `SwipeToDeleteWrapperX`**
   - Extension method `.withSwipeToDelete()` para facilitar uso
   - Sintaxe fluente

---

## 🚀 Uso em Novos Notifiers

### Passo 1: Adicionar o Mixin ao Notifier

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/mixins/optimistic_delete_mixin.dart';
import '../../domain/entities/appointment.dart';

@riverpod
class AppointmentsNotifier extends _$AppointmentsNotifier
    with OptimisticDeleteMixin<Appointment> {

  @override
  AppointmentsState build() {
    return const AppointmentsState();
  }

  // ... outros métodos CRUD ...
}
```

### Passo 2: Implementar os Métodos do Mixin

```dart
// ============================================================================
// OPTIMISTIC DELETE MIXIN IMPLEMENTATION
// ============================================================================

@override
String getItemId(Appointment item) => item.id;

@override
Future<void> performDelete(String id) async {
  final deleteAppointment = ref.read(deleteAppointmentProvider);
  final result = await deleteAppointment(id);

  result.fold(
    (failure) {
      // Log erro mas não propaga - item já foi removido da UI
      state = state.copyWith(error: failure.message);
    },
    (_) {
      // Sucesso - delete permanente confirmado
    },
  );
}

@override
Future<void> performRestore(Appointment item) async {
  // Re-adiciona o item à lista
  final updatedList = [...state.appointments, item];
  state = state.copyWith(appointments: updatedList);
}

/// Remove item otimisticamente (para uso com SwipeToDeleteWrapper)
Future<void> deleteAppointmentOptimistic(Appointment appointment) async {
  // Remove da UI imediatamente
  final updatedList = state.appointments
      .where((a) => a.id != appointment.id)
      .toList();
  state = state.copyWith(appointments: updatedList);

  // Agenda delete permanente com possibilidade de undo
  await removeOptimistic(appointment);
}

/// Restaura um item que foi removido otimisticamente
Future<void> restoreAppointment(String id) async {
  await restoreItem(id);
}
```

### Passo 3: Aplicar na UI (ListView)

#### Opção A: Usando SwipeToDeleteWrapper diretamente

```dart
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';

// No ListView.builder
itemBuilder: (context, index) {
  final appointment = appointments[index];

  return SwipeToDeleteWrapper(
    itemKey: 'appointment_${appointment.id}',
    deletedMessage: 'Consulta de ${appointment.animalName} foi excluída',
    onDelete: () async {
      await ref.read(appointmentsProvider.notifier)
          .deleteAppointmentOptimistic(appointment);
    },
    onRestore: () async {
      await ref.read(appointmentsProvider.notifier)
          .restoreAppointment(appointment.id);
    },
    child: AppointmentCard(
      appointment: appointment,
      onTap: () => onViewDetails(appointment),
    ),
  );
}
```

#### Opção B: Usando a extensão `.withSwipeToDelete()`

```dart
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';

itemBuilder: (context, index) {
  final appointment = appointments[index];

  return AppointmentCard(
    appointment: appointment,
    onTap: () => onViewDetails(appointment),
  ).withSwipeToDelete(
    itemKey: 'appointment_${appointment.id}',
    deletedMessage: 'Consulta de ${appointment.animalName} foi excluída',
    onDelete: () async {
      await ref.read(appointmentsProvider.notifier)
          .deleteAppointmentOptimistic(appointment);
    },
    onRestore: () async {
      await ref.read(appointmentsProvider.notifier)
          .restoreAppointment(appointment.id);
    },
  );
}
```

---

## 🎨 Customização

### Alterar Duração do Undo

Por padrão, o usuário tem 5 segundos para desfazer. Para alterar:

```dart
// No Notifier, sobrescreva o getter
@override
Duration get undoDuration => const Duration(seconds: 10); // 10 segundos
```

Ou no wrapper:

```dart
SwipeToDeleteWrapper(
  // ...
  undoDuration: const Duration(seconds: 10),
  child: MyCard(),
)
```

### Adicionar Confirmação Antes de Deletar

```dart
SwipeToDeleteWrapper(
  // ...
  confirmDismiss: (direction) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('EXCLUIR'),
          ),
        ],
      ),
    );
  },
  child: MyCard(),
)
```

### Desabilitar Swipe Temporariamente

```dart
SwipeToDeleteWrapper(
  // ...
  enabled: !isEditMode, // Desabilita em modo de edição
  child: MyCard(),
)
```

---

## 📦 Exemplo Completo: Implementação em Vacinas

### 1. Notifier (`vaccines_notifier.dart`)

```dart
@riverpod
class VaccinesNotifier extends _$VaccinesNotifier
    with OptimisticDeleteMixin<Vaccine> {

  @override
  VaccinesState build() {
    return const VaccinesState();
  }

  Future<void> loadVaccines() async { /* ... */ }

  // Implementação do mixin
  @override
  String getItemId(Vaccine item) => item.id;

  @override
  Future<void> performDelete(String id) async {
    final deleteVaccine = ref.read(deleteVaccineProvider);
    final result = await deleteVaccine(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {},
    );
  }

  @override
  Future<void> performRestore(Vaccine item) async {
    final updatedList = [...state.vaccines, item];
    state = state.copyWith(vaccines: updatedList);
  }

  Future<void> deleteVaccineOptimistic(Vaccine vaccine) async {
    final updatedList = state.vaccines
        .where((v) => v.id != vaccine.id)
        .toList();
    state = state.copyWith(vaccines: updatedList);
    await removeOptimistic(vaccine);
  }

  Future<void> restoreVaccine(String id) async {
    await restoreItem(id);
  }
}
```

### 2. UI (`vaccines_list.dart`)

```dart
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';

class VaccinesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinesState = ref.watch(vaccinesProvider);

    return ListView.builder(
      itemCount: vaccinesState.vaccines.length,
      itemBuilder: (context, index) {
        final vaccine = vaccinesState.vaccines[index];

        return SwipeToDeleteWrapper(
          itemKey: 'vaccine_${vaccine.id}',
          deletedMessage: '${vaccine.name} foi excluída',
          onDelete: () async {
            await ref.read(vaccinesProvider.notifier)
                .deleteVaccineOptimistic(vaccine);
          },
          onRestore: () async {
            await ref.read(vaccinesProvider.notifier)
                .restoreVaccine(vaccine.id);
          },
          child: VaccineCard(
            vaccine: vaccine,
            onTap: () => onViewDetails(vaccine),
          ),
        );
      },
    );
  }
}
```

---

## 🧪 Métodos Utilitários do Mixin

### Verificar se um item está pendente de delete

```dart
final notifier = ref.read(animalsProvider.notifier);
if (notifier.isPendingDelete('animal_123')) {
  // Mostrar opacity reduzida ou outro indicador visual
}
```

### Forçar delete de todos os itens pendentes

```dart
// Útil ao fazer logout ou limpar dados
await notifier.flushPendingDeletes();
```

### Cancelar todos os deletes pendentes

```dart
// Útil em cenários de erro ou cancelamento de operação em batch
await notifier.cancelAllPendingDeletes();
```

### Contar itens pendentes

```dart
final pendingCount = notifier.pendingDeleteCount;
// Exibir: "3 itens pendentes de exclusão"
```

---

## ⚠️ Importante: Dispose

Sempre chame `disposeDeleteMixin()` no `dispose` do Notifier para evitar memory leaks:

```dart
@override
void dispose() {
  disposeDeleteMixin(); // Limpa timers e cache
  super.dispose();
}
```

**Nota**: Em Riverpod Notifiers gerados com `@riverpod`, o dispose é gerenciado automaticamente, mas você pode adicionar lógica no `ref.onDispose`:

```dart
@riverpod
class MyNotifier extends _$MyNotifier with OptimisticDeleteMixin<Item> {
  @override
  MyState build() {
    ref.onDispose(() {
      disposeDeleteMixin();
    });
    return const MyState();
  }
}
```

---

## 📊 Features Aplicadas Atualmente

| Feature | Swipe-to-Delete | Status |
|---------|-----------------|--------|
| **Animals** | ✅ | Implementado |
| Appointments | ⬜ | Pendente |
| Vaccines | ⬜ | Pendente |
| Medications | ⬜ | Pendente |
| Reminders | ⬜ | Pendente |
| Expenses | ⬜ | Pendente |

---

## 🎯 Próximos Passos Recomendados

1. **Aplicar em Appointments** (consultas)
2. **Aplicar em Vaccines** (vacinas)
3. **Aplicar em Medications** (medicamentos)
4. **Aplicar em Reminders** (lembretes)
5. **Aplicar em Expenses** (despesas)

Cada implementação leva ~10-15 minutos seguindo este guia.

---

## 🔗 Referências

- **Arquivos Criados**:
  - `lib/core/widgets/swipe_to_delete_wrapper.dart`
  - `lib/core/mixins/optimistic_delete_mixin.dart`

- **Implementação de Referência**:
  - `lib/features/animals/presentation/providers/animals_providers.dart` (Notifier com mixin)
  - `lib/features/animals/presentation/widgets/animals_body.dart` (UI com wrapper)

- **Inspiração Original**:
  - App-Gasometer: `/apps/app-gasometer/lib/core/widgets/swipe_to_delete_wrapper.dart`
  - App-Gasometer: `/apps/app-gasometer/lib/core/mixins/optimistic_delete_mixin.dart`

---

**Documentado em**: 2025-12-29
**Autor**: Claude Code
**Status**: ✅ Pronto para uso em produção
