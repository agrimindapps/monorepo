/// Definição de modos de jogo para o jogo da memória
/// 
/// Implementa diferentes variações do jogo clássico com
/// mecânicas únicas e sistemas de pontuação específicos.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Modo de jogo abstrato
abstract class GameMode {
  /// Nome do modo
  String get name;
  
  /// Descrição do modo
  String get description;
  
  /// Ícone do modo
  IconData get icon;
  
  /// Cor temática do modo
  Color get color;
  
  /// Se o modo tem limite de tempo
  bool get hasTimeLimit;
  
  /// Se o modo tem limite de movimentos
  bool get hasMoveLimit;
  
  /// Tempo limite em segundos (se aplicável)
  int? get timeLimitSeconds;
  
  /// Limite de movimentos (se aplicável)
  int? get moveLimit;
  
  /// Multiplicador de pontuação
  double get scoreMultiplier;
  
  /// Calcula pontuação específica do modo
  int calculateScore({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
    required GameDifficulty difficulty,
  });
  
  /// Verifica se o jogo terminou (além da condição padrão)
  bool isGameOver({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  });
  
  /// Obtém penalidade por tempo/movimentos excessivos
  double getPenalty({
    required int moves,
    required int timeInSeconds,
  });
  
  /// Obtém bônus por performance excepcional
  double getBonus({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  });
}

/// Modo Clássico - Jogo padrão sem limitações
class ClassicMode extends GameMode {
  @override
  String get name => 'Clássico';
  
  @override
  String get description => 'Modo tradicional sem limites de tempo ou movimentos';
  
  @override
  IconData get icon => Icons.games;
  
  @override
  Color get color => Colors.blue;
  
  @override
  bool get hasTimeLimit => false;
  
  @override
  bool get hasMoveLimit => false;
  
  @override
  int? get timeLimitSeconds => null;
  
  @override
  int? get moveLimit => null;
  
  @override
  double get scoreMultiplier => 1.0;
  
  @override
  int calculateScore({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
    required GameDifficulty difficulty,
  }) {
    if (moves == 0 || timeInSeconds == 0) return 0;
    
    // Fator de dificuldade
    final difficultyFactor = difficulty.scoreMultiplier;
    
    // Eficiência baseada em movimentos e tempo
    final efficiency = (totalPairs.toDouble() / moves) * 
                      (totalPairs.toDouble() * 10 / timeInSeconds);
    
    final clampedEfficiency = efficiency.clamp(0.1, 3.0);
    
    return ((matchedPairs * 100 * difficultyFactor * scoreMultiplier) * clampedEfficiency).round();
  }
  
  @override
  bool isGameOver({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    return false; // Apenas condição padrão (todos os pares encontrados)
  }
  
  @override
  double getPenalty({
    required int moves,
    required int timeInSeconds,
  }) {
    return 0.0; // Sem penalidades no modo clássico
  }
  
  @override
  double getBonus({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    // Bônus por jogo perfeito (mínimo de movimentos)
    if (moves == totalPairs) {
      return 0.5; // 50% de bônus
    }
    return 0.0;
  }
}

/// Modo Contra o Tempo - Tempo limitado
class TimeAttackMode extends GameMode {
  final int _timeLimit;
  
  TimeAttackMode({int timeLimitMinutes = 3}) : _timeLimit = timeLimitMinutes * 60;
  
  @override
  String get name => 'Contra o Tempo';
  
  @override
  String get description => 'Complete o jogo antes que o tempo acabe!';
  
  @override
  IconData get icon => Icons.timer;
  
  @override
  Color get color => Colors.orange;
  
  @override
  bool get hasTimeLimit => true;
  
  @override
  bool get hasMoveLimit => false;
  
  @override
  int get timeLimitSeconds => _timeLimit;
  
  @override
  int? get moveLimit => null;
  
  @override
  double get scoreMultiplier => 1.5;
  
  @override
  int calculateScore({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
    required GameDifficulty difficulty,
  }) {
    if (moves == 0) return 0;
    
    final difficultyFactor = difficulty.scoreMultiplier;
    final baseScore = matchedPairs * 100 * difficultyFactor * scoreMultiplier;
    
    // Bônus por tempo restante
    final timeRemaining = (_timeLimit - timeInSeconds).clamp(0, _timeLimit);
    final timeBonusMultiplier = 1.0 + (timeRemaining / _timeLimit * 0.5);
    
    // Penalidade por muitos movimentos
    final movePenalty = getPenalty(moves: moves, timeInSeconds: timeInSeconds);
    
    return (baseScore * timeBonusMultiplier * (1.0 - movePenalty)).round();
  }
  
  @override
  bool isGameOver({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    return timeInSeconds >= _timeLimit;
  }
  
  @override
  double getPenalty({
    required int moves,
    required int timeInSeconds,
  }) {
    // Penalidade crescente por movimentos excessivos
    const idealMovesMultiplier = 1.2;
    final idealMoves = (moves / idealMovesMultiplier).round();
    
    if (moves > idealMoves) {
      final excessMoves = moves - idealMoves;
      return (excessMoves / moves * 0.3).clamp(0.0, 0.5);
    }
    
    return 0.0;
  }
  
  @override
  double getBonus({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    // Bônus por completar rapidamente
    final timeUsedRatio = timeInSeconds / _timeLimit;
    if (timeUsedRatio < 0.5) {
      return 0.8; // 80% de bônus por ser muito rápido
    } else if (timeUsedRatio < 0.7) {
      return 0.4; // 40% de bônus por ser rápido
    }
    return 0.0;
  }
}

/// Modo Desafio - Movimentos limitados
class ChallengeMode extends GameMode {
  final int _moveLimit;
  
  ChallengeMode({int? moveLimitMultiplier}) : 
    _moveLimit = moveLimitMultiplier ?? 20; // Valor padrão será calculado dinamicamente
  
  @override
  String get name => 'Desafio';
  
  @override
  String get description => 'Complete com o mínimo de movimentos possível!';
  
  @override
  IconData get icon => Icons.my_location;
  
  @override
  Color get color => Colors.red;
  
  @override
  bool get hasTimeLimit => false;
  
  @override
  bool get hasMoveLimit => true;
  
  @override
  int? get timeLimitSeconds => null;
  
  @override
  int get moveLimit => _moveLimit;
  
  @override
  double get scoreMultiplier => 2.0;
  
  /// Calcula limite de movimentos baseado na dificuldade
  int calculateMoveLimit(int totalPairs) {
    return (totalPairs * 1.3).round(); // 30% a mais que o mínimo teórico
  }
  
  @override
  int calculateScore({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
    required GameDifficulty difficulty,
  }) {
    if (moves == 0) return 0;
    
    final difficultyFactor = difficulty.scoreMultiplier;
    final baseScore = matchedPairs * 100 * difficultyFactor * scoreMultiplier;
    
    // Bônus por movimentos restantes
    final movesRemaining = (_moveLimit - moves).clamp(0, _moveLimit);
    final moveBonusMultiplier = 1.0 + (movesRemaining / _moveLimit * 0.8);
    
    // Bônus adicional por eficiência
    final efficiencyBonus = getBonus(
      matchedPairs: matchedPairs,
      totalPairs: totalPairs,
      moves: moves,
      timeInSeconds: timeInSeconds,
    );
    
    return (baseScore * moveBonusMultiplier * (1.0 + efficiencyBonus)).round();
  }
  
  @override
  bool isGameOver({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    return moves >= _moveLimit;
  }
  
  @override
  double getPenalty({
    required int moves,
    required int timeInSeconds,
  }) {
    return 0.0; // Não há penalidade por tempo no modo desafio
  }
  
  @override
  double getBonus({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    // Bônus por eficiência de movimentos
    final efficiency = matchedPairs.toDouble() / moves;
    
    if (efficiency > 0.8) {
      return 1.0; // 100% de bônus por alta eficiência
    } else if (efficiency > 0.6) {
      return 0.5; // 50% de bônus por boa eficiência
    } else if (efficiency > 0.4) {
      return 0.2; // 20% de bônus por eficiência ok
    }
    
    return 0.0;
  }
}

/// Modo Zen - Sem pressão, foco na experiência
class ZenMode extends GameMode {
  @override
  String get name => 'Zen';
  
  @override
  String get description => 'Jogue sem pressa, focando na tranquilidade';
  
  @override
  IconData get icon => Icons.self_improvement;
  
  @override
  Color get color => Colors.green;
  
  @override
  bool get hasTimeLimit => false;
  
  @override
  bool get hasMoveLimit => false;
  
  @override
  int? get timeLimitSeconds => null;
  
  @override
  int? get moveLimit => null;
  
  @override
  double get scoreMultiplier => 0.8;
  
  @override
  int calculateScore({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
    required GameDifficulty difficulty,
  }) {
    if (moves == 0) return 0;
    
    final difficultyFactor = difficulty.scoreMultiplier;
    
    // Pontuação focada em completar, não em velocidade
    final baseScore = matchedPairs * 100 * difficultyFactor * scoreMultiplier;
    
    // Bônus por consistência (menos erros)
    final consistencyBonus = getBonus(
      matchedPairs: matchedPairs,
      totalPairs: totalPairs,
      moves: moves,
      timeInSeconds: timeInSeconds,
    );
    
    return (baseScore * (1.0 + consistencyBonus)).round();
  }
  
  @override
  bool isGameOver({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    return false; // Apenas condição padrão
  }
  
  @override
  double getPenalty({
    required int moves,
    required int timeInSeconds,
  }) {
    return 0.0; // Sem penalidades no modo zen
  }
  
  @override
  double getBonus({
    required int matchedPairs,
    required int totalPairs,
    required int moves,
    required int timeInSeconds,
  }) {
    // Bônus por consistência (taxa de acerto)
    final errors = moves - matchedPairs;
    final errorRate = errors / moves;
    
    if (errorRate < 0.1) {
      return 0.6; // 60% de bônus por quase nenhum erro
    } else if (errorRate < 0.2) {
      return 0.3; // 30% de bônus por poucos erros
    } else if (errorRate < 0.3) {
      return 0.1; // 10% de bônus por erro aceitável
    }
    
    return 0.0;
  }
}

/// Factory para modos de jogo
class GameModeFactory {
  static final Map<String, GameMode Function()> _modes = {
    'classic': () => ClassicMode(),
    'timeAttack': () => TimeAttackMode(),
    'challenge': () => ChallengeMode(),
    'zen': () => ZenMode(),
  };
  
  /// Obtém todos os modos disponíveis
  static List<GameMode> getAllModes() {
    return _modes.values.map((factory) => factory()).toList();
  }
  
  /// Cria modo por nome
  static GameMode? createMode(String name) {
    final factory = _modes[name];
    return factory?.call();
  }
  
  /// Obtém modo padrão
  static GameMode getDefaultMode() {
    return ClassicMode();
  }
  
  /// Registra novo modo customizado
  static void registerMode(String name, GameMode Function() factory) {
    _modes[name] = factory;
  }
}

/// Extensão para GameDifficulty adicionar scoreMultiplier
extension GameDifficultyScoring on GameDifficulty {
  double get scoreMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 1.0;
      case GameDifficulty.medium:
        return 1.5;
      case GameDifficulty.hard:
        return 2.0;
    }
  }
}
