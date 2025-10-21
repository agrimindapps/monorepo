/// Centralização de todas as constantes e configurações do jogo Ping Pong
/// 
/// Organize as constantes em classes para diferentes categorias para
/// facilitar a manutenção e permitir ajustes no comportamento do jogo.
library;

// Flutter imports:
import 'package:flutter/material.dart';

/// Configurações principais do jogo
class GameConfig {
  // Dimensões dos elementos do jogo
  static const double paddleWidth = 16.0;
  static const double paddleHeight = 100.0;
  static const double ballSize = 20.0;
  static const double ballRadius = ballSize / 2;
  
  // Velocidades e limites
  static const double initialBallSpeed = 4.0;
  static const double maxBallSpeed = 10.0;
  static const double ballSpeedIncrease = 1.05;
  
  // Configurações de pontuação
  static const int maxScore = 10;
  
  // Configurações de timing
  static const int gameLoopIntervalMs = 16; // ~60 FPS
  
  // Configurações de rebatimento
  static const double maxAngleEffect = 5.0;
}

/// Configurações de física do jogo
class PhysicsConfig {
  // Parâmetros de colisão
  static const double collisionTolerance = 2.0;
  
  // Fatores de reflexão
  static const double wallReflectionFactor = 1.0;
  static const double paddleReflectionFactor = 1.0;
  
  // Randomização para evitar loops previsíveis
  static const double minRandomAngle = -4.0;
  static const double maxRandomAngle = 4.0;
}

/// Configurações de IA
class AIConfig {
  // Dificuldades pré-definidas
  static const double easyReactionSpeed = 0.04;
  static const double mediumReactionSpeed = 0.08;
  static const double hardReactionSpeed = 0.12;
  static const double adaptiveReactionSpeed = 0.08; // Base para adaptativo
  
  // Configurações de comportamento
  static const double aiPredictionFactor = 0.5;
  static const double aiRandomnessFactor = 0.1;
}

/// Configurações de interface do usuário
class UIConfig {
  // Cores
  static const Color backgroundColor = Colors.black;
  static const Color primaryColor = Colors.white;
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color pauseOverlayColor = Colors.black54;
  
  // Tamanhos de fonte
  static const double scoreFont = 32.0;
  static const double buttonFont = 20.0;
  static const double pauseFont = 32.0;
  
  // Espaçamentos
  static const double defaultPadding = 20.0;
  static const double buttonSpacing = 10.0;
  static const double scoreSpacing = 40.0;
  
  // Transparências
  static const double centerLineOpacity = 0.3;
  
  // Configurações responsivas
  static const double minScreenWidth = 320.0;
  static const double minScreenHeight = 200.0;
}

/// Configurações de áudio e feedback
class AudioConfig {
  // Volumes padrão
  static const double defaultSoundVolume = 0.7;
  static const double defaultMusicVolume = 0.3;
  
  // Tipos de feedback tátil
  static const String lightHaptic = 'light';
  static const String mediumHaptic = 'medium';
  static const String heavyHaptic = 'heavy';
}

/// Configurações de testes e debug
class DebugConfig {
  static const bool enableDebugMode = false;
  static const bool showFpsCounter = false;
  static const bool enablePhysicsDebug = false;
}

/// Enumeradores para diferentes configurações
enum GameMode {
  singlePlayer,
  multiPlayerLocal,
  practice
}

enum Difficulty {
  easy,
  medium,
  hard,
  adaptive
}

enum GameState {
  menu,
  playing,
  paused,
  gameOver,
  settings
}

enum SoundEffect {
  paddleHit,
  wallHit,
  score,
  gameStart,
  gameEnd,
  buttonClick
}

/// Extensões para facilitar o uso dos enums
extension DifficultyExtension on Difficulty {
  double get reactionSpeed {
    switch (this) {
      case Difficulty.easy:
        return AIConfig.easyReactionSpeed;
      case Difficulty.medium:
        return AIConfig.mediumReactionSpeed;
      case Difficulty.hard:
        return AIConfig.hardReactionSpeed;
      case Difficulty.adaptive:
        return AIConfig.adaptiveReactionSpeed;
    }
  }
  
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Médio';
      case Difficulty.hard:
        return 'Difícil';
      case Difficulty.adaptive:
        return 'Adaptativo';
    }
  }
}

extension GameModeExtension on GameMode {
  String get label {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Um Jogador';
      case GameMode.multiPlayerLocal:
        return 'Dois Jogadores';
      case GameMode.practice:
        return 'Treino';
    }
  }
}
