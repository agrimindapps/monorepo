// Flutter imports:
import 'package:flutter/material.dart';

/// Enum para representar diferentes tamanhos de tela
enum ScreenSize { small, medium, large, extraLarge }

/// Constantes de layout e design para o jogo Caça Palavras
///
/// REFATORAÇÃO CONCLUÍDA:
/// - Centralizou todas as configurações de layout do jogo
/// - Padronizou espaçamentos, tamanhos e proporções
/// - Facilitou manutenção e consistência visual
/// - Possibilitou mudanças globais de design
/// - Adicionado suporte a responsividade para diferentes tamanhos de tela

class GameLayout {
  // ========== Breakpoints para Responsividade ==========
  
  /// Largura mínima para telas pequenas (telefones)
  static const double smallScreenWidth = 600.0;
  
  /// Largura mínima para telas médias (tablets)
  static const double mediumScreenWidth = 900.0;
  
  /// Largura mínima para telas grandes (desktops)
  static const double largeScreenWidth = 1200.0;
  
  /// Determina o tipo de tela baseado na largura
  static ScreenSize getScreenSize(double width) {
    if (width < smallScreenWidth) return ScreenSize.small;
    if (width < mediumScreenWidth) return ScreenSize.medium;
    if (width < largeScreenWidth) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
  
  /// Retorna fator de escala baseado no tamanho da tela
  static double getScaleFactor(double width) {
    final screenSize = getScreenSize(width);
    switch (screenSize) {
      case ScreenSize.small:
        return width < 350 ? 0.8 : 1.0; // Reduz em telas muito pequenas
      case ScreenSize.medium:
        return 1.2;
      case ScreenSize.large:
        return 1.4;
      case ScreenSize.extraLarge:
        return 1.6;
    }
  }
  
  /// Retorna padding responsivo baseado no tamanho da tela
  static EdgeInsets getResponsivePadding(double width) {
    final scaleFactor = getScaleFactor(width);
    final padding = spacingDefault * scaleFactor;
    return EdgeInsets.all(padding);
  }
  
  /// Retorna o flex do grid baseado na orientação
  static int getResponsiveGridFlex(Orientation orientation) {
    return orientation == Orientation.landscape ? 2 : 3;
  }
  
  /// Retorna o flex da lista de palavras baseado na orientação
  static int getResponsiveWordListFlex(Orientation orientation) {
    return orientation == Orientation.landscape ? 2 : 1;
  }
  
  /// Retorna tamanho de fonte responsivo
  static double getResponsiveFontSize(double baseFontSize, double width) {
    final scaleFactor = getScaleFactor(width);
    return baseFontSize * scaleFactor;
  }
  // ========== Espaçamentos ==========

  /// Espaçamento pequeno (4.0)
  static const double spacingSmall = 4.0;

  /// Espaçamento médio (8.0)
  static const double spacingMedium = 8.0;

  /// Espaçamento padrão (16.0)
  static const double spacingDefault = 16.0;

  /// Espaçamento grande (20.0)
  static const double spacingLarge = 20.0;

  /// Espaçamento extra grande (24.0)
  static const double spacingExtraLarge = 24.0;

  /// Espaçamento para seções (32.0)
  static const double spacingSection = 32.0;

  // ========== Padding/Margin ==========

  /// Padding padrão para containers
  static const EdgeInsets paddingDefault = EdgeInsets.all(spacingDefault);

  /// Padding horizontal e vertical simétrico
  static const EdgeInsets paddingSymmetric =
      EdgeInsets.symmetric(horizontal: spacingDefault, vertical: spacingMedium);

  /// Padding apenas horizontal
  static const EdgeInsets paddingHorizontal =
      EdgeInsets.symmetric(horizontal: spacingDefault);

  /// Padding apenas vertical
  static const EdgeInsets paddingVertical =
      EdgeInsets.symmetric(vertical: spacingMedium);

  // ========== Dimensões do Grid ==========

  /// Razão de aspecto do grid (1:1 - quadrado)
  static const double gridAspectRatio = 1.0;

  /// Padding interno do grid
  static const EdgeInsets gridPadding = EdgeInsets.all(spacingSmall);

  /// Raio de borda do grid
  static const double gridBorderRadius = 12.0;

  /// Raio de borda das células
  static const double cellBorderRadius = 4.0;

  /// Espessura da borda das células
  static const double cellBorderWidth = 1.0;

  // ========== Dimensões dos Chips de Palavras ==========

  /// Padding horizontal dos chips de palavra
  static const double wordChipPaddingHorizontal = 12.0;

  /// Padding vertical dos chips de palavra
  static const double wordChipPaddingVertical = 6.0;

  /// Raio de borda dos chips de palavra
  static const double wordChipBorderRadius = 16.0;

  /// Espaçamento entre chips na lista
  static const double wordChipSpacing = spacingMedium;

  // ========== Flex e Proporções ==========

  /// Flex do grid de letras (3 partes)
  static const int gridFlex = 3;

  /// Flex da lista de palavras (1 parte)
  static const int wordListFlex = 1;

  // ========== Tamanhos de Fonte ==========

  /// Tamanho da fonte pequena
  static const double fontSizeSmall = 14.0;

  /// Tamanho da fonte padrão
  static const double fontSizeDefault = 16.0;

  /// Tamanho da fonte grande
  static const double fontSizeLarge = 18.0;

  /// Tamanho da fonte do título
  static const double fontSizeTitle = 20.0;

  // ========== Sombras ==========

  /// Sombra padrão para containers
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  /// Sombra leve para elementos pequenos
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 5,
      offset: Offset(0, 2),
    ),
  ];

  // ========== Bordas ==========

  /// Borda padrão para containers
  static BorderSide get defaultBorder => BorderSide(
        color: Colors.grey.shade300,
        width: 1.0,
      );

  /// Borda de destaque para elementos selecionados
  static const BorderSide highlightBorder = BorderSide(
    color: Colors.blue,
    width: 2.0,
  );

  // ========== Decorações Pré-definidas ==========

  /// Decoração para o container do grid
  static BoxDecoration get gridDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(gridBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: defaultShadow,
      );

  /// Decoração para o container da lista de palavras
  static BoxDecoration get wordListDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(spacingMedium),
        border: Border.all(color: Colors.grey.shade300),
      );

  /// Decoração para chips de palavra
  static BoxDecoration wordChipDecoration({
    required Color backgroundColor,
    required Color borderColor,
  }) =>
      BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(wordChipBorderRadius),
        border: Border.all(color: borderColor),
      );

  // ========== Estilos de Texto Pré-definidos ==========

  /// Estilo para texto de progresso
  static const TextStyle progressTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  /// Estilo para labels
  static const TextStyle labelTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: fontSizeDefault,
  );

  /// Estilo para texto de palavra encontrada
  static const TextStyle foundWordTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.lineThrough,
  );

  /// Estilo para texto de palavra destacada
  static const TextStyle highlightedWordTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  // ========== Durações de Animação ==========

  /// Duração rápida para animações (200ms)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Duração padrão para animações (300ms)
  static const Duration animationDefault = Duration(milliseconds: 300);

  /// Duração lenta para animações (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ========== Utilitários ==========

  /// Cria SizedBox com espaçamento vertical
  static Widget verticalSpacing(double height) => SizedBox(height: height);

  /// Cria SizedBox com espaçamento horizontal
  static Widget horizontalSpacing(double width) => SizedBox(width: width);

  /// Espaçamento vertical pequeno
  static Widget get verticalSpacingSmall => verticalSpacing(spacingSmall);

  /// Espaçamento vertical médio
  static Widget get verticalSpacingMedium => verticalSpacing(spacingMedium);

  /// Espaçamento vertical padrão
  static Widget get verticalSpacingDefault => verticalSpacing(spacingDefault);

  /// Espaçamento vertical grande
  static Widget get verticalSpacingLarge => verticalSpacing(spacingLarge);

  /// Espaçamento horizontal pequeno
  static Widget get horizontalSpacingSmall => horizontalSpacing(spacingSmall);

  /// Espaçamento horizontal médio
  static Widget get horizontalSpacingMedium => horizontalSpacing(spacingMedium);

  /// Espaçamento horizontal padrão
  static Widget get horizontalSpacingDefault =>
      horizontalSpacing(spacingDefault);
}
