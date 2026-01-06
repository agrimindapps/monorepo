import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/feedback_providers.dart';
import '../../loading/contextual_loading_manager.dart';
import '../feedback_system.dart';
import '../haptic_service.dart';
import '../progress_tracker.dart';
import '../toast_service.dart';
import 'operation_config.dart';

/// Service responsável por executar operações com feedback completo
/// Extrai lógica de executeWithFeedback do UnifiedFeedbackSystem
class OperationExecutorService {
  final Ref _ref;
  late final HapticService _hapticService;
  late final ToastService _toastService;
  late final FeedbackService _feedbackService;

  OperationExecutorService(this._ref) {
    _hapticService = _ref.watch(hapticServiceProvider);
    _toastService = _ref.watch(toastServiceProvider);
    _feedbackService = _ref.watch(feedbackServiceProvider);
  }

  /// Executa operação com feedback visual completo
  Future<T> execute<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function() operation,
    required OperationConfig config,
  }) async {
    // Inicia loading
    ContextualLoadingManager.startLoading(
      operationKey,
      message: config.loadingMessage,
      type: config.loadingType,
      timeout: config.timeout,
    );

    // Haptic inicial
    if (config.includeHaptic) {
      await _hapticService.light();
    }

    try {
      // Executa operação
      final result = await operation();

      // Para loading
      ContextualLoadingManager.stopLoading(operationKey);

      // Feedback de sucesso
      await _handleSuccess(context: context, config: config);

      return result;
    } catch (error) {
      // Para loading
      ContextualLoadingManager.stopLoading(operationKey);

      // Feedback de erro
      await _handleError(context: context, error: error, config: config);

      rethrow;
    }
  }

  /// Executa operação com progresso determinado
  Future<T> executeWithProgress<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function(void Function(double, String?) progressCallback)
    operation,
    required ProgressOperationConfig config,
  }) async {
    final progressOp = ProgressTracker.startOperation(
      key: operationKey,
      title: config.title,
      description: config.description,
      type: ProgressType.determinate,
      includeHaptic: config.includeHaptic,
    );

    progressOp.setContext(context);

    try {
      final result = await operation((progress, message) {
        ProgressTracker.updateProgress(
          operationKey,
          progress: progress,
          message: message,
          includeHaptic: false, // Evitar spam de haptic
        );
      });

      ProgressTracker.completeOperation(
        operationKey,
        successMessage: config.successMessage,
        showToast: config.showToast,
        includeHaptic: config.includeHaptic,
      );

      return result;
    } catch (error) {
      ProgressTracker.failOperation(
        operationKey,
        errorMessage: 'Erro: ${error.toString()}',
        showToast: config.showToast,
        includeHaptic: config.includeHaptic,
        onRetry: () {},
      );

      rethrow;
    }
  }

  /// Processa feedback de sucesso
  Future<void> _handleSuccess({
    required BuildContext context,
    required OperationConfig config,
  }) async {
    if (config.includeHaptic) {
      await _hapticService.success();
    }

    if (config.showToast && context.mounted) {
      _toastService.showSuccess(
        context: context,
        message: config.successMessage ?? 'Operação concluída!',
      );
    }

    if (context.mounted) {
      _feedbackService.showSuccess(
        context: context,
        message: config.successMessage ?? 'Sucesso!',
        animation: config.successAnimation,
      );
    }
  }

  /// Processa feedback de erro
  Future<void> _handleError({
    required BuildContext context,
    required Object error,
    required OperationConfig config,
  }) async {
    if (config.includeHaptic) {
      await _hapticService.heavy();
    }

    final errorMessage =
        config.errorMessage ?? 'Erro na operação: ${error.toString()}';

    if (config.showToast && context.mounted) {
      _toastService.showError(context: context, message: errorMessage);
    }

    if (context.mounted) {
      _feedbackService.showError(context: context, message: errorMessage);
    }
  }
}
