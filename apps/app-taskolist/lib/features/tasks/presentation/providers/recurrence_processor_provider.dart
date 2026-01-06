import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/task_entity.dart';

part 'recurrence_processor_provider.g.dart';

/// Provider que processa tarefas recorrentes automaticamente
@riverpod
class RecurrenceProcessor extends _$RecurrenceProcessor {
  @override
  FutureOr<void> build() async {
    // TODO: Implementar processamento de tarefas recorrentes
  }

  /// Força o processamento manual de tarefas recorrentes
  Future<void> processNow() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implementar
    });
  }
}

/// Provider que retorna se uma tarefa deve ser recriada hoje
@riverpod
Future<bool> shouldRecreateTask(
  Ref ref,
  TaskEntity task,
) async {
  // TODO: Implementar lógica de recorrência quando recurrenceRule for adicionado
  return false;
}
