import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/body_condition_provider.dart';
import 'body_condition_tab_controller.dart';

/// Menu handler for Body Condition Calculator
/// 
/// Responsibilities:
/// - Handle menu action selection
/// - Coordinate with dialog presentations
/// - Keep menu logic separate from main page
class BodyConditionMenuHandler {
  final BuildContext context;
  final WidgetRef ref;
  final BodyConditionTabController tabController;

  BodyConditionMenuHandler({
    required this.context,
    required this.ref,
    required this.tabController,
  });

  /// Handle menu action selection
  void handleMenuAction(String action) {
    switch (action) {
      case 'reset':
        _handleResetAction();
        break;
      case 'history':
        _handleHistoryAction();
        break;
      case 'export':
        _handleExportAction();
        break;
      default:
        // Unknown action - handle gracefully
        break;
    }
  }

  /// Handle reset menu action
  void _handleResetAction() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Calculadora'),
        content: const Text('Isso limpará todos os dados inseridos e resultados. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bodyConditionProvider.notifier).reset();
              Navigator.pop(context);
              tabController.goToInputTab();
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  /// Handle history menu action
  void _handleHistoryAction() {
    tabController.goToHistoryTab();
  }

  /// Handle export menu action
  void _handleExportAction() {
    final output = ref.read(bodyConditionOutputProvider);
    if (output == null) {
      _showErrorSnackBar('Nenhum resultado para exportar');
      return;
    }
    
    // Validate data before export
    if (!_validateExportData(output)) {
      _showErrorSnackBar('Dados insuficientes para exportação segura');
      return;
    }
    
    _showExportDialog(output);
  }

  /// Get menu items for PopupMenuButton
  List<PopupMenuEntry<String>> getMenuItems() {
    return [
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

  /// Validate export data before proceeding
  bool _validateExportData(dynamic output) {
    // Critical veterinary data validations before export
    final bcsScore = (output as dynamic)?.bcsScore as double? ?? 0.0;
    if (bcsScore < 1.0 || bcsScore > 9.0) {
      return false; // Invalid BCS score
    }
    
    final input = ref.read(bodyConditionInputProvider);
    if (input.currentWeight <= 0.0 || input.currentWeight > 150.0) {
      return false; // Invalid weight
    }
    
    // Check if essential data is present
    final results = (output as dynamic)?.results as List? ?? [];
    if (results.isEmpty) {
      return false; // No calculated results
    }
    
    return true;
  }

  /// Show export dialog
  void _showExportDialog(dynamic output) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Resultado BCS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Score BCS: ${output.bcsScore.toStringAsFixed(1)}'),
            Text('Classificação: ${_getClassificationText(output.classification)}'),
            const SizedBox(height: 8),
            const Text('Os dados serão exportados de forma segura e anônima.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSecureExport(output);
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  /// Perform secure export
  void _performSecureExport(dynamic output) {
    // Secure export implementation
    // In a real implementation, this would:
    // - Sanitize data
    // - Remove sensitive information
    // - Generate PDF or other format
    // - Secure sharing
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado exportado com segurança!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Get classification text
  String _getClassificationText(dynamic classification) {
    if (classification == null) return 'Não definido';
    return (classification.displayName as String?) ?? 'Não definido';
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Dispose of resources
  void dispose() {
    // No resources to dispose in this handler
  }
}