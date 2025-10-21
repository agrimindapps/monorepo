/// Sistema de dificuldade adaptativa para o jogo Ping Pong
/// 
/// Analisa o desempenho do jogador em tempo real e ajusta
/// automaticamente a dificuldade da IA para manter o jogo balanceado.
library;

// Dart imports:
import 'dart:math';

/// Gerenciador de dificuldade adaptativa
class AdaptiveDifficultyManager {
  /// Dados de performance do jogador
  final PlayerPerformanceData _performanceData = PlayerPerformanceData();
  
  /// Configuração de dificuldade atual
  DifficultySettings _currentSettings = DifficultySettings.medium();
  
  /// Histórico de ajustes
  final List<DifficultyAdjustment> _adjustmentHistory = [];
  
  /// Configurações do sistema adaptativo
  final AdaptiveConfig _config = AdaptiveConfig();
  
  /// Indica se o sistema está ativo
  bool _isActive = false;
  
  /// Último tempo de análise
  DateTime? _lastAnalysis;
  
  /// Getter para configurações atuais
  DifficultySettings get currentSettings => _currentSettings;
  
  /// Getter para verificar se está ativo
  bool get isActive => _isActive;
  
  /// Getter para dados de performance
  PlayerPerformanceData get performanceData => _performanceData;
  
  /// Ativa o sistema de dificuldade adaptativa
  void activate() {
    _isActive = true;
    _lastAnalysis = DateTime.now();
    _performanceData.reset();
  }
  
  /// Desativa o sistema
  void deactivate() {
    _isActive = false;
  }
  
  /// Registra um ponto do jogador
  void registerPlayerScore() {
    if (!_isActive) return;
    
    _performanceData.playerWins++;
    _performanceData.totalGames++;
    _performanceData.lastPlayerScoreTime = DateTime.now();
    
    _checkForAdjustment();
  }
  
  /// Registra um ponto da IA
  void registerAIScore() {
    if (!_isActive) return;
    
    _performanceData.aiWins++;
    _performanceData.totalGames++;
    _performanceData.lastAIScoreTime = DateTime.now();
    
    _checkForAdjustment();
  }
  
  /// Registra um rebote do jogador
  void registerPlayerHit(double ballSpeed, double accuracy) {
    if (!_isActive) return;
    
    _performanceData.totalHits++;
    _performanceData.totalBallSpeed += ballSpeed;
    _performanceData.totalAccuracy += accuracy;
    _performanceData.recentHitTimes.add(DateTime.now());
    
    // Mantém apenas os últimos N hits
    if (_performanceData.recentHitTimes.length > _config.maxRecentHits) {
      _performanceData.recentHitTimes.removeAt(0);
    }
  }
  
  /// Registra tempo de reação do jogador
  void registerReactionTime(Duration reactionTime) {
    if (!_isActive) return;
    
    _performanceData.reactionTimes.add(reactionTime.inMilliseconds.toDouble());
    
    // Mantém apenas as últimas N medições
    if (_performanceData.reactionTimes.length > _config.maxReactionSamples) {
      _performanceData.reactionTimes.removeAt(0);
    }
  }
  
  /// Verifica se precisa fazer ajuste de dificuldade
  void _checkForAdjustment() {
    if (_lastAnalysis == null) return;
    
    final now = DateTime.now();
    final timeSinceLastAnalysis = now.difference(_lastAnalysis!);
    
    // Só analisa a cada X segundos
    if (timeSinceLastAnalysis.inSeconds < _config.analysisIntervalSeconds) return;
    
    _lastAnalysis = now;
    
    // Analisa performance e ajusta se necessário
    final analysis = _analyzePerformance();
    if (analysis.needsAdjustment) {
      _adjustDifficulty(analysis);
    }
  }
  
  /// Analisa a performance atual do jogador
  PerformanceAnalysis _analyzePerformance() {
    final analysis = PerformanceAnalysis();
    
    // Calcula taxa de vitórias
    if (_performanceData.totalGames > 0) {
      analysis.winRate = _performanceData.playerWins / _performanceData.totalGames;
    }
    
    // Calcula velocidade média de rebote
    if (_performanceData.totalHits > 0) {
      analysis.averageBallSpeed = _performanceData.totalBallSpeed / _performanceData.totalHits;
      analysis.averageAccuracy = _performanceData.totalAccuracy / _performanceData.totalHits;
    }
    
    // Calcula tempo de reação médio
    if (_performanceData.reactionTimes.isNotEmpty) {
      final sum = _performanceData.reactionTimes.reduce((a, b) => a + b);
      analysis.averageReactionTime = sum / _performanceData.reactionTimes.length;
    }
    
    // Calcula consistência (baseada na variação dos tempos de reação)
    if (_performanceData.reactionTimes.length > 2) {
      final mean = analysis.averageReactionTime;
      final variance = _performanceData.reactionTimes
          .map((time) => pow(time - mean, 2))
          .reduce((a, b) => a + b) / _performanceData.reactionTimes.length;
      analysis.consistency = 1.0 / (1.0 + sqrt(variance) / 100.0);
    }
    
    // Calcula tendência recente
    analysis.recentTrend = _calculateRecentTrend();
    
    // Determina se precisa ajustar
    analysis.needsAdjustment = _shouldAdjustDifficulty(analysis);
    
    // Determina direção do ajuste
    if (analysis.needsAdjustment) {
      analysis.adjustmentDirection = _determineAdjustmentDirection(analysis);
    }
    
    return analysis;
  }
  
  /// Calcula tendência recente de performance
  double _calculateRecentTrend() {
    if (_performanceData.totalGames < 6) return 0.0;
    
    // Analisa últimos 6 jogos
    final recentGames = min(6, _performanceData.totalGames);
    final recentPlayerWins = _performanceData.playerWins;
    final recentTotal = _performanceData.totalGames;
    
    // Compara com performance geral
    final recentWinRate = recentPlayerWins / recentTotal;
    final overallWinRate = _performanceData.playerWins / _performanceData.totalGames;
    
    return recentWinRate - overallWinRate;
  }
  
  /// Determina se deve ajustar a dificuldade
  bool _shouldAdjustDifficulty(PerformanceAnalysis analysis) {
    // Não ajusta se não tem dados suficientes
    if (_performanceData.totalGames < _config.minGamesBeforeAdjustment) {
      return false;
    }
    
    // Ajusta se taxa de vitórias está muito alta ou baixa
    if (analysis.winRate > _config.maxWinRateThreshold || 
        analysis.winRate < _config.minWinRateThreshold) {
      return true;
    }
    
    // Ajusta se tendência recente é muito forte
    if (analysis.recentTrend.abs() > _config.trendThreshold) {
      return true;
    }
    
    // Ajusta se tempo de reação mudou significativamente
    if (analysis.averageReactionTime > 0) {
      final expectedReactionTime = _getExpectedReactionTime();
      final reactionDifference = (analysis.averageReactionTime - expectedReactionTime).abs();
      if (reactionDifference > _config.reactionTimeThreshold) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Determina a direção do ajuste (mais fácil ou mais difícil)
  AdjustmentDirection _determineAdjustmentDirection(PerformanceAnalysis analysis) {
    double adjustmentScore = 0.0;
    
    // Fator da taxa de vitórias
    if (analysis.winRate > 0.6) {
      adjustmentScore += (analysis.winRate - 0.6) * 2.0; // Mais difícil
    } else if (analysis.winRate < 0.4) {
      adjustmentScore -= (0.4 - analysis.winRate) * 2.0; // Mais fácil
    }
    
    // Fator da tendência recente
    adjustmentScore += analysis.recentTrend;
    
    // Fator do tempo de reação
    if (analysis.averageReactionTime > 0) {
      final expectedReactionTime = _getExpectedReactionTime();
      if (analysis.averageReactionTime < expectedReactionTime * 0.8) {
        adjustmentScore += 0.3; // Jogador está rápido, pode ser mais difícil
      } else if (analysis.averageReactionTime > expectedReactionTime * 1.2) {
        adjustmentScore -= 0.3; // Jogador está lento, deve ser mais fácil
      }
    }
    
    // Fator da consistência
    if (analysis.consistency > 0.8) {
      adjustmentScore += 0.2; // Muito consistente, pode ser mais difícil
    } else if (analysis.consistency < 0.5) {
      adjustmentScore -= 0.2; // Inconsistente, deve ser mais fácil
    }
    
    return adjustmentScore > 0.1 ? AdjustmentDirection.harder : 
           adjustmentScore < -0.1 ? AdjustmentDirection.easier : 
           AdjustmentDirection.none;
  }
  
  /// Ajusta a dificuldade baseada na análise
  void _adjustDifficulty(PerformanceAnalysis analysis) {
    final adjustment = DifficultyAdjustment(
      timestamp: DateTime.now(),
      direction: analysis.adjustmentDirection,
      reason: _generateAdjustmentReason(analysis),
      previousSettings: DifficultySettings.fromSettings(_currentSettings),
      playerWinRate: analysis.winRate,
      averageReactionTime: analysis.averageReactionTime,
    );
    
    // Aplica o ajuste
    _applyAdjustment(adjustment);
    
    // Adiciona ao histórico
    _adjustmentHistory.add(adjustment);
    
    // Limita histórico
    if (_adjustmentHistory.length > _config.maxHistorySize) {
      _adjustmentHistory.removeAt(0);
    }
  }
  
  /// Aplica um ajuste de dificuldade
  void _applyAdjustment(DifficultyAdjustment adjustment) {
    final factor = _getAdjustmentFactor(adjustment.direction);
    
    // Ajusta velocidade de reação da IA
    _currentSettings.aiReactionSpeed = 
        (_currentSettings.aiReactionSpeed * factor).clamp(0.02, 0.20);
    
    // Ajusta precisão da IA
    _currentSettings.aiAccuracy = 
        (_currentSettings.aiAccuracy * factor).clamp(0.3, 0.95);
    
    // Ajusta agressividade
    _currentSettings.aiAggression = 
        (_currentSettings.aiAggression * factor).clamp(0.2, 0.9);
    
    // Ajusta fator de predição
    _currentSettings.predictionFactor = 
        (_currentSettings.predictionFactor * factor).clamp(0.1, 0.8);
    
    // Marca timestamp da mudança
    _currentSettings.lastModified = DateTime.now();
    
    adjustment.newSettings = DifficultySettings.fromSettings(_currentSettings);
  }
  
  /// Obtém fator de ajuste baseado na direção
  double _getAdjustmentFactor(AdjustmentDirection direction) {
    switch (direction) {
      case AdjustmentDirection.easier:
        return 0.9; // Reduz em 10%
      case AdjustmentDirection.harder:
        return 1.1; // Aumenta em 10%
      case AdjustmentDirection.none:
        return 1.0; // Sem mudança
    }
  }
  
  /// Gera razão para o ajuste
  String _generateAdjustmentReason(PerformanceAnalysis analysis) {
    final reasons = <String>[];
    
    if (analysis.winRate > 0.7) {
      reasons.add('Taxa de vitórias muito alta (${(analysis.winRate * 100).toStringAsFixed(1)}%)');
    } else if (analysis.winRate < 0.3) {
      reasons.add('Taxa de vitórias muito baixa (${(analysis.winRate * 100).toStringAsFixed(1)}%)');
    }
    
    if (analysis.recentTrend > 0.2) {
      reasons.add('Tendência crescente de vitórias');
    } else if (analysis.recentTrend < -0.2) {
      reasons.add('Tendência decrescente de vitórias');
    }
    
    if (analysis.averageReactionTime > 0) {
      final expected = _getExpectedReactionTime();
      if (analysis.averageReactionTime < expected * 0.8) {
        reasons.add('Tempo de reação muito rápido');
      } else if (analysis.averageReactionTime > expected * 1.2) {
        reasons.add('Tempo de reação lento');
      }
    }
    
    return reasons.join(', ');
  }
  
  /// Obtém tempo de reação esperado baseado na dificuldade atual
  double _getExpectedReactionTime() {
    // Tempo em milissegundos baseado na dificuldade
    return 200.0 + (1.0 - _currentSettings.aiReactionSpeed) * 300.0;
  }
  
  /// Força um ajuste manual de dificuldade
  void forceAdjustment(AdjustmentDirection direction, String reason) {
    final adjustment = DifficultyAdjustment(
      timestamp: DateTime.now(),
      direction: direction,
      reason: 'Ajuste manual: $reason',
      previousSettings: DifficultySettings.fromSettings(_currentSettings),
      playerWinRate: _performanceData.totalGames > 0 ? 
          _performanceData.playerWins / _performanceData.totalGames : 0.0,
      averageReactionTime: _performanceData.reactionTimes.isNotEmpty ?
          _performanceData.reactionTimes.reduce((a, b) => a + b) / _performanceData.reactionTimes.length : 0.0,
    );
    
    _applyAdjustment(adjustment);
    _adjustmentHistory.add(adjustment);
  }
  
  /// Reseta o sistema para configurações padrão
  void resetToDefault() {
    _currentSettings = DifficultySettings.medium();
    _performanceData.reset();
    _adjustmentHistory.clear();
    _lastAnalysis = DateTime.now();
  }
  
  /// Obtém relatório de performance
  Map<String, dynamic> getPerformanceReport() {
    final analysis = _analyzePerformance();
    
    return {
      'isActive': _isActive,
      'totalGames': _performanceData.totalGames,
      'playerWins': _performanceData.playerWins,
      'winRate': analysis.winRate,
      'averageReactionTime': analysis.averageReactionTime,
      'averageBallSpeed': analysis.averageBallSpeed,
      'averageAccuracy': analysis.averageAccuracy,
      'consistency': analysis.consistency,
      'recentTrend': analysis.recentTrend,
      'currentDifficulty': _currentSettings.toMap(),
      'adjustmentHistory': _adjustmentHistory.map((a) => a.toMap()).toList(),
    };
  }
  
  /// Carrega configurações de um mapa
  void loadSettings(Map<String, dynamic> data) {
    if (data.containsKey('currentSettings')) {
      _currentSettings = DifficultySettings.fromMap(data['currentSettings']);
    }
    
    if (data.containsKey('performanceData')) {
      _performanceData.fromMap(data['performanceData']);
    }
  }
  
  /// Salva configurações em um mapa
  Map<String, dynamic> saveSettings() {
    return {
      'currentSettings': _currentSettings.toMap(),
      'performanceData': _performanceData.toMap(),
      'isActive': _isActive,
    };
  }
}

/// Dados de performance do jogador
class PlayerPerformanceData {
  int playerWins = 0;
  int aiWins = 0;
  int totalGames = 0;
  int totalHits = 0;
  double totalBallSpeed = 0.0;
  double totalAccuracy = 0.0;
  List<double> reactionTimes = [];
  List<DateTime> recentHitTimes = [];
  DateTime? lastPlayerScoreTime;
  DateTime? lastAIScoreTime;
  
  void reset() {
    playerWins = 0;
    aiWins = 0;
    totalGames = 0;
    totalHits = 0;
    totalBallSpeed = 0.0;
    totalAccuracy = 0.0;
    reactionTimes.clear();
    recentHitTimes.clear();
    lastPlayerScoreTime = null;
    lastAIScoreTime = null;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'playerWins': playerWins,
      'aiWins': aiWins,
      'totalGames': totalGames,
      'totalHits': totalHits,
      'totalBallSpeed': totalBallSpeed,
      'totalAccuracy': totalAccuracy,
      'reactionTimes': reactionTimes,
    };
  }
  
  void fromMap(Map<String, dynamic> data) {
    playerWins = data['playerWins'] ?? 0;
    aiWins = data['aiWins'] ?? 0;
    totalGames = data['totalGames'] ?? 0;
    totalHits = data['totalHits'] ?? 0;
    totalBallSpeed = data['totalBallSpeed']?.toDouble() ?? 0.0;
    totalAccuracy = data['totalAccuracy']?.toDouble() ?? 0.0;
    reactionTimes = (data['reactionTimes'] as List?)?.cast<double>() ?? [];
  }
}

/// Configurações de dificuldade
class DifficultySettings {
  double aiReactionSpeed;
  double aiAccuracy;
  double aiAggression;
  double predictionFactor;
  DateTime lastModified;
  
  DifficultySettings({
    required this.aiReactionSpeed,
    required this.aiAccuracy,
    required this.aiAggression,
    required this.predictionFactor,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();
  
  factory DifficultySettings.easy() {
    return DifficultySettings(
      aiReactionSpeed: 0.04,
      aiAccuracy: 0.4,
      aiAggression: 0.3,
      predictionFactor: 0.2,
    );
  }
  
  factory DifficultySettings.medium() {
    return DifficultySettings(
      aiReactionSpeed: 0.08,
      aiAccuracy: 0.6,
      aiAggression: 0.5,
      predictionFactor: 0.4,
    );
  }
  
  factory DifficultySettings.hard() {
    return DifficultySettings(
      aiReactionSpeed: 0.12,
      aiAccuracy: 0.8,
      aiAggression: 0.7,
      predictionFactor: 0.6,
    );
  }
  
  factory DifficultySettings.fromSettings(DifficultySettings other) {
    return DifficultySettings(
      aiReactionSpeed: other.aiReactionSpeed,
      aiAccuracy: other.aiAccuracy,
      aiAggression: other.aiAggression,
      predictionFactor: other.predictionFactor,
      lastModified: other.lastModified,
    );
  }
  
  factory DifficultySettings.fromMap(Map<String, dynamic> data) {
    return DifficultySettings(
      aiReactionSpeed: data['aiReactionSpeed']?.toDouble() ?? 0.08,
      aiAccuracy: data['aiAccuracy']?.toDouble() ?? 0.6,
      aiAggression: data['aiAggression']?.toDouble() ?? 0.5,
      predictionFactor: data['predictionFactor']?.toDouble() ?? 0.4,
      lastModified: data['lastModified'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(data['lastModified']) : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'aiReactionSpeed': aiReactionSpeed,
      'aiAccuracy': aiAccuracy,
      'aiAggression': aiAggression,
      'predictionFactor': predictionFactor,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }
}

/// Análise de performance
class PerformanceAnalysis {
  double winRate = 0.0;
  double averageBallSpeed = 0.0;
  double averageAccuracy = 0.0;
  double averageReactionTime = 0.0;
  double consistency = 0.0;
  double recentTrend = 0.0;
  bool needsAdjustment = false;
  AdjustmentDirection adjustmentDirection = AdjustmentDirection.none;
}

/// Ajuste de dificuldade
class DifficultyAdjustment {
  final DateTime timestamp;
  final AdjustmentDirection direction;
  final String reason;
  final DifficultySettings previousSettings;
  DifficultySettings? newSettings;
  final double playerWinRate;
  final double averageReactionTime;
  
  DifficultyAdjustment({
    required this.timestamp,
    required this.direction,
    required this.reason,
    required this.previousSettings,
    this.newSettings,
    required this.playerWinRate,
    required this.averageReactionTime,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'direction': direction.toString(),
      'reason': reason,
      'playerWinRate': playerWinRate,
      'averageReactionTime': averageReactionTime,
      'previousSettings': previousSettings.toMap(),
      'newSettings': newSettings?.toMap(),
    };
  }
}

/// Configuração do sistema adaptativo
class AdaptiveConfig {
  final int minGamesBeforeAdjustment = 5;
  final double maxWinRateThreshold = 0.7;
  final double minWinRateThreshold = 0.3;
  final double trendThreshold = 0.2;
  final double reactionTimeThreshold = 100.0; // ms
  final int analysisIntervalSeconds = 30;
  final int maxRecentHits = 20;
  final int maxReactionSamples = 15;
  final int maxHistorySize = 50;
}

/// Direção do ajuste de dificuldade
enum AdjustmentDirection {
  easier,
  harder,
  none
}
