import 'package:flutter/material.dart';

import '../../loading/contextual_loading_manager.dart';
import '../core/feedback_orchestrator.dart';
import '../core/operation_config.dart';

/// Extension helpers para operações de sync e backup
extension SyncFeedbackHelpers on FeedbackOrchestrator {
  /// Sincronização com feedback
  Future<T> sync<T>({
    required BuildContext context,
    required Future<T> Function() operation,
  }) {
    return executeOperation<T>(
      context: context,
      operationKey: 'sync_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: const OperationConfig(
        loadingMessage: 'Sincronizando dados...',
        successMessage: 'Dados sincronizados!',
        loadingType: LoadingType.sync,
      ),
    );
  }

  /// Backup com progresso
  Future<T> backup<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    operation,
  }) {
    return executeWithProgress<T>(
      context: context,
      operationKey: 'backup_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: const ProgressOperationConfig(
        title: 'Criando backup',
        description: 'Salvando seus dados na nuvem...',
        successMessage: 'Backup criado com sucesso!',
      ),
    );
  }
}
