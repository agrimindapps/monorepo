import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/feedback_providers.dart';
import '../confirmation_system.dart';
import '../haptic_service.dart';
import '../toast_service.dart';
import 'operation_config.dart';
import 'operation_executor_service.dart';

/// Orchestrator principal do sistema de feedback
/// Coordena todos os services de feedback de forma centralizada
class FeedbackOrchestrator {
  final Ref _ref;
  late final OperationExecutorService _executor;
  late final HapticService _hapticService;
  late final ToastService _toastService;
  late final ConfirmationService _confirmationService;

  FeedbackOrchestrator(this._ref) {
    _executor = _ref.watch(operationExecutorServiceProvider);
    _hapticService = _ref.watch(hapticServiceProvider);
    _toastService = _ref.watch(toastServiceProvider);
    _confirmationService = _ref.watch(confirmationServiceProvider);
  }

  // ==================== OPERATION EXECUTION ====================

  /// Executa operação com feedback completo
  Future<T> executeOperation<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function() operation,
    required OperationConfig config,
  }) {
    return _executor.execute<T>(
      context: context,
      operationKey: operationKey,
      operation: operation,
      config: config,
    );
  }

  /// Executa operação com progresso determinado
  Future<T> executeWithProgress<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function(void Function(double, String?) progressCallback)
    operation,
    required ProgressOperationConfig config,
  }) {
    return _executor.executeWithProgress<T>(
      context: context,
      operationKey: operationKey,
      operation: operation,
      config: config,
    );
  }

  // ==================== CONFIRMATIONS ====================

  /// Mostra dialog de confirmação
  Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    ConfirmationType type = ConfirmationType.info,
    IconData? icon,
  }) async {
    return await _confirmationService.showConfirmation(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      type: type,
      icon: icon,
    );
  }

  /// Mostra confirmação destrutiva
  Future<bool> showDestructiveConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    bool requiresDoubleConfirmation = false,
  }) async {
    return await _confirmationService.showDestructiveConfirmation(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      requiresDoubleConfirmation: requiresDoubleConfirmation,
    );
  }

  // ==================== TOASTS ====================

  /// Mostra toast de sucesso
  void showSuccessToast(BuildContext context, String message) {
    _toastService.showSuccess(context: context, message: message);
  }

  /// Mostra toast de erro
  void showErrorToast(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    _toastService.showError(
      context: context,
      message: message,
      onAction: onRetry,
      actionLabel: onRetry != null ? 'Tentar novamente' : null,
    );
  }

  /// Mostra toast de info
  void showInfoToast(BuildContext context, String message) {
    _toastService.showInfo(context: context, message: message);
  }

  /// Mostra toast de warning
  void showWarningToast(BuildContext context, String message) {
    _toastService.showWarning(context: context, message: message);
  }

  // ==================== HAPTIC FEEDBACK ====================

  /// Haptic leve
  Future<void> lightHaptic() => _hapticService.light();

  /// Haptic médio
  Future<void> mediumHaptic() => _hapticService.medium();

  /// Haptic pesado
  Future<void> heavyHaptic() => _hapticService.heavy();

  /// Haptic de sucesso
  Future<void> successHaptic() => _hapticService.success();

  /// Haptic de erro
  Future<void> errorHaptic() => _hapticService.error();

  /// Haptic contextual
  Future<void> contextualHaptic(String contextType) async {
    switch (contextType) {
      case 'button_tap':
        await _hapticService.buttonTap();
        break;
      case 'task_complete':
        await _hapticService.completeTask();
        break;
      case 'plant_save':
        await _hapticService.addPlant();
        break;
      case 'premium_purchase':
        await _hapticService.purchaseSuccess();
        break;
      case 'error':
        await _hapticService.error();
        break;
      case 'success':
        await _hapticService.success();
        break;
      default:
        await _hapticService.light();
    }
  }
}
