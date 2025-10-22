import 'package:flutter/material.dart';

/// Design tokens centralizados para funcionalidades Premium
/// Padroniza mensagens, estilos e comportamentos em todo o app
class PremiumDesignTokens {
  PremiumDesignTokens._(); // Private constructor prevents instantiation

  // ==================== MENSAGENS ====================

  /// Mensagens padrão para bloqueios premium
  static const String featureRequiredTitle = 'Recurso Premium';
  static const String featureRequiredMessage =
      'Este recurso está disponível apenas para assinantes do app.';

  /// Mensagens específicas por feature
  static const Map<String, String> featureTitles = {
    'comentarios': 'Comentários Premium',
    'favoritos_diagnosticos': 'Diagnósticos Favoritos não disponíveis',
    'favoritos_defensivos': 'Defensivos Favoritos não disponíveis',
    'favoritos_pragas': 'Pragas Favoritas não disponíveis',
    'sync': 'Sincronização Premium',
    'export': 'Exportação Premium',
  };

  /// Botões de ação
  static const String upgradeButtonText = 'Desbloquear Agora';
  static const String previewButtonText = 'Ver Prévia';
  static const String learnMoreButtonText = 'Saiba Mais';

  /// Mensagens de limite atingido
  static const String limitReachedTitle = 'Limite Atingido';
  static String getLimitReachedMessage(String feature, int limit) =>
      'Você atingiu o limite de $limit $feature na versão gratuita.';

  // ==================== CORES ====================

  /// Cores do card premium
  static const Color premiumCardBackground = Color(0xFFFFF3E0);
  static const Color premiumCardBorder = Color(0xFFFFB74D);
  static const Color premiumIconColor = Color(0xFFFF9800);
  static const Color premiumTitleColor = Color(0xFFE65100);
  static const Color premiumDescriptionColor = Color(0xFFBF360C);
  static const Color premiumButtonBackground = Color(0xFFFF9800);
  static const Color premiumButtonForeground = Colors.white;

  /// Cores de badge
  static const Color premiumBadgeColor = Color(0xFFFFD700);
  static const Color activeBadgeColor = Color(0xFF4CAF50);

  // ==================== ÍCONES ====================

  /// Ícones padrão premium
  static const IconData lockIcon = Icons.lock;
  static const IconData diamondIcon = Icons.diamond;
  static const IconData rocketIcon = Icons.rocket_launch;
  static const IconData starIcon = Icons.star;

  // ==================== ESTILOS DE TEXTO ====================

  /// Estilo do título do card premium
  static const TextStyle premiumTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: premiumTitleColor,
  );

  /// Estilo da descrição do card premium
  static const TextStyle premiumDescriptionStyle = TextStyle(
    fontSize: 16,
    color: premiumDescriptionColor,
  );

  /// Estilo do botão de upgrade
  static const TextStyle upgradeButtonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: premiumButtonForeground,
  );

  // ==================== DIMENSÕES ====================

  /// Dimensões do card premium
  static const double premiumCardWidth = 280;
  static const double premiumCardMargin = 8.0;
  static const double premiumCardPadding = 8.0;
  static const double premiumCardBorderRadius = 16;
  static const double premiumCardBorderWidth = 1;

  /// Tamanhos de ícone
  static const double premiumIconSize = 48;
  static const double buttonIconSize = 20;

  /// Espaçamentos
  static const double verticalSpacingSmall = 8;
  static const double verticalSpacingMedium = 16;
  static const double verticalSpacingLarge = 24;

  // ==================== NAVEGAÇÃO ====================

  /// Rotas de navegação premium
  static const String subscriptionRoute = '/subscription';

  // ==================== ANALYTICS ====================

  /// Eventos de analytics premium
  static const String premiumAttemptEvent = 'premium_feature_attempted';
  static const String premiumUpgradeClickedEvent = 'premium_upgrade_clicked';
  static const String premiumPreviewClickedEvent = 'premium_preview_clicked';

  // ==================== HELPERS ====================

  /// Retorna a decoração padrão do card premium
  static BoxDecoration getPremiumCardDecoration() {
    return BoxDecoration(
      color: premiumCardBackground,
      borderRadius: BorderRadius.circular(premiumCardBorderRadius),
      border: Border.all(
        color: premiumCardBorder,
        width: premiumCardBorderWidth,
      ),
    );
  }

  /// Retorna o estilo padrão do botão de upgrade
  static ButtonStyle getUpgradeButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: premiumButtonBackground,
      foregroundColor: premiumButtonForeground,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );
  }

  /// Retorna o ícone premium padrão
  static Widget getPremiumIcon() {
    return const Icon(
      diamondIcon,
      size: premiumIconSize,
      color: premiumIconColor,
    );
  }

  /// Retorna o ícone do botão de upgrade
  static Widget getUpgradeButtonIcon() {
    return const Icon(
      rocketIcon,
      color: premiumButtonForeground,
      size: buttonIconSize,
    );
  }
}
