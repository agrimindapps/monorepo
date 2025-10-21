// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'enums.dart';

/// Configuração central do jogo 2048
/// Centraliza todas as constantes mágicas e configurações de layout
class Game2048Config {
  // =================================================================
  // DIMENSÕES DO LAYOUT
  // =================================================================
  
  /// Largura máxima da interface do jogo
  static const double maxContentWidth = 1020.0;
  
  /// Dimensão base do tabuleiro (usada para cálculos de escala)
  static const double baseBoardDimension = 400.0;
  
  /// Padding interno do container do tabuleiro
  static const double boardPadding = 16.0;
  
  /// Espaçamento entre tiles no grid
  static const double tileSpacing = 4.0;
  
  /// Raio da borda das cartas e containers
  static const double cardBorderRadius = 8.0;
  
  // =================================================================
  // ESPACAMENTOS E MARGENS
  // =================================================================
  
  /// Padding padrão da página
  static const double pagePadding = 16.0;
  
  /// Espaçamento vertical entre seções
  static const double sectionSpacing = 16.0;
  
  /// Espaçamento pequeno para elementos próximos
  static const double smallSpacing = 8.0;
  
  /// Espaçamento grande para separar seções principais
  static const double largeSpacing = 24.0;
  
  // =================================================================
  // DIMENSÕES DOS TILES
  // =================================================================
  
  /// Tamanho da fonte base dos números nos tiles
  static const double baseFontSize = 24.0;
  
  /// Peso da fonte dos números
  static const FontWeight tileFontWeight = FontWeight.bold;
  
  /// Raio da borda dos tiles individuais
  static const double tileBorderRadius = 8.0;
  
  // =================================================================
  // CONFIGURAÇÕES DE ANIMAÇÃO
  // =================================================================
  
  /// Duração padrão das animações de tiles
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  
  /// Duração da animação de merge/combinação
  static const Duration mergeAnimationDuration = Duration(milliseconds: 300);
  
  /// Curva de animação padrão
  static const Curve defaultAnimationCurve = Curves.easeInOut;
  
  // =================================================================
  // CORES E TEMAS
  // =================================================================
  
  /// Cor de fundo padrão do tabuleiro
  static const Color boardBackgroundColor = Color(0xFFF5F5F5);
  
  /// Cor de texto escuro para tiles claros
  static const Color darkTextColor = Colors.black;
  
  /// Cor de texto claro para tiles escuros
  static const Color lightTextColor = Colors.white;
  
  /// Limiar para determinar quando usar texto claro (valores maiores que este usam texto claro)
  static const int lightTextThreshold = 4;
  
  // =================================================================
  // CONFIGURAÇÕES DE INTERFACE
  // =================================================================
  
  /// Altura dos botões de controle
  static const double controlButtonHeight = 48.0;
  
  /// Padding interno dos botões
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  
  /// Tamanho dos ícones nos controles
  static const double controlIconSize = 20.0;
  
  /// Tamanho dos ícones grandes (pontuação, etc.)
  static const double largeIconSize = 28.0;
  
  // =================================================================
  // CONFIGURAÇÕES RESPONSIVAS
  // =================================================================
  
  /// Breakpoint para layout móvel
  static const double mobileBreakpoint = 600.0;
  
  /// Breakpoint para layout tablet
  static const double tabletBreakpoint = 900.0;
  
  /// Fator de escala para telas pequenas
  static const double mobileScaleFactor = 0.8;
  
  /// Fator de escala para tablets
  static const double tabletScaleFactor = 0.9;
  
  // =================================================================
  // CONFIGURAÇÕES DE JOGO
  // =================================================================
  
  /// Valor objetivo padrão para vitória
  static const int defaultWinTarget = 2048;
  
  /// Tamanho padrão do tabuleiro
  static const BoardSize defaultBoardSize = BoardSize.size4x4;
  
  /// Esquema de cores padrão
  static const TileColorScheme defaultColorScheme = TileColorScheme.blue;
  
  /// Máximo de entradas no histórico de jogos
  static const int maxGameHistoryEntries = 50;
  
  // =================================================================
  // MÉTODOS AUXILIARES
  // =================================================================
  
  /// Calcula a dimensão do tabuleiro baseada no tamanho selecionado
  static double getBoardDimension(BoardSize size, {double? screenWidth}) {
    double scaleFactor = 1.0;
    
    if (screenWidth != null) {
      if (screenWidth < mobileBreakpoint) {
        scaleFactor = mobileScaleFactor;
      } else if (screenWidth < tabletBreakpoint) {
        scaleFactor = tabletScaleFactor;
      }
    }
    
    return baseBoardDimension * (size.size / 4) * scaleFactor;
  }
  
  /// Retorna o padding baseado no tipo de dispositivo
  static EdgeInsets getResponsivePadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(12.0);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(pagePadding);
    }
  }
  
  /// Calcula o tamanho da fonte baseado no valor do tile
  static double getTileFontSize(int value, {double? screenWidth}) {
    double scaleFactor = 1.0;
    
    if (screenWidth != null && screenWidth < mobileBreakpoint) {
      scaleFactor = 0.8;
    }
    
    // Reduz o tamanho da fonte para números muito grandes
    if (value >= 1000) {
      return (baseFontSize - 4) * scaleFactor;
    } else if (value >= 100) {
      return (baseFontSize - 2) * scaleFactor;
    }
    
    return baseFontSize * scaleFactor;
  }
  
  /// Determina se deve usar texto claro baseado no valor
  static bool shouldUseLightText(int value) {
    return value > lightTextThreshold;
  }
  
  /// Retorna o número de colunas do grid baseado na tela
  static int getGridColumns(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 1; // Stack vertical em telas pequenas
    } else if (screenWidth < tabletBreakpoint) {
      return 1; // Ainda layout vertical em tablets
    } else {
      return 1; // Layout horizontal apenas em desktop
    }
  }
  
  /// Configurações dos controles baseadas no tamanho da tela
  static WrapAlignment getControlsAlignment(double screenWidth) {
    return screenWidth < mobileBreakpoint 
        ? WrapAlignment.center 
        : WrapAlignment.center;
  }
  
  /// Espaçamento entre controles baseado no tamanho da tela
  static double getControlsSpacing(double screenWidth) {
    return screenWidth < mobileBreakpoint ? 8.0 : 16.0;
  }
  
  // =================================================================
  // MÉTODOS ESTÁTICOS RESPONSIVOS
  // =================================================================
  
  /// Cria configuração responsiva baseada no tamanho da tela
  static ResponsiveConfig forScreenSize(Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width < 900;
    
    return ResponsiveConfig(
      screenSize: screenSize,
      isSmallScreen: isSmallScreen,
      isMediumScreen: isMediumScreen,
      boardSize: isSmallScreen ? 300 : (isMediumScreen ? 400 : 450),
      tileSize: isSmallScreen ? 60 : (isMediumScreen ? 80 : 90),
      tileFontSize: isSmallScreen ? 20 : (isMediumScreen ? 28 : 32),
      padding: isSmallScreen ? 8.0 : 16.0,
      spacing: isSmallScreen ? 12.0 : 20.0,
      tilePadding: isSmallScreen ? 3.0 : 5.0,
      borderRadius: isSmallScreen ? 6.0 : 8.0,
      maxGameWidth: isSmallScreen ? 350 : (isMediumScreen ? 500 : 600),
    );
  }
}

/// Configuração responsiva para diferentes tamanhos de tela
class ResponsiveConfig {
  final Size screenSize;
  final bool isSmallScreen;
  final bool isMediumScreen;
  final double boardSize;
  final double tileSize;
  final double tileFontSize;
  final double padding;
  final double spacing;
  final double tilePadding;
  final double borderRadius;
  final double maxGameWidth;
  
  const ResponsiveConfig({
    required this.screenSize,
    required this.isSmallScreen,
    required this.isMediumScreen,
    required this.boardSize,
    required this.tileSize,
    required this.tileFontSize,
    required this.padding,
    required this.spacing,
    required this.tilePadding,
    required this.borderRadius,
    required this.maxGameWidth,
  });
  
  /// Calcula tamanho do tile baseado no tamanho do tabuleiro
  double getTileSize(BoardSize boardSize) => this.boardSize / boardSize.size - tilePadding;
  
  /// Calcula fonte baseada no tamanho do tile
  double getTileFontSize(BoardSize boardSize) {
    final tileSize = getTileSize(boardSize);
    return tileSize * 0.3; // 30% do tamanho do tile
  }
}
