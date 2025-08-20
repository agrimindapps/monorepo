// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'dashboard_constants.dart';

class DashboardHelpers {
  static BorderRadius getCardBorderRadius() {
    return BorderRadius.circular(DashboardConstants.cardBorderRadius);
  }

  static EdgeInsets getDefaultPadding() {
    return const EdgeInsets.all(16);
  }

  static EdgeInsets getCardPadding() {
    return const EdgeInsets.all(16);
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle getCardSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
    );
  }

  static TextStyle getValueStyle() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle getStatLabelStyle() {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[700],
    );
  }

  static TextStyle getStatSubtitleStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    );
  }

  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
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
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
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

  static Widget buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static int getGridColumns(BuildContext context) {
    return MediaQuery.of(context).size.width < 600
        ? DashboardConstants.smallScreenColumns
        : DashboardConstants.largeScreenColumns;
  }

  static double getGridAspectRatio(BuildContext context) {
    return MediaQuery.of(context).size.width < 600
        ? DashboardConstants.smallScreenAspectRatio
        : DashboardConstants.largeScreenAspectRatio;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
