import 'package:flutter/material.dart';

/// Design tokens extraídos do mockup IMG_3186.PNG para implementação pixel-perfect
/// dos diagnósticos de pragas no ReceitaAgro
/// 
/// Responsabilidade: centralizar constantes visuais para consistência
class DiagnosticoMockupTokens {
  // ========================================
  // CORES EXTRAÍDAS DO MOCKUP
  // ========================================
  
  /// Verde principal usado em ícones e elementos de destaque
  static const Color primaryGreen = Color(0xFF4CAF50);
  
  /// Background branco dos cards de diagnósticos
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// Background cinza claro das seções de cultura
  static const Color sectionBackground = Color(0xFFF5F5F5);
  
  /// Texto principal preto
  static const Color textPrimary = Color(0xFF212121);
  
  /// Texto secundário cinza (ingrediente ativo)
  static const Color textSecondary = Color(0xFF757575);
  
  /// Texto terciário cinza claro (dosagem)
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  /// Cor do ícone premium amarelo
  static const Color premiumWarning = Color(0xFFFFA726);
  
  /// Cor do chevron de navegação
  static const Color chevronColor = Color(0xFF757575);
  
  /// Cor da borda dos campos de filtro
  static const Color filterBorderColor = Color(0xFFE0E0E0);
  
  // ========================================
  // DIMENSÕES EXTRAÍDAS DO MOCKUP
  // ========================================
  
  /// Altura dos cards de diagnóstico
  static const double cardHeight = 80.0;
  
  /// Border radius dos cards
  static const double cardBorderRadius = 12.0;
  
  /// Border radius das seções de cultura
  static const double sectionBorderRadius = 8.0;
  
  /// Tamanho do ícone principal dos cards
  static const double cardIconSize = 40.0;
  
  /// Tamanho do ícone da seção (folha)
  static const double sectionIconSize = 18.0;
  
  /// Tamanho do ícone premium
  static const double premiumIconSize = 16.0;
  
  /// Tamanho do chevron
  static const double chevronSize = 20.0;
  
  /// Padding interno dos cards
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  /// Padding das seções de cultura
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 16.0, 
    vertical: 12.0,
  );
  
  /// Margin entre cards
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12.0);
  
  /// Margin das seções
  static const EdgeInsets sectionMargin = EdgeInsets.only(bottom: 8.0);
  
  /// Espaçamento entre elementos internos do card
  static const double cardInternalSpacing = 12.0;
  
  /// Espaçamento entre seção e primeiro card
  static const double sectionToCardSpacing = 16.0;
  
  /// Altura dos campos de filtro
  static const double filterHeight = 48.0;
  
  /// Padding dos filtros
  static const EdgeInsets filterPadding = EdgeInsets.symmetric(horizontal: 16.0);
  
  // ========================================
  // TIPOGRAFIA BASEADA NO MOCKUP
  // ========================================
  
  /// Estilo do nome do produto no card
  static const TextStyle cardProductNameStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.25,
  );
  
  /// Estilo do ingrediente ativo no card
  static const TextStyle cardIngredientStyle = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.23,
  );
  
  /// Estilo da dosagem no card
  static const TextStyle cardDosageStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.33,
  );
  
  /// Estilo do texto da seção de cultura
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.25,
  );
  
  /// Estilo do placeholder dos filtros
  static const TextStyle filterHintStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
  
  // ========================================
  // SHADOWS E ELEVAÇÕES
  // ========================================
  
  /// Shadow sutil dos cards com melhorias visuais baseadas no detalhe de defensivos
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x19000000), // 10% opacity black para melhor profundidade
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity black para sombra secundária
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Shadow para cards com foco
  static const List<BoxShadow> cardFocusedShadow = [
    BoxShadow(
      color: Color(0x1A4CAF50), // Verde com transparência para foco
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
  
  // ========================================
  // ÍCONES ESPECÍFICOS
  // ========================================
  
  /// Ícone usado no card de diagnóstico (químico/pesticida)
  static const IconData cardIcon = Icons.science;
  
  /// Ícone da seção de cultura (folha)
  static const IconData sectionIcon = Icons.eco;
  
  /// Ícone de pesquisa nos filtros
  static const IconData searchIcon = Icons.search;
  
  /// Ícone do dropdown dos filtros
  static const IconData dropdownIcon = Icons.calendar_today;
  
  /// Ícone premium (alerta)
  static const IconData premiumIcon = Icons.warning;
  
  /// Ícone de navegação (chevron)
  static const IconData chevronIcon = Icons.chevron_right;
  
  // ========================================
  // STRINGS ESPECÍFICAS
  // ========================================
  
  /// Text placeholder para dosagem premium
  static const String hiddenDosage = '••• mg/L';
  
  /// Text base para dosagem
  static const String dosagePrefix = 'Dosagem: ';
  
  /// Text placeholder campo de busca
  static const String searchPlaceholder = 'Localizar';
  
  /// Text padrão do dropdown
  static const String dropdownDefaultValue = 'Todas';
  
  // ========================================
  // DURAÇÃO DE ANIMAÇÕES
  // ========================================
  
  /// Duração padrão para animações de filtro
  static const Duration filterAnimationDuration = Duration(milliseconds: 200);
  
  /// Duração para feedback visual de tap
  static const Duration tapFeedbackDuration = Duration(milliseconds: 150);

  /// Duração para animações de focus
  static const Duration focusAnimationDuration = Duration(milliseconds: 250);

  // ========================================
  // HELPERS THEME-AWARE
  // ========================================

  /// Retorna shadow adequada baseada no tema do contexto
  static List<BoxShadow> getCardShadow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (isDark) {
      return [
        BoxShadow(
          color: theme.shadowColor.withAlpha(51), // 20% opacity no tema escuro
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    
    return cardShadow;
  }

  /// Retorna cor de background adequada para cards baseada no tema
  static Color getCardBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.cardColor;
  }

  /// Retorna cor de texto adequada baseada no tema
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final theme = Theme.of(context);
    return isSecondary 
      ? theme.textTheme.bodyMedium?.color?.withAlpha(153) ?? textSecondary
      : theme.textTheme.bodyLarge?.color ?? textPrimary;
  }
}