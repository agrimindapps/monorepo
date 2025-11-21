import 'package:flutter/material.dart';

class SettingsDesignTokens {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successBackgroundColor = Color(0x1A4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color errorBackgroundColor = Color(0x1AE53935);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color premiumColor = Color(0xFFFFD700);
  static const Color developmentColor = Color(0xFF2196F3);
  static const IconData configIcon = Icons.settings;
  static const IconData premiumIcon = Icons.workspace_premium;
  static const IconData adIcon = Icons.monetization_on;
  static const IconData webIcon = Icons.public;
  static const IconData speechIcon = Icons.mic;
  static const IconData infoIcon = Icons.info;
  static const IconData devIcon = Icons.code;
  static const IconData themeIcon = Icons.dark_mode;
  static const IconData themeLightIcon = Icons.light_mode;
  static const IconData checkIcon = Icons.check_circle;
  static const IconData removeIcon = Icons.remove_circle;
  static const IconData verifiedIcon = Icons.verified_user;
  static const IconData circleInfoIcon = Icons.info_outline;
  static const IconData volumeIcon = Icons.volume_up;
  static const IconData paletteIcon = Icons.nightlight_round;
  static const IconData systemThemeIcon = Icons.auto_mode;
  static const IconData deviceManagementIcon = Icons.devices;
  static const EdgeInsets sectionMargin = EdgeInsets.symmetric(vertical: 4.0);
  static const EdgeInsets sectionHeaderPadding = EdgeInsets.fromLTRB(16, 16, 16, 8);
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
  static const double sectionIconSize = 20.0;
  static const double maxPageWidth = 1120.0;
  static const double cardBorderRadius = 12.0;
  static const double iconContainerRadius = 8.0;
  static const double sectionSpacing = 16.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(8.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
  static const EdgeInsets iconPadding = EdgeInsets.all(8.0);
  static TextStyle getSectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ) ?? const TextStyle(fontWeight: FontWeight.w600);
  }

  static TextStyle getListTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle(fontWeight: FontWeight.w500);
  }

  static TextStyle getListSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    ) ?? const TextStyle();
  }
  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration getSuccessIconDecoration() {
    return BoxDecoration(
      color: successBackgroundColor,
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }

  static BoxDecoration getErrorIconDecoration() {
    return BoxDecoration(
      color: errorBackgroundColor,
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }

  static BoxDecoration getDevelopmentIconDecoration() {
    return BoxDecoration(
      color: developmentColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }
  static SnackBar getSuccessSnackbar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(checkIcon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: successColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static SnackBar getErrorSnackbar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: errorColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static SnackBar getWarningSnackbar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: warningColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  static const String testSubscriptionSuccess = 'Assinatura local gerada com sucesso! Status premium ativo por 30 dias.';
  static const String testSubscriptionRemoved = 'Assinatura local removida com sucesso! Status premium desativado.';
  static const String testSubscriptionError = 'Falha ao gerar assinatura de teste';
  static const String removeSubscriptionError = 'Falha ao remover assinatura de teste';
  static const String siteUrl = 'receituagro.agrimind.com.br';
  static const String developmentSectionTitle = 'Ferramentas de Desenvolvimento';
  static const String generateTestSubscription = 'Gerar Assinatura Local';
  static const String generateTestSubscriptionDesc = 'Cria uma assinatura local para testes';
  static const String removeTestSubscription = 'Remover Assinatura Local';
  static const String removeTestSubscriptionDesc = 'Remove a assinatura local de testes';
}
