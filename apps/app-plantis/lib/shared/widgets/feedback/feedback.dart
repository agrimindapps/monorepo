/// Sistema completo de feedback visual para operações async
///
/// Este sistema integra:
/// - Loading states contextuais
/// - Feedback de sucesso/erro com animações
/// - Toasts não intrusivos
/// - Progress tracking para uploads
/// - Haptic feedback
/// - Dialogs de confirmação
///
/// Uso básico:
/// ```dart
/// // Inicializar no app (main.dart)
/// await UnifiedFeedbackSystem.initialize();
///
/// // Envolver o app com provider
/// UnifiedFeedbackProvider(
///   child: MyApp(),
/// )
///
/// // Em widgets, usar mixin
/// class MyWidget extends StatefulWidget with UnifiedFeedbackMixin {
///   // ... implementação
/// }
///
/// // Executar operações com feedback
/// await executeOperation(
///   context: context,
///   operation: () => saveData(),
///   loadingMessage: 'Salvando dados...',
///   successMessage: 'Dados salvos!',
/// );
/// ```

library;

import 'package:flutter/material.dart';

import '../loading/contextual_loading_manager.dart';
import 'feedback_system.dart';
import 'unified_feedback_system.dart';

export '../loading/contextual_loading_manager.dart';
export 'confirmation_system.dart';
export 'feedback_system.dart';
export 'haptic_service.dart';
export 'progress_tracker.dart';
export 'services/animation_service.dart';
export 'toast_service.dart';
export 'unified_feedback_system.dart';

class FeedbackOperations {
  static const String taskComplete = 'task_complete';
  static const String taskCreate = 'task_create';
  static const String taskDelete = 'task_delete';
  static const String plantSave = 'plant_save';
  static const String plantUpdate = 'plant_update';
  static const String plantDelete = 'plant_delete';
  static const String plantWater = 'plant_water';
  static const String premiumPurchase = 'premium_purchase';
  static const String premiumRestore = 'premium_restore';
  static const String premiumCancel = 'premium_cancel';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  static const String sync = 'sync';
  static const String backup = 'backup';
  static const String restore = 'restore';
  static const String upload = 'upload';
  static const String saveSettings = 'save_settings';
  static const String resetData = 'reset_data';
}

/// Utility class for common feedback patterns
final class FeedbackPatterns {
  FeedbackPatterns._();

  /// Pattern para salvar dados
  static Future<T> saveData<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required String itemName,
    bool isUpdate = false,
  }) {
    return UnifiedFeedbackSystem.executeWithFeedback<T>(
      context: context,
      operationKey: 'save_${itemName}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      loadingMessage: isUpdate
          ? 'Atualizando $itemName...'
          : 'Salvando $itemName...',
      successMessage: isUpdate ? '$itemName atualizado!' : '$itemName salvo!',
      loadingType: LoadingType.save,
      successAnimation: SuccessAnimationType.checkmark,
    );
  }

  /// Pattern para deletar dados
  static Future<bool> deleteData({
    required BuildContext context,
    required Future<void> Function() operation,
    required String itemName,
    required String itemType,
    bool requireConfirmation = true,
  }) async {
    // Capture context before async gap
    final capturedContext = context;

    if (requireConfirmation) {
      final confirmed = await UnifiedFeedbackSystem.confirmDestruction(
        context: capturedContext,
        title: 'Deletar $itemType',
        message: 'Tem certeza que deseja remover "$itemName"?',
        requireDouble: true,
      );

      if (!confirmed) return false;
    }

    // Safe to use after check - UnifiedFeedbackSystem handles mounted checks internally
    if (!capturedContext.mounted) return false;

    await UnifiedFeedbackSystem.executeWithFeedback<void>(
      context: capturedContext,
      operationKey:
          'delete_${itemName}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      loadingMessage: 'Removendo $itemName...',
      successMessage: '$itemName removido!',
      loadingType: LoadingType.standard,
      successAnimation: SuccessAnimationType.fade,
    );

    return true;
  }

  /// Pattern para upload com progresso
  static Future<T> uploadFile<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) onProgress)
    operation,
    required String fileName,
  }) {
    return UnifiedFeedbackSystem.uploadImage<T>(
      context: context,
      uploadOperation: operation,
      imageName: fileName,
    );
  }

  /// Pattern para login
  static Future<T> loginUser<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? userName,
  }) {
    return UnifiedFeedbackSystem.login<T>(
      context: context,
      loginOperation: operation,
      userName: userName,
    );
  }

  /// Pattern para compra premium
  static Future<T> purchasePremium<T>({
    required BuildContext context,
    required Future<T> Function() operation,
  }) {
    return UnifiedFeedbackSystem.purchasePremium<T>(
      context: context,
      purchaseOperation: operation,
    );
  }

  /// Pattern para sync de dados
  static Future<T> syncData<T>({
    required BuildContext context,
    required Future<T> Function() operation,
  }) {
    return UnifiedFeedbackSystem.sync<T>(
      context: context,
      syncOperation: operation,
    );
  }

  /// Pattern para backup
  static Future<T> backupData<T>({
    required BuildContext context,
    required Future<T> Function(void Function(double, String?) onProgress)
    operation,
  }) {
    return UnifiedFeedbackSystem.backup<T>(
      context: context,
      backupOperation: operation,
    );
  }
}

/// Utility class for quick feedback shortcuts
final class QuickFeedback {
  QuickFeedback._();

  /// Toast de sucesso rápido
  static void success(BuildContext context, String message) {
    UnifiedFeedbackSystem.successToast(context, message);
  }

  /// Toast de erro rápido
  static void error(BuildContext context, String message) {
    UnifiedFeedbackSystem.errorToast(context, message);
  }

  /// Toast de info rápido
  static void info(BuildContext context, String message) {
    UnifiedFeedbackSystem.infoToast(context, message);
  }

  /// Toast de warning rápido
  static void warning(BuildContext context, String message) {
    UnifiedFeedbackSystem.warningToast(context, message);
  }

  /// Confirmação rápida
  static Future<bool> confirm(
    BuildContext context,
    String title,
    String message,
  ) {
    return UnifiedFeedbackSystem.confirm(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Haptic leve
  static Future<void> haptic() => UnifiedFeedbackSystem.lightHaptic();

  /// Haptic médio
  static Future<void> hapticMedium() => UnifiedFeedbackSystem.mediumHaptic();

  /// Haptic pesado
  static Future<void> hapticHeavy() => UnifiedFeedbackSystem.heavyHaptic();
}
