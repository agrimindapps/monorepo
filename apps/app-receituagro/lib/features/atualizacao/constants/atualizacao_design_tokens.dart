import 'package:flutter/material.dart';

/// Design tokens for updates page following consistent design system
class AtualizacaoDesignTokens {
  // Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  
  // Latest Version Colors
  static const Color latestVersionBackgroundLight = Color(0xFFC8E6C9);
  static const Color latestVersionBorderLight = Color(0xFF66BB6A);
  static const Color latestVersionBadgeColor = Color(0xFF43A047);
  static const Color latestVersionIconColor = Color(0xFF388E3C);
  
  // Standard Version Colors
  static const Color standardBackgroundLight = Color(0xFFF5F5F5);
  static const Color standardBorderLight = Color(0xFFE0E0E0);
  static const Color standardBackgroundDark = Color(0xFF424242);
  static const Color standardBorderDark = Color(0xFF616161);
  
  // Card Colors
  static const Color cardBackgroundLight = Color(0xFFF5F5F5);
  static const Color cardBackgroundDark = Color(0xFF1E1E22);
  
  // Text Colors
  static const Color textPrimaryLight = Colors.black;
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryLight = Color(0xFF424242);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  
  // Icons
  static const IconData branchIcon = Icons.code;
  static const IconData newReleaseIcon = Icons.new_releases;
  static const IconData updateIcon = Icons.system_update;
  static const IconData historyIcon = Icons.history;
  static const IconData errorIcon = Icons.error_outline;
  
  // Dimensions
  static const double maxPageWidth = 1120.0;
  static const double cardBorderRadius = 12.0;
  static const double badgeBorderRadius = 8.0;
  static const double iconContainerSize = 40.0;
  static const double iconSize = 24.0;
  static const double emptyStateIconSize = 48.0;
  
  // Spacing
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
  static const EdgeInsets emptyStatePadding = EdgeInsets.all(40.0);
  
  // Text Styles
  static TextStyle getVersionTitleStyle(BuildContext context, {bool isLatest = false}) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: isLatest 
          ? latestVersionIconColor 
          : Theme.of(context).colorScheme.onSurface,
    ) ?? const TextStyle(fontWeight: FontWeight.w600);
  }

  static TextStyle getReleaseNotesStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: isDark ? textSecondaryDark : textSecondaryLight,
      height: 1.3,
    ) ?? const TextStyle(height: 1.3);
  }

  static const TextStyle badgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static TextStyle getEmptyStateTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    ) ?? const TextStyle();
  }

  static TextStyle getEmptyStateSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    ) ?? const TextStyle();
  }

  // Decorations
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardBackgroundDark : cardBackgroundLight,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getVersionIconDecoration(
    BuildContext context, {
    bool isLatest = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isLatest 
          ? latestVersionBackgroundLight
          : (isDark ? standardBackgroundDark : standardBackgroundLight),
      border: Border.all(
        color: isLatest 
            ? latestVersionBorderLight
            : (isDark ? standardBorderDark : standardBorderLight),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    );
  }

  static BoxDecoration getBadgeDecoration() {
    return BoxDecoration(
      color: latestVersionBadgeColor,
      borderRadius: BorderRadius.circular(badgeBorderRadius),
    );
  }

  // Helper methods
  static Color getVersionIconColor(BuildContext context, {bool isLatest = false}) {
    return isLatest 
        ? latestVersionIconColor 
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
  }

  static IconData getVersionIcon({bool isLatest = false}) {
    return isLatest ? newReleaseIcon : updateIcon;
  }

  // Messages
  static const String pageTitle = 'Atualizações';
  static const String pageSubtitle = 'Histórico de versões do aplicativo';
  static const String latestVersionBadge = 'ATUAL';
  static const String emptyStateTitle = 'Nenhuma atualização disponível';
  static const String emptyStateSubtitle = 'O histórico de versões será exibido aqui';
  static const String loadingMessage = 'Carregando atualizações...';
  static const String errorLoadingMessage = 'Erro ao carregar atualizações';
}