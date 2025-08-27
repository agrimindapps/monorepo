import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calorie_dialog_manager.dart';

/// Menu actions handler for Calorie Calculator
/// 
/// Responsibilities:
/// - Handle menu action selection
/// - Coordinate with dialog manager
/// - Keep menu logic separate from main page
class CalorieMenuHandler {
  final CalorieDialogManager dialogManager;
  final WidgetRef ref;
  final VoidCallback? onPresetLoaded;
  final VoidCallback? onReset;
  final VoidCallback? onHistoryItemSelected;

  CalorieMenuHandler({
    required this.dialogManager,
    required this.ref,
    this.onPresetLoaded,
    this.onReset,
    this.onHistoryItemSelected,
  });

  /// Handle menu action selection
  void handleMenuAction(String action) {
    switch (action) {
      case 'presets':
        _handlePresetsAction();
        break;
      case 'reset':
        _handleResetAction();
        break;
      case 'history':
        _handleHistoryAction();
        break;
      case 'export':
        _handleExportAction();
        break;
      case 'help':
        _handleHelpAction();
        break;
      default:
        // Unknown action - could log or handle gracefully
        break;
    }
  }

  /// Handle presets menu action
  void _handlePresetsAction() {
    dialogManager.showPresetsDialog(
      onPresetLoaded: onPresetLoaded,
    );
  }

  /// Handle reset menu action
  void _handleResetAction() {
    dialogManager.showResetDialog(
      onReset: onReset,
    );
  }

  /// Handle history menu action
  void _handleHistoryAction() {
    dialogManager.showHistoryDialog(
      onHistoryItemSelected: onHistoryItemSelected,
    );
  }

  /// Handle export menu action
  void _handleExportAction() {
    dialogManager.showExportDialog();
  }

  /// Handle help menu action
  void _handleHelpAction() {
    dialogManager.showCalorieGuide();
  }

  /// Get menu items for PopupMenuButton
  List<PopupMenuEntry<String>> getMenuItems() {
    return [
      const PopupMenuItem(
        value: 'presets',
        child: ListTile(
          leading: Icon(Icons.speed),
          title: Text('Presets Rápidos'),
          dense: true,
        ),
      ),
      const PopupMenuItem(
        value: 'reset',
        child: ListTile(
          leading: Icon(Icons.refresh),
          title: Text('Resetar'),
          dense: true,
        ),
      ),
      const PopupMenuItem(
        value: 'history',
        child: ListTile(
          leading: Icon(Icons.history),
          title: Text('Histórico'),
          dense: true,
        ),
      ),
      const PopupMenuItem(
        value: 'export',
        child: ListTile(
          leading: Icon(Icons.share),
          title: Text('Exportar'),
          dense: true,
        ),
      ),
    ];
  }

  /// Dispose of resources
  void dispose() {
    // No resources to dispose in this handler
  }
}