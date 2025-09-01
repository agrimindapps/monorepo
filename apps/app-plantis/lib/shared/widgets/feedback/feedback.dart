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

library feedback;

import 'package:flutter/material.dart';

import '../loading/contextual_loading_manager.dart';
import 'feedback_system.dart';
import 'unified_feedback_system.dart';

// Loading integration
export '../loading/contextual_loading_manager.dart';
export 'animated_feedback.dart';
export 'confirmation_system.dart';
// Individual components
export 'feedback_system.dart';
export 'haptic_service.dart';
export 'progress_tracker.dart';
export 'toast_service.dart';
// Core system
export 'unified_feedback_system.dart';

// Pre-defined contexts for common operations
class FeedbackOperations {
  // Tasks
  static const String taskComplete = 'task_complete';
  static const String taskCreate = 'task_create';
  static const String taskDelete = 'task_delete';
  
  // Plants
  static const String plantSave = 'plant_save';
  static const String plantUpdate = 'plant_update';
  static const String plantDelete = 'plant_delete';
  static const String plantWater = 'plant_water';
  
  // Premium
  static const String premiumPurchase = 'premium_purchase';
  static const String premiumRestore = 'premium_restore';
  static const String premiumCancel = 'premium_cancel';
  
  // Auth
  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'register';
  
  // Data
  static const String sync = 'sync';
  static const String backup = 'backup';
  static const String restore = 'restore';
  static const String upload = 'upload';
  
  // Settings
  static const String saveSettings = 'save_settings';
  static const String resetData = 'reset_data';
}

// Common feedback patterns
class FeedbackPatterns {
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
      successMessage: isUpdate 
          ? '$itemName atualizado!' 
          : '$itemName salvo!',
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
    // Confirmação
    if (requireConfirmation) {
      final confirmed = await UnifiedFeedbackSystem.confirmDestruction(
        context: context,
        title: 'Deletar $itemType',
        message: 'Tem certeza que deseja remover "$itemName"?',
        requireDouble: true,
      );
      
      if (!confirmed) return false;
    }
    
    // Executar operação
    await UnifiedFeedbackSystem.executeWithFeedback<void>(
      context: context,
      operationKey: 'delete_${itemName}_${DateTime.now().millisecondsSinceEpoch}',
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
    required Future<T> Function(Function(double, String?) onProgress) operation,
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
    required Future<T> Function(Function(double, String?) onProgress) operation,
  }) {
    return UnifiedFeedbackSystem.backup<T>(
      context: context,
      backupOperation: operation,
    );
  }
}

// Quick access helpers
class QuickFeedback {
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

