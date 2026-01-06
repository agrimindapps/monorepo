import 'package:flutter/material.dart';

import '../../loading/contextual_loading_manager.dart';
import '../core/feedback_orchestrator.dart';
import '../core/operation_config.dart';
import '../feedback_system.dart';

/// Extension helpers para operações relacionadas a tarefas
extension TaskFeedbackHelpers on FeedbackOrchestrator {
  /// Completa tarefa com feedback
  Future<T> completeTask<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String taskName,
  }) {
    return executeOperation<T>(
      context: context,
      operationKey: 'complete_task_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: OperationConfig(
        loadingMessage: 'Concluindo tarefa...',
        successMessage: 'Tarefa "$taskName" concluída!',
        loadingType: LoadingType.standard,
        successAnimation: SuccessAnimationType.confetti,
      ),
    );
  }
}
