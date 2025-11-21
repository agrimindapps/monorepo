import 'package:flutter/material.dart';

import '../loading/contextual_loading_manager.dart';
import 'confirmation_system.dart';
import 'feedback_system.dart';
import 'haptic_service.dart';
import 'progress_tracker.dart';
import 'toast_service.dart';

/// Sistema unificado de feedback que integra todos os componentes
/// Trabalha em conjunto com ContextualLoadingManager para experiência completa
class UnifiedFeedbackSystem {
  static bool _isInitialized = false;

  /// Inicializa todos os sistemas de feedback
  static Future<void> initialize() async {
    if (_isInitialized) return;
    // await getIt<HapticService>().initialize();

    _isInitialized = true;
  }

  /// Verifica se foi inicializado
  static bool get isInitialized => _isInitialized;

  /// Executa operação async com feedback visual completo
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
  }) async {
    ContextualLoadingManager.startLoading(
      operationKey,
      message: loadingMessage,
      type: loadingType,
      timeout: timeout,
    );

    if (includeHaptic) {
      // await getIt<HapticService>().light();
    }

    try {
      final result = await operation();
      ContextualLoadingManager.stopLoading(operationKey);
      if (includeHaptic) {
        // await getIt<HapticService>().success();
      }

      if (showToast && context.mounted) {
        // getIt<ToastService>().showSuccess(
        //   context: context,
        //   message: successMessage ?? 'Operação concluída com sucesso!',
        // );
      }
      if (context.mounted) {
        // getIt<FeedbackService>().showSuccess(
        //   context: context,
        //   message: successMessage ?? 'Sucesso!',
        //   animation: successAnimation,
        //   includeHaptic: false, // Já foi feito acima
        // );
      }

      return result;
    } catch (error) {
      ContextualLoadingManager.stopLoading(operationKey);
      if (includeHaptic) {
        // await getIt<HapticService>().error();
      }

      final errorMsg = errorMessage ?? 'Erro na operação: ${error.toString()}';

      if (showToast && context.mounted) {
        // getIt<ToastService>().showError(
        //   context: context,
        //   message: errorMsg,
        //   actionLabel: 'Tentar novamente',
        //   onAction: () {
        //   },
        // );
      }

      if (context.mounted) {
        // getIt<FeedbackService>().showError(
        //   context: context,
        //   message: errorMsg,
        //   animation: ErrorAnimationType.shake,
        //   includeHaptic: false,
        // );
      }

      rethrow;
    }
  }

  /// Executa operação com progresso determinado
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
  }) async {
    final progressOp = ProgressTracker.startOperation(
      key: operationKey,
      title: title,
      description: description,
      type: ProgressType.determinate,
      includeHaptic: includeHaptic,
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
        successMessage: successMessage,
        showToast: showToast,
        includeHaptic: includeHaptic,
      );

      return result;
    } catch (error) {
      ProgressTracker.failOperation(
        operationKey,
        errorMessage: 'Erro: ${error.toString()}',
        showToast: showToast,
        includeHaptic: includeHaptic,
        onRetry: () {
        },
      );

      rethrow;
    }
  }

  /// Salvar planta com feedback completo
  static Future<T> savePlant<T>({
    required BuildContext context,
    required Future<T> Function() saveOperation,
    required String plantName,
    bool isEdit = false,
  }) async {
    return executeWithFeedback<T>(
      context: context,
      operationKey: 'save_plant_${DateTime.now().millisecondsSinceEpoch}',
      operation: saveOperation,
      loadingMessage:
          isEdit ? 'Atualizando $plantName...' : 'Salvando $plantName...',
      successMessage:
          isEdit ? 'Planta atualizada!' : 'Planta salva com sucesso!',
      loadingType: LoadingType.save,
      successAnimation: SuccessAnimationType.bounce,
    );
  }

  /// Completar tarefa com feedback completo
  static Future<T> completeTask<T>({
    required BuildContext context,
    required Future<T> Function() completeOperation,
    required String taskName,
  }) async {
    return executeWithFeedback<T>(
      context: context,
      operationKey: 'complete_task_${DateTime.now().millisecondsSinceEpoch}',
      operation: completeOperation,
      loadingMessage: 'Concluindo tarefa...',
      successMessage: 'Tarefa "$taskName" concluída!',
      loadingType: LoadingType.standard,
      successAnimation: SuccessAnimationType.confetti,
    );
  }

  /// Login com feedback completo
  static Future<T> login<T>({
    required BuildContext context,
    required Future<T> Function() loginOperation,
    String? userName,
  }) async {
    return executeWithFeedback<T>(
      context: context,
      operationKey: 'login_${DateTime.now().millisecondsSinceEpoch}',
      operation: loginOperation,
      loadingMessage: 'Fazendo login...',
      successMessage:
          userName != null
              ? 'Bem-vindo, $userName!'
              : 'Login realizado com sucesso!',
      loadingType: LoadingType.auth,
      successAnimation: SuccessAnimationType.checkmark,
    );
  }

  /// Compra premium com feedback completo
  static Future<T> purchasePremium<T>({
    required BuildContext context,
    required Future<T> Function() purchaseOperation,
  }) async {
    return executeWithFeedback<T>(
      context: context,
      operationKey: 'purchase_premium_${DateTime.now().millisecondsSinceEpoch}',
      operation: purchaseOperation,
      loadingMessage: 'Processando compra...',
      successMessage: 'Premium ativado com sucesso!',
      loadingType: LoadingType.purchase,
      successAnimation: SuccessAnimationType.confetti,
      timeout: const Duration(minutes: 2),
    );
  }

  /// Backup com progresso
  static Future<T> backup<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    backupOperation,
  }) async {
    return executeWithProgress<T>(
      context: context,
      operationKey: 'backup_${DateTime.now().millisecondsSinceEpoch}',
      operation: backupOperation,
      title: 'Criando backup',
      description: 'Salvando seus dados na nuvem...',
      successMessage: 'Backup criado com sucesso!',
    );
  }

  /// Upload de imagem com progresso
  static Future<T> uploadImage<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) progressCallback)
    uploadOperation,
    required String imageName,
  }) async {
    return executeWithProgress<T>(
      context: context,
      operationKey: 'upload_image_${DateTime.now().millisecondsSinceEpoch}',
      operation: uploadOperation,
      title: 'Enviando imagem',
      description: 'Upload de $imageName',
      successMessage: 'Imagem enviada com sucesso!',
    );
  }

  /// Sincronização com feedback
  static Future<T> sync<T>({
    required BuildContext context,
    required Future<T> Function() syncOperation,
  }) async {
    return executeWithFeedback<T>(
      context: context,
      operationKey: 'sync_${DateTime.now().millisecondsSinceEpoch}',
      operation: syncOperation,
      loadingMessage: 'Sincronizando dados...',
      successMessage: 'Dados sincronizados!',
      loadingType: LoadingType.sync,
      successAnimation: SuccessAnimationType.checkmark,
    );
  }

  /// Confirmação com feedback háptico
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    ConfirmationType type = ConfirmationType.info,
    IconData? icon,
  }) async {
    // return getIt<ConfirmationService>().showConfirmation(
    //   context: context,
    //   title: title,
    //   message: message,
    //   confirmLabel: confirmLabel,
    //   cancelLabel: cancelLabel,
    //   type: type,
    //   icon: icon,
    // );
    return false;
  }

  /// Confirmação destrutiva com feedback
  static Future<bool> confirmDestruction({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    bool requireDouble = false,
  }) async {
    // return getIt<ConfirmationService>().showDestructiveConfirmation(
    //   context: context,
    //   title: title,
    //   message: message,
    //   confirmLabel: confirmLabel,
    //   requiresDoubleConfirmation: requireDouble,
    // );
    return false;
  }

  /// Toast de sucesso rápido
  static void successToast(BuildContext context, String message) {
    // getIt<ToastService>().showSuccess(
    //   context: context,
    //   message: message,
    //   includeHaptic: true,
    // );
  }

  /// Toast de erro com ação
  static void errorToast(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    // getIt<ToastService>().showError(
    //   context: context,
    //   message: message,
    //   actionLabel: onRetry != null ? 'Tentar novamente' : null,
    //   onAction: onRetry,
    //   includeHaptic: true,
    // );
  }

  /// Toast de info
  static void infoToast(BuildContext context, String message) {
    // getIt<ToastService>().showInfo(context: context, message: message);
  }

  /// Toast de warning
  static void warningToast(BuildContext context, String message) {
    // getIt<ToastService>().showWarning(
    //   context: context,
    //   message: message,
    //   includeHaptic: true,
    // );
  }

  /// Haptic para ações básicas
  static Future<void> lightHaptic() async {
    // return getIt<HapticService>().light();
  }

  /// Haptic para ações importantes
  static Future<void> mediumHaptic() async {
    // return getIt<HapticService>().medium();
  }

  /// Haptic para ações críticas
  static Future<void> heavyHaptic() async {
    // return getIt<HapticService>().heavy();
  }

  /// Haptic contextual
  static Future<void> contextualHaptic(String context) async {
    // final hapticService = getIt<HapticService>();
    // switch (context) {
    //   case 'task_complete':
    //     await hapticService.completeTask();
    //     break;
    //   case 'plant_save':
    //     await hapticService.addPlant();
    //     break;
    //   case 'premium_purchase':
    //     await hapticService.purchaseSuccess();
    //     break;
    //   case 'error':
    //     await hapticService.error();
    //     break;
    //   case 'success':
    //     await hapticService.success();
    //     break;
    //   default:
    //     await hapticService.light();
    // }
  }

  /// Limpa todos os sistemas de feedback
  static void dispose() {
    // getIt<FeedbackService>().dispose();
    ContextualLoadingManager.dispose();
    ProgressTracker.clearAll();
    // getIt<ToastService>().dismissAll();
  }

  /// Para todas as operações ativas
  static void stopAll() {
    // getIt<FeedbackService>().dismissAll();
    ContextualLoadingManager.stopAllLoadings();
    ProgressTracker.clearAll();
    // getIt<ToastService>().dismissAll();
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
    if (widget.enableFeedbackOverlay) {
      // child = FeedbackListener(
      //   feedbackService: getIt<FeedbackService>(),
      //   alignment: widget.feedbackAlignment,
      //   child: child,
      // );
    }
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
