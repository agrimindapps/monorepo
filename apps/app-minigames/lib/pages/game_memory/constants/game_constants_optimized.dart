/// Constantes otimizadas para o jogo da memória
/// 
/// Centraliza todas as constantes do jogo para melhor performance
/// e facilidade de manutenção, usando widgets const sempre que possível.
library;

// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes de layout e dimensões
class GameLayout {
  /// Dimensões padrão de cartas
  static const double defaultCardSize = 80.0;
  static const double minCardSize = 40.0;
  static const double maxCardSize = 120.0;
  
  /// Espaçamento
  static const double gridSpacing = 8.0;
  static const double sectionSpacing = 16.0;
  static const double elementSpacing = 8.0;
  
  /// Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(8.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
  
  /// Border radius
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double dialogBorderRadius = 16.0;
  
  /// Tamanhos mínimos para acessibilidade
  static const double minTouchTarget = 48.0;
  static const double largeTouchTarget = 64.0;
  
  /// Aspectos de responsividade
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  
  /// Construtores privados para evitar instanciação
  GameLayout._();
}

/// Constantes de animação
class GameAnimations {
  /// Durações
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  /// Durações específicas
  static const Duration cardFlipDuration = Duration(milliseconds: 400);
  static const Duration matchFoundDuration = Duration(milliseconds: 600);
  static const Duration gameOverDelay = Duration(milliseconds: 1000);
  static const Duration dialogTransition = Duration(milliseconds: 250);
  
  /// Curvas de animação
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve fastCurve = Curves.easeOut;
  static const Curve slowCurve = Curves.easeInOutCubic;
  
  /// Construtores privados
  GameAnimations._();
}

/// Constantes de cores
class GameColors {
  /// Cores primárias
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  /// Cores secundárias
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  
  /// Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  /// Cores de fundo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF424242);
  
  /// Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Cores para cartas
  static const List<Color> cardColors = [
    Color(0xFFE91E63), // Rosa
    Color(0xFF9C27B0), // Roxo
    Color(0xFF673AB7), // Roxo escuro
    Color(0xFF3F51B5), // Índigo
    Color(0xFF2196F3), // Azul
    Color(0xFF03A9F4), // Azul claro
    Color(0xFF00BCD4), // Ciano
    Color(0xFF009688), // Verde-azulado
    Color(0xFF4CAF50), // Verde
    Color(0xFF8BC34A), // Verde claro
    Color(0xFFCDDC39), // Lima
    Color(0xFFFFEB3B), // Amarelo
    Color(0xFFFFC107), // Âmbar
    Color(0xFFFF9800), // Laranja
    Color(0xFFFF5722), // Laranja escuro
    Color(0xFF795548), // Marrom
  ];
  
  /// Cores para alto contraste
  static const Color highContrastForeground = Color(0xFFFFFFFF);
  static const Color highContrastBackground = Color(0xFF000000);
  static const Color highContrastAccent = Color(0xFFFFD700);
  
  /// Construtores privados
  GameColors._();
}

/// Constantes de tipografia
class GameTypography {
  /// Tamanhos de fonte
  static const double headlineSize = 28.0;
  static const double titleSize = 22.0;
  static const double subtitleSize = 18.0;
  static const double bodySize = 16.0;
  static const double captionSize = 14.0;
  static const double smallSize = 12.0;
  
  /// Pesos de fonte
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  /// Estilos de texto constantes
  static const TextStyle headline = TextStyle(
    fontSize: headlineSize,
    fontWeight: bold,
    color: GameColors.textPrimary,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: titleSize,
    fontWeight: semiBold,
    color: GameColors.textPrimary,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: subtitleSize,
    fontWeight: medium,
    color: GameColors.textSecondary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: bodySize,
    fontWeight: regular,
    color: GameColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: captionSize,
    fontWeight: regular,
    color: GameColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: bodySize,
    fontWeight: semiBold,
    color: GameColors.surface,
  );
  
  /// Construtores privados
  GameTypography._();
}

/// Constantes de ícones
class GameIcons {
  /// Ícones do jogo
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData stop = Icons.stop;
  static const IconData restart = Icons.refresh;
  static const IconData settings = Icons.settings;
  static const IconData help = Icons.help_outline;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  
  /// Ícones de estado
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error;
  static const IconData warning = Icons.warning;
  static const IconData info = Icons.info;
  
  /// Ícones de mídia
  static const IconData soundOn = Icons.volume_up;
  static const IconData soundOff = Icons.volume_off;
  static const IconData music = Icons.music_note;
  static const IconData vibration = Icons.vibration;
  
  /// Ícones de acessibilidade
  static const IconData accessibility = Icons.accessibility;
  static const IconData visibility = Icons.visibility;
  static const IconData contrast = Icons.contrast;
  static const IconData textSize = Icons.format_size;
  
  /// Ícones para cartas (usados no jogo)
  static const List<IconData> cardIcons = [
    Icons.favorite,           // Coração
    Icons.star,              // Estrela
    Icons.diamond,           // Diamante
    Icons.circle,            // Círculo
    Icons.square,            // Quadrado
    Icons.change_history,    // Triângulo
    Icons.pets,              // Animal
    Icons.local_florist,     // Flor
    Icons.brightness_1,      // Círculo sólido
    Icons.check_box_outline_blank, // Quadrado vazio
    Icons.radio_button_unchecked,  // Círculo vazio
    Icons.favorite_border,   // Coração vazio
    Icons.star_border,       // Estrela vazia
    Icons.wb_sunny,          // Sol
    Icons.cloud,             // Nuvem
    Icons.flash_on,          // Raio
  ];
  
  /// Construtores privados
  GameIcons._();
}

/// Constantes de timing
class GameTiming {
  /// Timeouts para diferentes dificuldades
  static const int easyMatchTime = 1500;    // ms
  static const int mediumMatchTime = 1200;  // ms
  static const int hardMatchTime = 1000;    // ms
  
  /// Intervalos de timer
  static const int gameLoopInterval = 16;   // ~60 FPS
  static const int secondTimer = 1000;      // 1 segundo
  
  /// Delays para feedback
  static const int hapticDelay = 50;        // ms
  static const int soundDelay = 100;        // ms
  static const int visualFeedbackDelay = 200; // ms
  
  /// Construtores privados
  GameTiming._();
}

/// Widgets constantes reutilizáveis
class ConstantWidgets {
  /// Espaçadores constantes
  static const Widget verticalSpaceSmall = SizedBox(height: GameLayout.elementSpacing);
  static const Widget verticalSpaceMedium = SizedBox(height: GameLayout.sectionSpacing);
  static const Widget verticalSpaceLarge = SizedBox(height: GameLayout.sectionSpacing * 2);
  
  static const Widget horizontalSpaceSmall = SizedBox(width: GameLayout.elementSpacing);
  static const Widget horizontalSpaceMedium = SizedBox(width: GameLayout.sectionSpacing);
  static const Widget horizontalSpaceLarge = SizedBox(width: GameLayout.sectionSpacing * 2);
  
  /// Dividers constantes
  static const Widget divider = Divider(color: GameColors.textDisabled);
  static const Widget verticalDivider = VerticalDivider(color: GameColors.textDisabled);
  
  /// Loading indicators constantes
  static const Widget loadingIndicator = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
  );
  
  static const Widget loadingIndicatorSmall = SizedBox(
    width: 16.0,
    height: 16.0,
    child: CircularProgressIndicator(
      strokeWidth: 2.0,
      valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
    ),
  );
  
  /// Ícones constantes
  static const Widget playIcon = Icon(GameIcons.play, color: GameColors.surface);
  static const Widget pauseIcon = Icon(GameIcons.pause, color: GameColors.surface);
  static const Widget restartIcon = Icon(GameIcons.restart, color: GameColors.surface);
  static const Widget settingsIcon = Icon(GameIcons.settings, color: GameColors.surface);
  static const Widget helpIcon = Icon(GameIcons.help, color: GameColors.surface);
  static const Widget closeIcon = Icon(GameIcons.close, color: GameColors.surface);
  
  /// Construtores privados
  ConstantWidgets._();
}

/// Constantes de configuração do jogo
class GameConfig {
  /// Configurações de grade por dificuldade
  static const Map<String, int> gridSizes = {
    'easy': 4,    // 4x4 = 16 cartas (8 pares)
    'medium': 6,  // 6x6 = 36 cartas (18 pares)
    'hard': 8,    // 8x8 = 64 cartas (32 pares)
  };
  
  /// Pontuações máximas por dificuldade
  static const Map<String, int> maxScores = {
    'easy': 1000,
    'medium': 2000,
    'hard': 4000,
  };
  
  /// Multiplicadores de pontuação
  static const Map<String, double> scoreMultipliers = {
    'easy': 1.0,
    'medium': 1.5,
    'hard': 2.0,
  };
  
  /// Configurações de cache
  static const int maxCacheSize = 100;
  static const Duration cacheTimeout = Duration(minutes: 10);
  
  /// Configurações de performance
  static const int targetFPS = 60;
  static const bool enableLazyLoading = true;
  static const bool enableVirtualization = true;
  
  /// Construtores privados
  GameConfig._();
}

/// Constantes de semântica (acessibilidade)
class SemanticLabels {
  static const String gameBoard = 'Tabuleiro do jogo da memória';
  static const String gameInfo = 'Informações da partida atual';
  static const String gameControls = 'Controles do jogo';
  static const String playButton = 'Botão para iniciar o jogo';
  static const String pauseButton = 'Botão para pausar o jogo';
  static const String restartButton = 'Botão para reiniciar o jogo';
  static const String settingsButton = 'Botão de configurações';
  static const String helpButton = 'Botão de ajuda';
  static const String cardButton = 'Carta do jogo da memória';
  static const String revealedCard = 'Carta revelada';
  static const String hiddenCard = 'Carta oculta';
  static const String matchedCard = 'Carta que faz parte de um par encontrado';
  
  /// Construtores privados
  SemanticLabels._();
}

/// Constantes de validação
class GameValidation {
  /// Limites mínimos e máximos
  static const int minGridSize = 2;
  static const int maxGridSize = 10;
  static const double minTextScale = 0.5;
  static const double maxTextScale = 3.0;
  static const int minScore = 0;
  static const int maxScore = 999999;
  
  /// Regex para validação
  static const String scorePattern = r'^\d{1,6}$';
  static const String timePattern = r'^\d{1,2}:\d{2}$';
  
  /// Construtores privados
  GameValidation._();
}
