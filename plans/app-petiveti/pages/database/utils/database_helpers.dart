// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pluto_grid/pluto_grid.dart';

// Project imports:
import 'database_constants.dart';

class DatabaseHelpers {
  static String formatFieldName(String fieldName) {
    return DatabaseConstants.getFieldDisplayName(fieldName);
  }

  static double getColumnWidth(String fieldName) {
    return DatabaseConstants.getColumnWidth(fieldName);
  }

  static TextStyle getCellTextStyle() {
    return DatabaseConstants.cellTextStyle;
  }

  static TextStyle getColumnTextStyle() {
    return DatabaseConstants.columnTextStyle;
  }

  static double getRowHeight() {
    return DatabaseConstants.rowHeight;
  }

  static double getColumnHeight() {
    return DatabaseConstants.columnHeight;
  }

  static Color getGridBorderColor() {
    return DatabaseConstants.gridBorderColor;
  }

  static Color getGridBackgroundColor() {
    return DatabaseConstants.gridBackgroundColor;
  }

  static Color getActivatedBorderColor() {
    return DatabaseConstants.activatedBorderColor;
  }

  static Color getActivatedColor() {
    return DatabaseConstants.activatedColor;
  }

  static Widget buildGridFooter(PlutoGridStateManager stateManager) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: DatabaseConstants.headerBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total de registros: ${stateManager.rows.length}',
            style: DatabaseConstants.footerTextStyle,
          ),
          if (stateManager.hasFilter)
            Text(
              'Filtrados: ${stateManager.refRows.length}',
              style: DatabaseConstants.footerTextStyle.copyWith(
                color: Colors.blue[600],
              ),
            ),
        ],
      ),
    );
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(DatabaseConstants.loadingMessage),
          ],
        ),
      ),
    );
  }

  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  static BorderRadius getCardBorderRadius() {
    return BorderRadius.circular(DatabaseConstants.cardBorderRadius);
  }

  static EdgeInsets getDefaultPadding() {
    return const EdgeInsets.all(16.0);
  }

  static EdgeInsets getCardPadding() {
    return const EdgeInsets.all(16.0);
  }

  static InputDecoration getSearchDecoration() {
    return InputDecoration(
      hintText: DatabaseConstants.searchPlaceholder,
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      suffixIcon: const Icon(Icons.clear),
    );
  }

  static InputDecoration getDropdownDecoration() {
    return const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String formatRecordCount(int count) {
    if (count == 0) return 'Nenhum registro';
    if (count == 1) return '1 registro';
    return '$count registros';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static List<T> debounce<T>(List<T> items, Duration delay) {
    // Simple debounce implementation for search
    return items;
  }

  static bool isValidSearchTerm(String term) {
    return term.isNotEmpty && term.trim().length >= 2;
  }

  static String sanitizeSearchTerm(String term) {
    return term.trim().toLowerCase();
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
      case 'completo':
      case 'sucesso':
        return Colors.green;
      case 'pendente':
      case 'aguardando':
        return Colors.orange;
      case 'inativo':
      case 'erro':
      case 'falha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getBoxTypeIcon(String boxType) {
    switch (boxType.toLowerCase()) {
      case 'animais':
        return Icons.pets;
      case 'consultas':
        return Icons.medical_services;
      case 'despesas':
        return Icons.receipt_long;
      case 'lembretes':
        return Icons.notifications;
      case 'medicamentos':
        return Icons.medication;
      case 'pesos':
        return Icons.monitor_weight;
      case 'vacinas':
        return Icons.vaccines;
      default:
        return Icons.storage;
    }
  }
}
