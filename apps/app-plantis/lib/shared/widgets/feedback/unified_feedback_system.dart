import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/feedback_providers.dart';
import '../loading/contextual_loading_manager.dart';
import 'confirmation_system.dart';
import 'core/feedback_orchestrator.dart';
import 'core/operation_config.dart';
import 'feedback_system.dart';
import 'helpers/auth_feedback_helpers.dart';
import 'helpers/plant_feedback_helpers.dart';
import 'helpers/sync_feedback_helpers.dart';
import 'helpers/task_feedback_helpers.dart';
import 'progress_tracker.dart';

/// Sistema unificado de feedback - Facade Pattern
///
/// DEPRECATION NOTICE:
/// Esta classe mantém compatibilidade backward mas delega para FeedbackOrchestrator.
/// Use FeedbackOrchestrator diretamente via Riverpod para novos códigos.
///
/// Refatorado de God Class (614L) para Facade + Services modulares
class UnifiedFeedbackSystem {
  static bool _isInitialized = false;
  static FeedbackOrchestrator? _orchestrator;

  /// Inicializa o sistema de feedback
  static Future<void> initialize({ProviderContainer? container}) async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Obtém orchestrator do context
  static FeedbackOrchestrator _getOrchestrator(
    BuildContext? context,
    ProviderContainer? container,
  ) {
    if (_orchestrator != null) return _orchestrator!;

    final providerContainer =
        container ??
        (context != null ? ProviderScope.containerOf(context) : null);

    if (providerContainer == null) {
      throw StateError(
        'No ProviderContainer available for UnifiedFeedbackSystem',
      );
    }

    return providerContainer.read(feedbackOrchestratorProvider);
  }

  /// Verifica se foi inicializado
  static bool get isInitialized => _isInitialized;

  // ==================== DEPRECATED METHODS ====================
  // Mantidos por compatibilidade - Delegar para FeedbackOrchestrator

  @Deprecated('Use FeedbackOrchestrator.executeOperation()')
  static Future<T> executeWithFeedback<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function() operation,
    required String loadingMessage,
    String? successMessage,
    String? errorMessage,
    LoadingType loadingType = LoadingType.standard,
    SuccessAnimationType successAnimation = SuccessAnimationType.checkmark,
    bool includeHaptic = true,
    bool showToast = true,
    Duration? timeout,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).executeOperation<T>(
      context: context,
      operationKey: operationKey,
      operation: operation,
      config: OperationConfig(
        loadingMessage: loadingMessage,
        successMessage: successMessage,
        errorMessage: errorMessage,
        loadingType: loadingType,
        successAnimation: successAnimation,
        includeHaptic: includeHaptic,
        showToast: showToast,
        timeout: timeout,
      ),
    );
  }

  @Deprecated('Use FeedbackOrchestrator.executeWithProgress()')
  static Future<T> executeWithProgress<T>({
    required BuildContext context,
    required String operationKey,
    required Future<T> Function(void Function(double, String?) progressCallback)
    operation,
    required String title,
    String? description,
    String? successMessage,
    bool includeHaptic = true,
    bool showToast = true,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).executeWithProgress<T>(
      context: context,
      operationKey: operationKey,
      operation: operation,
      config: ProgressOperationConfig(
        title: title,
        description: description,
        successMessage: successMessage,
        includeHaptic: includeHaptic,
        showToast: showToast,
      ),
    );
  }

  // Convenience methods - delegate to helpers
  @Deprecated('Use PlantFeedbackHelpers.savePlant()')
  static Future<T> savePlant<T>({
    required BuildContext context,
    required Future<T> Function() saveOperation,
    required String plantName,
    bool isEdit = false,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).savePlant<T>(
      context: context,
      operation: saveOperation,
      plantName: plantName,
      isEdit: isEdit,
    );
  }

  @Deprecated('Use TaskFeedbackHelpers.completeTask()')
  static Future<T> completeTask<T>({
    required BuildContext context,
    required Future<T> Function() completeOperation,
    required String taskName,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).completeTask<T>(
      context: context,
      operation: completeOperation,
      taskName: taskName,
    );
  }

  @Deprecated('Use AuthFeedbackHelpers.login()')
  static Future<T> login<T>({
    required BuildContext context,
    required Future<T> Function() loginOperation,
    String? userName,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(
      context,
      container,
    ).login<T>(context: context, operation: loginOperation, userName: userName);
  }

  @Deprecated('Use AuthFeedbackHelpers.purchasePremium()')
  static Future<T> purchasePremium<T>({
    required BuildContext context,
    required Future<T> Function() purchaseOperation,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(
      context,
      container,
    ).purchasePremium<T>(context: context, operation: purchaseOperation);
  }

  @Deprecated('Use SyncFeedbackHelpers.backup()')
  static Future<T> backup<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    backupOperation,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(
      context,
      container,
    ).backup<T>(context: context, operation: backupOperation);
  }

  @Deprecated('Use PlantFeedbackHelpers.uploadPlantImage()')
  static Future<T> uploadImage<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    uploadOperation,
    required String imageName,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).uploadPlantImage<T>(
      context: context,
      operation: uploadOperation,
      imageName: imageName,
    );
  }

  @Deprecated('Use SyncFeedbackHelpers.sync()')
  static Future<T> sync<T>({
    required BuildContext context,
    required Future<T> Function() syncOperation,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(
      context,
      container,
    ).sync<T>(context: context, operation: syncOperation);
  }

  @Deprecated('Use FeedbackOrchestrator.showConfirmation()')
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    ConfirmationType type = ConfirmationType.info,
    IconData? icon,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).showConfirmation(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      type: type,
      icon: icon,
    );
  }

  @Deprecated('Use FeedbackOrchestrator.showDestructiveConfirmation()')
  static Future<bool> confirmDestruction({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    bool requireDouble = false,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).showDestructiveConfirmation(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      requiresDoubleConfirmation: requireDouble,
    );
  }

  @Deprecated('Use FeedbackOrchestrator.showSuccessToast()')
  static void successToast(
    BuildContext context,
    String message, {
    ProviderContainer? container,
  }) {
    _getOrchestrator(context, container).showSuccessToast(context, message);
  }

  @Deprecated('Use FeedbackOrchestrator.showErrorToast()')
  static void errorToast(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    ProviderContainer? container,
  }) {
    _getOrchestrator(
      context,
      container,
    ).showErrorToast(context, message, onRetry: onRetry);
  }

  @Deprecated('Use FeedbackOrchestrator.showInfoToast()')
  static void infoToast(
    BuildContext context,
    String message, {
    ProviderContainer? container,
  }) {
    _getOrchestrator(context, container).showInfoToast(context, message);
  }

  @Deprecated('Use FeedbackOrchestrator.showWarningToast()')
  static void warningToast(
    BuildContext context,
    String message, {
    ProviderContainer? container,
  }) {
    _getOrchestrator(context, container).showWarningToast(context, message);
  }

  @Deprecated('Use FeedbackOrchestrator.lightHaptic()')
  static Future<void> lightHaptic({
    BuildContext? context,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).lightHaptic();
  }

  @Deprecated('Use FeedbackOrchestrator.mediumHaptic()')
  static Future<void> mediumHaptic({
    BuildContext? context,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).mediumHaptic();
  }

  @Deprecated('Use FeedbackOrchestrator.heavyHaptic()')
  static Future<void> heavyHaptic({
    BuildContext? context,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).heavyHaptic();
  }

  @Deprecated('Use FeedbackOrchestrator.contextualHaptic()')
  static Future<void> contextualHaptic(
    String contextType, {
    BuildContext? context,
    ProviderContainer? container,
  }) {
    return _getOrchestrator(context, container).contextualHaptic(contextType);
  }

  /// Limpa todos os sistemas de feedback
  static void dispose({BuildContext? context, ProviderContainer? container}) {
    ContextualLoadingManager.dispose();
    ProgressTracker.clearAll();
  }

  /// Para todas as operações ativas
  static void stopAll({BuildContext? context, ProviderContainer? container}) {
    ContextualLoadingManager.stopAllLoadings();
    ProgressTracker.clearAll();
  }
}

/// Widget principal que gerencia todos os tipos de feedback
class UnifiedFeedbackProvider extends StatefulWidget {
  final Widget child;
  final bool enableFeedbackOverlay;
  final bool enableToastOverlay;
  final bool enableProgressOverlay;
  final Alignment feedbackAlignment;

  const UnifiedFeedbackProvider({
    super.key,
    required this.child,
    this.enableFeedbackOverlay = true,
    this.enableToastOverlay = true,
    this.enableProgressOverlay = true,
    this.feedbackAlignment = Alignment.topCenter,
  });

  @override
  State<UnifiedFeedbackProvider> createState() =>
      _UnifiedFeedbackProviderState();
}

class _UnifiedFeedbackProviderState extends State<UnifiedFeedbackProvider> {
  @override
  void initState() {
    super.initState();
    UnifiedFeedbackSystem.initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    child = ContextualLoadingListener(child: child);
    if (widget.enableProgressOverlay) {
      child = Stack(
        children: [
          child,
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: ProgressTrackerPanel(showOnlyActive: true),
          ),
        ],
      );
    }

    return child;
  }
}

/// Mixin para widgets que precisam de feedback unificado
mixin UnifiedFeedbackMixin {
  /// Executa operação com feedback completo
  Future<T> executeOperation<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String loadingMessage,
    String? successMessage,
    LoadingType loadingType = LoadingType.standard,
    SuccessAnimationType successAnimation = SuccessAnimationType.checkmark,
  }) {
    return UnifiedFeedbackSystem.executeWithFeedback<T>(
      context: context,
      operationKey: '${runtimeType}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
      loadingType: loadingType,
      successAnimation: successAnimation,
    );
  }

  /// Mostra confirmação
  Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    ConfirmationType type = ConfirmationType.warning,
  }) {
    return UnifiedFeedbackSystem.confirm(
      context: context,
      title: title,
      message: message,
      type: type,
    );
  }

  /// Mostra toast de sucesso
  void showSuccessToast(BuildContext context, String message) {
    UnifiedFeedbackSystem.successToast(context, message);
  }

  /// Mostra toast de erro
  void showErrorToast(BuildContext context, String message) {
    UnifiedFeedbackSystem.errorToast(context, message);
  }

  /// Haptic feedback contextual
  Future<void> performHaptic(String context) {
    return UnifiedFeedbackSystem.contextualHaptic(context);
  }
}

/// Extensão para BuildContext com feedback unificado
extension UnifiedFeedbackExtension on BuildContext {
  /// Executa operação com feedback
  Future<T> executeWithFeedback<T>({
    required Future<T> Function() operation,
    required String loadingMessage,
    String? successMessage,
  }) {
    return UnifiedFeedbackSystem.executeWithFeedback<T>(
      context: this,
      operationKey: 'context_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      loadingMessage: loadingMessage,
      successMessage: successMessage,
    );
  }

  /// Mostra toast de sucesso
  void showSuccessToast(String message) {
    UnifiedFeedbackSystem.successToast(this, message);
  }

  /// Mostra toast de erro
  void showErrorToast(String message) {
    UnifiedFeedbackSystem.errorToast(this, message);
  }

  /// Mostra confirmação
  Future<bool> showConfirmation({
    required String title,
    required String message,
  }) {
    return UnifiedFeedbackSystem.confirm(
      context: this,
      title: title,
      message: message,
    );
  }
}
