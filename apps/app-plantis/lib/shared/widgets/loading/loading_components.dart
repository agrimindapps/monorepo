
import 'package:flutter/material.dart';

import 'contextual_loading_manager.dart';
import 'error_recovery.dart';
import 'loading_button.dart';
import 'save_indicator.dart';
import 'skeleton_loader.dart';

export 'contextual_loading_manager.dart';
export 'error_recovery.dart';
export 'loading_button.dart';
export 'save_indicator.dart';
export 'skeleton_loader.dart';

/// Quick access constants for common loading contexts
class LoadingConstants {
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration mediumTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(minutes: 2);
  static const Duration quickDelay = Duration(milliseconds: 300);
  static const Duration standardDelay = Duration(milliseconds: 500);
  static const Duration slowDelay = Duration(seconds: 1);
  static const int defaultSkeletonCount = 3;
  static const int listSkeletonCount = 5;
  static const int gridSkeletonCount = 6;
}

/// Utility class for common loading operations
class LoadingUtils {
  /// Shows a contextual loading with automatic timeout
  static void showLoadingWithTimeout(
    String context, {
    required String message,
    String? semanticLabel,
    LoadingType type = LoadingType.standard,
    Duration timeout = LoadingConstants.mediumTimeout,
  }) {
    ContextualLoadingManager.startLoading(
      context,
      message: message,
      semanticLabel: semanticLabel,
      type: type,
      timeout: timeout,
    );
  }

  /// Shows loading for save operations
  static void showSaveLoading(String context, {String? itemName}) {
    showLoadingWithTimeout(
      context,
      message:
          itemName != null ? 'Salvando $itemName...' : 'Salvando alterações...',
      semanticLabel:
          itemName != null ? 'Salvando $itemName' : 'Salvando alterações',
      type: LoadingType.save,
    );
  }

  /// Shows loading for purchase operations
  static void showPurchaseLoading(String context, {String? productName}) {
    showLoadingWithTimeout(
      context,
      message:
          productName != null
              ? 'Processando compra de $productName...'
              : 'Processando compra...',
      semanticLabel:
          productName != null
              ? 'Processando compra de $productName'
              : 'Processando compra',
      type: LoadingType.purchase,
      timeout: LoadingConstants.longTimeout, // Purchases may take longer
    );
  }

  /// Shows loading for sync operations
  static void showSyncLoading(String context, {String? syncType}) {
    showLoadingWithTimeout(
      context,
      message:
          syncType != null
              ? 'Sincronizando $syncType...'
              : 'Sincronizando dados...',
      semanticLabel:
          syncType != null ? 'Sincronizando $syncType' : 'Sincronizando dados',
      type: LoadingType.sync,
    );
  }

  /// Shows loading for auth operations
  static void showAuthLoading(String context, {required String operation}) {
    showLoadingWithTimeout(
      context,
      message: operation,
      semanticLabel: 'Executando operação de autenticação: $operation',
      type: LoadingType.auth,
    );
  }

  /// Stops loading for a specific context
  static void stopLoading(String context) {
    ContextualLoadingManager.stopLoading(context);
  }

  /// Stops all active loadings
  static void stopAllLoadings() {
    ContextualLoadingManager.stopAllLoadings();
  }
}

/// Pre-configured loading widgets for common scenarios
class LoadingPresets {
  /// Standard loading button for forms
  static Widget saveButton({
    required Future<void> Function() onSave,
    String? text,
    bool enabled = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    return SaveButton(
      onSave: onSave,
      text: text,
      enabled: enabled,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Purchase button with loading states
  static Widget purchaseButton({
    required Future<void> Function() onPurchase,
    required String productName,
    required String price,
    bool enabled = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    return PurchaseButton(
      onPurchase: onPurchase,
      productName: productName,
      price: price,
      enabled: enabled,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Sync button for data synchronization
  static Widget syncButton({
    required Future<void> Function() onSync,
    String? text,
    bool enabled = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    return SyncButton(
      onSync: onSync,
      text: text,
      enabled: enabled,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Plant list skeleton for loading states
  static Widget plantListSkeleton({
    int count = LoadingConstants.defaultSkeletonCount,
  }) {
    return PlantListSkeleton(itemCount: count, isLoading: true);
  }

  /// Task list skeleton for loading states
  static Widget taskListSkeleton({
    int count = LoadingConstants.listSkeletonCount,
  }) {
    return TaskListSkeleton(itemCount: count, isLoading: true);
  }

  /// Network error recovery widget
  static Widget networkError({
    VoidCallback? onRetry,
    VoidCallback? onOfflineMode,
    bool isOffline = false,
  }) {
    return NetworkErrorRecovery(
      onRetry: onRetry,
      onOfflineMode: onOfflineMode,
      isOffline: isOffline,
    );
  }

  /// Form error recovery widget
  static Widget formErrors({
    required Map<String, String> errors,
    VoidCallback? onFix,
  }) {
    return FormErrorRecovery(fieldErrors: errors, onFixErrors: onFix);
  }

  /// Auto-save indicator
  static Widget autoSave({
    required bool hasChanges,
    required Future<void> Function() onSave,
    Duration debounceDelay = const Duration(seconds: 2),
    String? statusText,
  }) {
    return AutoSaveIndicator(
      hasChanges: hasChanges,
      onSave: onSave,
      debounceDelay: debounceDelay,
      statusText: statusText,
    );
  }

  /// Save indicator with manual save
  static Widget saveIndicator({
    bool isSaving = false,
    bool hasChanges = false,
    VoidCallback? onSave,
    SaveIndicatorStyle style = SaveIndicatorStyle.chip,
  }) {
    return SaveIndicator(
      isSaving: isSaving,
      hasUnsavedChanges: hasChanges,
      onSave: onSave,
      style: style,
    );
  }
}

/// Mixin that combines all loading functionality for pages
mixin LoadingPageMixin<T extends StatefulWidget> on State<T> {
  void startContextualLoading(
    String context, {
    required String message,
    String? semanticLabel,
    LoadingType type = LoadingType.standard,
    Duration? timeout = const Duration(seconds: 30),
  }) {
    LoadingUtils.showLoadingWithTimeout(
      context,
      message: message,
      semanticLabel: semanticLabel,
      type: type,
      timeout: timeout ?? LoadingConstants.mediumTimeout,
    );
  }

  void stopContextualLoading(String context) {
    LoadingUtils.stopLoading(context);
  }

  bool hasContextualLoading(String context) {
    return ContextualLoadingManager.hasActiveLoading(context);
  }

  /// Convenience method for save operations
  void startSaveLoading({String? itemName}) {
    LoadingUtils.showSaveLoading(LoadingContexts.plantSave, itemName: itemName);
  }

  /// Convenience method for purchase operations
  void startPurchaseLoading({String? productName}) {
    LoadingUtils.showPurchaseLoading(
      LoadingContexts.premium,
      productName: productName,
    );
  }

  /// Convenience method for sync operations
  void startSyncLoading({String? syncType}) {
    LoadingUtils.showSyncLoading(LoadingContexts.sync, syncType: syncType);
  }

  /// Convenience method for auth operations
  void startAuthLoading({required String operation}) {
    LoadingUtils.showAuthLoading(LoadingContexts.auth, operation: operation);
  }

  /// Stop loading for common contexts
  void stopSaveLoading() => stopContextualLoading(LoadingContexts.plantSave);
  void stopPurchaseLoading() => stopContextualLoading(LoadingContexts.premium);
  void stopSyncLoading() => stopContextualLoading(LoadingContexts.sync);
  void stopAuthLoading() => stopContextualLoading(LoadingContexts.auth);

  /// Stop all loadings (cleanup method)
  void stopAllLoadings() => LoadingUtils.stopAllLoadings();

  void disposeLoadings() {
    stopAllLoadings();
  }
}
