import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Rastreador de progresso de migração
///
/// Responsabilidade: Gerenciar e emitir atualizações de progresso
/// Aplica SRP (Single Responsibility Principle)
@LazySingleton()
class MigrationProgressTracker {
  final StreamController<MigrationProgress> _progressController =
      StreamController<MigrationProgress>.broadcast();

  /// Stream de progresso da migração
  Stream<MigrationProgress> get progressStream => _progressController.stream;

  /// Emite atualização de progresso
  void emitProgress({
    required double percentage,
    required String operation,
    String? details,
    Duration? estimatedTime,
  }) {
    if (kDebugMode) {
      debugPrint(
        '📊 Migration Progress: ${(percentage * 100).toInt()}% - $operation',
      );
    }

    _progressController.add(
      MigrationProgress(
        percentage: percentage,
        currentOperation: operation,
        details: details,
      ),
    );
  }

  /// Emite progresso inicial
  void emitInitial() {
    emitProgress(percentage: 0.0, operation: 'Iniciando migração');
  }

  /// Emite progresso de conclusão
  void emitCompleted({String? message}) {
    emitProgress(percentage: 1.0, operation: message ?? 'Migração concluída');
  }

  /// Emite progresso de cancelamento
  void emitCancelled() {
    emitProgress(percentage: 0.0, operation: 'Migração cancelada');
  }

  /// Emite progresso de erro
  void emitError(String errorMessage) {
    emitProgress(
      percentage: 0.0,
      operation: 'Erro durante migração',
      details: errorMessage,
    );
  }

  /// Limpa recursos
  void dispose() {
    _progressController.close();
  }
}
