import 'package:flutter/material.dart';

import '../core/feedback_orchestrator.dart';
import '../core/operation_config.dart';
import '../feedback_system.dart';
import '../../loading/contextual_loading_manager.dart';

/// Extension helpers para operações relacionadas a plantas
extension PlantFeedbackHelpers on FeedbackOrchestrator {
  /// Salva planta com feedback completo
  Future<T> savePlant<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String plantName,
    bool isEdit = false,
  }) {
    return executeOperation<T>(
      context: context,
      operationKey: 'save_plant_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: OperationConfig(
        loadingMessage: isEdit
            ? 'Atualizando $plantName...'
            : 'Salvando $plantName...',
        successMessage: isEdit
            ? 'Planta atualizada!'
            : 'Planta salva com sucesso!',
        loadingType: LoadingType.save,
        successAnimation: SuccessAnimationType.bounce,
      ),
    );
  }

  /// Upload de imagem de planta com progresso
  Future<T> uploadPlantImage<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    operation,
    required String imageName,
  }) {
    return executeWithProgress<T>(
      context: context,
      operationKey: 'upload_image_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: const ProgressOperationConfig(
        title: 'Enviando imagem',
        description: 'Upload em andamento...',
        successMessage: 'Imagem enviada com sucesso!',
      ),
    );
  }
}
