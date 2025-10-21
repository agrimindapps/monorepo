// Flutter imports:
import 'package:flutter/material.dart';

/// Game constants organized by category
class GameConstants {
  GameConstants._();
}

/// Color constants for the game
class GameColors {
  GameColors._();
  
  /// Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cellHidden = Color(0xFFE0E0E0);
  static const Color cellRevealed = Color(0xFFFFFFFF);
  static const Color cellMine = Color(0xFFFF5722);
  static const Color cellFlag = Color(0xFFFF9800);
  static const Color cellQuestion = Color(0xFF9C27B0);
  
  /// Number colors (1-8)
  static const List<Color> numberColors = [
    Colors.transparent, // 0
    Color(0xFF2196F3), // 1 - Blue
    Color(0xFF4CAF50), // 2 - Green
    Color(0xFFFF5722), // 3 - Red
    Color(0xFF9C27B0), // 4 - Purple
    Color(0xFF795548), // 5 - Brown
    Color(0xFF607D8B), // 6 - Blue Grey
    Color(0xFF424242), // 7 - Dark Grey
    Color(0xFF000000), // 8 - Black
  ];
  
  /// Gets the appropriate color for a number
  static Color getNumberColor(int number) {
    if (number >= 0 && number < numberColors.length) {
      return numberColors[number];
    }
    return Colors.black;
  }
}

/// Size constants for UI elements
class GameSizes {
  GameSizes._();
  
  /// Cell dimensions
  static const double cellSize = 40.0;
  static const double cellPadding = 2.0;
  static const double cellSpacing = 1.0;
  
  /// Font sizes
  static const double cellFontSize = 16.0;
  static const double headerFontSize = 20.0;
  static const double buttonFontSize = 14.0;
  
  /// Icon sizes
  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;
}

/// Timing-related constants
class Timing {
  Timing._();
  
  /// Timer update interval in milliseconds
  static const int timerUpdateInterval = 1000;
  
  /// Animation duration for cell reveal in milliseconds
  static const int cellRevealAnimationDuration = 150;
  
  /// Animation duration for flag placement in milliseconds
  static const int flagAnimationDuration = 200;
  
  /// Animation duration for game over overlay in milliseconds
  static const int gameOverAnimationDuration = 500;
  
  /// Delay between auto-reveal animations in milliseconds
  static const int autoRevealDelay = 50;
}

/// Layout and spacing constants
class Layout {
  Layout._();
  
  /// Game grid padding
  static const double gridPadding = 16.0;
  
  /// Header section padding
  static const double headerPadding = 8.0;
  
  /// Space between UI elements
  static const double elementSpacing = 12.0;
  
  /// Border radius for cells
  static const double cellBorderRadius = 4.0;
  
  /// Border width for cells
  static const double cellBorderWidth = 1.0;
  
  /// Border radius for grid container
  static const double gridBorderRadius = 8.0;
  
  /// Border width for grid container
  static const double gridBorderWidth = 2.0;
  
  /// Maximum grid width on larger screens
  static const double maxGridWidth = 600.0;
  
  /// Maximum grid height on larger screens
  static const double maxGridHeight = 800.0;
}

/// Animation and visual effect constants
class Animation {
  Animation._();
  
  /// Scale animation range for cell press
  static const double cellPressScale = 0.95;
  
  /// Scale animation range for flag placement
  static const double flagPlaceScale = 1.2;
  
  /// Rotation animation for mines explosion
  static const double mineExplosionRotation = 0.1;
  
  /// Bounce animation intensity for victory
  static const double victoryBounceScale = 1.1;
  
  /// Fade animation opacity range
  static const double fadeOpacityRange = 0.3;
}

/// Game logic constants
class GameLogic {
  GameLogic._();
  
  /// Maximum time in seconds (999 seconds = 16:39)
  static const int maxTime = 999;
  
  /// Mine value in cell (used internally)
  static const int mineValue = -1;
  
  /// Maximum custom grid rows
  static const int maxCustomRows = 24;
  
  /// Maximum custom grid columns
  static const int maxCustomCols = 30;
  
  /// Minimum custom grid rows
  static const int minCustomRows = 5;
  
  /// Minimum custom grid columns
  static const int minCustomCols = 5;
  
  /// Maximum mine density (percentage of total cells)
  static const double maxMineDensity = 0.8;
  
  /// Minimum mine count
  static const int minMineCount = 1;
}

/// Visual feedback constants
class VisualFeedback {
  VisualFeedback._();
  
  /// Shadow blur radius for cells
  static const double cellShadowBlur = 2.0;
  
  /// Shadow offset for cells
  static const double cellShadowOffsetX = 1.0;
  static const double cellShadowOffsetY = 1.0;
  
  /// Grid shadow properties
  static const double gridShadowBlur = 4.0;
  static const double gridShadowOffsetX = 2.0;
  static const double gridShadowOffsetY = 2.0;
  static const double gridShadowOpacity = 0.2;
  
  /// Shadow color opacity
  static const double shadowOpacity = 0.3;
  
  /// Border highlight opacity for focused cells
  static const double borderHighlightOpacity = 0.6;
  
  /// Ripple effect opacity
  static const double rippleOpacity = 0.2;
}

/// Icon and symbol constants
class GameIcons {
  GameIcons._();
  
  /// Unicode symbols for game elements
  static const String mine = '💣';
  static const String flag = '🚩';
  static const String question = '❓';
  static const String explosion = '💥';
  static const String trophy = '🏆';
  static const String timer = '⏱️';
  static const String restart = '🔄';
  static const String settings = '⚙️';
  
  /// Numbers for revealed cells (0-8)
  static const List<String> numbers = [
    '', '1', '2', '3', '4', '5', '6', '7', '8'
  ];
}

/// Storage keys for persistence
class StorageKeys {
  StorageKeys._();
  
  /// High scores for each difficulty
  static const String beginnerBestTime = 'minesweeper_beginner_best_time';
  static const String intermediateBestTime = 'minesweeper_intermediate_best_time';
  static const String expertBestTime = 'minesweeper_expert_best_time';
  
  /// Game statistics
  static const String totalGamesPlayed = 'minesweeper_total_games';
  static const String totalGamesWon = 'minesweeper_total_wins';
  static const String currentStreak = 'minesweeper_current_streak';
  static const String bestStreak = 'minesweeper_best_streak';
  
  /// Settings
  static const String lastDifficulty = 'minesweeper_last_difficulty';
  static const String soundEnabled = 'minesweeper_sound_enabled';
  static const String vibrationEnabled = 'minesweeper_vibration_enabled';
  static const String customRows = 'minesweeper_custom_rows';
  static const String customCols = 'minesweeper_custom_cols';
  static const String customMines = 'minesweeper_custom_mines';
}
