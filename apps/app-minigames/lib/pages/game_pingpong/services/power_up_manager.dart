// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';
import 'package:app_minigames/models/power_up.dart';
import 'package:app_minigames/services/audio_manager.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Gerenciador de power-ups para o jogo Ping Pong
///
/// Controla spawning, coleta e efeitos dos power-ups durante o jogo.
/// Integra com o sistema de jogo para aplicar efeitos temporários.


/// Gerenciador de power-ups
class PowerUpManager extends ChangeNotifier {
  /// Estado do jogo
  PingPongGameState? _gameState;

  /// Gerenciador de áudio
  AudioManager? _audioManager;

  /// Gerenciador de temas (para futuras funcionalidades visuais)
  // ignore: unused_field
  ThemeManager? _themeManager;

  /// Lista de power-ups ativos
  final List<PowerUp> _activePowerUps = [];

  /// Lista de efeitos ativos
  final List<ActiveEffect> _activeEffects = [];

  /// Configurações de spawn
  double _spawnRate = 0.3; // Chance por segundo
  double _timeSinceLastSpawn = 0.0;
  double _minSpawnInterval = 5.0; // Segundos
  double _maxSpawnInterval = 15.0; // Segundos

  /// Dimensões da tela
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;

  /// Random generator
  final Random _random = Random();

  /// Timer para atualizações
  Timer? _updateTimer;

  /// Estado das configurações
  bool _powerUpsEnabled = true;
  double _effectIntensity = 1.0;

  /// Getters
  List<PowerUp> get activePowerUps => List.unmodifiable(_activePowerUps);
  List<ActiveEffect> get activeEffects => List.unmodifiable(_activeEffects);
  bool get powerUpsEnabled => _powerUpsEnabled;
  double get effectIntensity => _effectIntensity;

  /// Inicializa o gerenciador
  void initialize({
    required PingPongGameState gameState,
    AudioManager? audioManager,
    ThemeManager? themeManager,
  }) {
    _gameState = gameState;
    _audioManager = audioManager;
    _themeManager = themeManager;

    _gameState?.addListener(_onGameStateChanged);

    debugPrint('PowerUpManager inicializado');
  }

  /// Define dimensões da tela
  void setScreenDimensions(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  /// Configura power-ups
  void configurePowerUps({
    bool? enabled,
    double? spawnRate,
    double? effectIntensity,
    double? minSpawnInterval,
    double? maxSpawnInterval,
  }) {
    _powerUpsEnabled = enabled ?? _powerUpsEnabled;
    _spawnRate = spawnRate ?? _spawnRate;
    _effectIntensity = effectIntensity ?? _effectIntensity;
    _minSpawnInterval = minSpawnInterval ?? _minSpawnInterval;
    _maxSpawnInterval = maxSpawnInterval ?? _maxSpawnInterval;

    notifyListeners();
  }

  /// Inicia o sistema de power-ups
  void startPowerUpSystem() {
    if (!_powerUpsEnabled) return;

    _activePowerUps.clear();
    _activeEffects.clear();
    _timeSinceLastSpawn = 0.0;

    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) => _update(),
    );

    debugPrint('Sistema de power-ups iniciado');
  }

  /// Para o sistema de power-ups
  void stopPowerUpSystem() {
    _updateTimer?.cancel();
    _updateTimer = null;

    _activePowerUps.clear();
    _activeEffects.clear();

    debugPrint('Sistema de power-ups parado');
    notifyListeners();
  }

  /// Atualiza o sistema
  void _update() {
    if (_gameState == null || !_gameState!.isPlaying || !_powerUpsEnabled) {
      return;
    }

    const deltaTime = 0.1; // 100ms

    // Atualiza power-ups existentes
    _updatePowerUps(deltaTime);

    // Verifica spawn de novos power-ups
    _checkSpawnPowerUps(deltaTime);

    // Atualiza efeitos ativos
    _updateActiveEffects(deltaTime);

    // Verifica colisões
    _checkCollisions();

    notifyListeners();
  }

  /// Atualiza power-ups existentes
  void _updatePowerUps(double deltaTime) {
    for (int i = _activePowerUps.length - 1; i >= 0; i--) {
      final powerUp = _activePowerUps[i];
      powerUp.update(deltaTime);

      if (!powerUp.isActive) {
        _activePowerUps.removeAt(i);
      }
    }
  }

  /// Verifica spawn de novos power-ups
  void _checkSpawnPowerUps(double deltaTime) {
    _timeSinceLastSpawn += deltaTime;

    if (_timeSinceLastSpawn >= _minSpawnInterval) {
      final spawnChance = _spawnRate * deltaTime;

      if (_random.nextDouble() < spawnChance ||
          _timeSinceLastSpawn >= _maxSpawnInterval) {
        _spawnRandomPowerUp();
        _timeSinceLastSpawn = 0.0;
      }
    }
  }

  /// Spawna um power-up aleatório
  void _spawnRandomPowerUp() {
    if (_activePowerUps.length >= 3) return; // Máximo 3 power-ups simultâneos

    final powerUpType = _selectRandomPowerUpType();
    final position = _generateSafeSpawnPosition();

    final powerUp = PowerUp(
      x: position.dx,
      y: position.dy,
      type: powerUpType,
      size: 30.0 + _random.nextDouble() * 20.0, // Tamanho variável
      timeToLive: 10.0 + _random.nextDouble() * 10.0, // 10-20 segundos
      animationSpeed: 1.0 + _random.nextDouble() * 2.0,
    );

    _activePowerUps.add(powerUp);

    debugPrint(
        'Power-up spawned: ${powerUpType.name} at (${position.dx.toInt()}, ${position.dy.toInt()})');
  }

  /// Seleciona tipo de power-up baseado na raridade
  PowerUpType _selectRandomPowerUpType() {
    final totalWeight =
        PowerUpType.values.fold(0.0, (sum, type) => sum + type.rarity);
    final randomValue = _random.nextDouble() * totalWeight;

    double currentWeight = 0.0;
    for (final type in PowerUpType.values) {
      currentWeight += type.rarity;
      if (randomValue <= currentWeight) {
        return type;
      }
    }

    return PowerUpType.speedBoost; // Fallback
  }

  /// Gera posição segura para spawn
  Offset _generateSafeSpawnPosition() {
    if (_gameState == null) return Offset.zero;

    // Evita spawnar muito próximo das raquetes ou da bola
    final ball = _gameState!.ball;
    const safeZoneRadius = 100.0;

    int attempts = 0;
    const maxAttempts = 10;

    while (attempts < maxAttempts) {
      final x = (_random.nextDouble() - 0.5) * _screenWidth * 0.8;
      final y = (_random.nextDouble() - 0.5) * _screenHeight * 0.8;

      final position = Offset(x, y);
      final distanceToBall = (position - Offset(ball.x, ball.y)).distance;

      if (distanceToBall > safeZoneRadius) {
        return position;
      }

      attempts++;
    }

    // Fallback: centro da tela
    return Offset.zero;
  }

  /// Verifica colisões com power-ups
  void _checkCollisions() {
    if (_gameState == null) return;

    final ball = _gameState!.ball;
    final playerPaddle = _gameState!.playerPaddle;
    final aiPaddle = _gameState!.aiPaddle;

    for (final powerUp in _activePowerUps) {
      if (powerUp.isCollected) continue;

      bool collected = false;
      PaddleType? collector;

      // Verifica colisão com raquete do jogador
      if (powerUp.checkCollisionWithPaddle(
        playerPaddle.x,
        playerPaddle.y,
        playerPaddle.width,
        playerPaddle.height,
      )) {
        collected = true;
        collector = PaddleType.player;
      }
      // Verifica colisão com raquete da IA
      else if (powerUp.checkCollisionWithPaddle(
        aiPaddle.x,
        aiPaddle.y,
        aiPaddle.width,
        aiPaddle.height,
      )) {
        collected = true;
        collector = PaddleType.ai;
      }
      // Verifica colisão com bola
      else if (powerUp.checkCollisionWithBall(
        ball.x,
        ball.y,
        ball.size,
      )) {
        collected = true;
        collector = null; // Bola não tem dono específico
      }

      if (collected) {
        _collectPowerUp(powerUp, collector);
      }
    }
  }

  /// Coleta um power-up
  void _collectPowerUp(PowerUp powerUp, PaddleType? collector) {
    powerUp.collect();

    // Toca som de coleta
    if (_audioManager != null) {
      // _audioManager!.playSound(SoundEffect.powerUpCollect);
    }

    // Aplica efeito
    _applyPowerUpEffect(powerUp, collector);

    debugPrint(
        'Power-up collected: ${powerUp.type.name} by ${collector?.name ?? "ball"}');
  }

  /// Aplica efeito do power-up
  void _applyPowerUpEffect(PowerUp powerUp, PaddleType? collector) {
    final effect = ActiveEffect(
      type: powerUp.type,
      duration: powerUp.type.duration,
      intensity: _effectIntensity,
      collector: collector,
      startTime: DateTime.now(),
    );

    _activeEffects.add(effect);

    // Aplica efeito imediato baseado no tipo
    _applyImmediateEffect(effect);

    debugPrint('Efeito aplicado: ${powerUp.type.name} por ${effect.duration}s');
  }

  /// Aplica efeito imediato
  void _applyImmediateEffect(ActiveEffect effect) {
    if (_gameState == null) return;

    switch (effect.type) {
      case PowerUpType.extraLife:
        if (effect.collector == PaddleType.player) {
          // Remove 1 ponto da IA
          if (_gameState!.aiScore > 0) {
            _gameState!.addPlayerScore();
          }
        }
        break;

      case PowerUpType.pointSteal:
        if (effect.collector == PaddleType.player && _gameState!.aiScore > 0) {
          // Rouba 1 ponto da IA
          _gameState!.addPlayerScore();
        }
        break;

      case PowerUpType.multiball:
        // Cria bolas adicionais (simulado)
        _createMultiballEffect();
        break;

      default:
        // Outros efeitos são aplicados continuamente
        break;
    }
  }

  /// Cria efeito de multibola
  void _createMultiballEffect() {
    // Simula criação de bolas adicionais
    debugPrint('Efeito multiball ativado');

    // Aqui você implementaria a lógica para criar bolas adicionais
    // Por simplicidade, vamos apenas aumentar a velocidade da bola atual
    if (_gameState != null) {
      final ball = _gameState!.ball;
      ball.speedX *= 1.5;
      ball.speedY *= 1.5;
    }
  }

  /// Atualiza efeitos ativos
  void _updateActiveEffects(double deltaTime) {
    for (int i = _activeEffects.length - 1; i >= 0; i--) {
      final effect = _activeEffects[i];
      effect.update(deltaTime);

      if (effect.isExpired) {
        _removeEffect(effect);
        _activeEffects.removeAt(i);
      }
    }
  }

  /// Remove efeito
  void _removeEffect(ActiveEffect effect) {
    // Reverte efeitos que precisam ser revertidos
    switch (effect.type) {
      case PowerUpType.speedBoost:
      case PowerUpType.slowMotion:
        // Reverte velocidade da bola
        if (_gameState != null) {
          final ball = _gameState!.ball;
          ball.speedX /= (effect.type == PowerUpType.speedBoost ? 1.5 : 0.7);
          ball.speedY /= (effect.type == PowerUpType.speedBoost ? 1.5 : 0.7);
        }
        break;

      case PowerUpType.bigPaddle:
      case PowerUpType.smallPaddle:
        // Reverte tamanho das raquetes
        if (_gameState != null) {
          // Resetar tamanho das raquetes para o padrão
          // Implementação específica dependeria da estrutura do Paddle
        }
        break;

      default:
        break;
    }

    debugPrint('Efeito removido: ${effect.type.name}');
  }

  /// Aplica efeitos contínuos
  void applyContinuousEffects() {
    if (_gameState == null) return;

    for (final effect in _activeEffects) {
      _applyContinuousEffect(effect);
    }
  }

  /// Aplica efeito contínuo específico
  void _applyContinuousEffect(ActiveEffect effect) {
    if (_gameState == null) return;

    switch (effect.type) {
      case PowerUpType.magneticPaddle:
        if (effect.collector == PaddleType.player) {
          _applyMagneticPaddleEffect(_gameState!.playerPaddle);
        }
        break;

      case PowerUpType.fastPaddle:
        if (effect.collector == PaddleType.player) {
          // Aplicar multiplicador de velocidade à raquete
          // Implementação específica dependeria da estrutura do Paddle
        }
        break;

      case PowerUpType.freeze:
        if (effect.collector == PaddleType.player) {
          // Congelar raquete da IA
          // Implementação específica dependeria da estrutura do Paddle
        }
        break;

      default:
        break;
    }
  }

  /// Aplica efeito de raquete magnética
  void _applyMagneticPaddleEffect(Paddle paddle) {
    if (_gameState == null) return;

    final ball = _gameState!.ball;
    final distance =
        (Offset(ball.x, ball.y) - Offset(paddle.x, paddle.y)).distance;

    if (distance < 150.0) {
      // Atrai a bola em direção à raquete
      final direction =
          (Offset(paddle.x, paddle.y) - Offset(ball.x, ball.y)).direction;
      final force =
          50.0 / distance; // Força inversamente proporcional à distância

      ball.x += cos(direction) * force * 0.1;
      ball.y += sin(direction) * force * 0.1;
    }
  }

  /// Responde a mudanças no estado do jogo
  void _onGameStateChanged() {
    if (_gameState == null) return;

    if (_gameState!.isPlaying) {
      if (_updateTimer == null) {
        startPowerUpSystem();
      }
    } else {
      stopPowerUpSystem();
    }
  }

  /// Força spawn de power-up específico (para testes)
  void forceSpawnPowerUp(PowerUpType type, {Offset? position}) {
    final spawnPosition = position ?? _generateSafeSpawnPosition();

    final powerUp = PowerUp(
      x: spawnPosition.dx,
      y: spawnPosition.dy,
      type: type,
    );

    _activePowerUps.add(powerUp);
    notifyListeners();
  }

  /// Limpa todos os power-ups
  void clearAllPowerUps() {
    _activePowerUps.clear();
    _activeEffects.clear();
    notifyListeners();
  }

  /// Obtém estatísticas de power-ups
  Map<String, dynamic> getPowerUpStatistics() {
    final effectCounts = <String, int>{};
    for (final effect in _activeEffects) {
      effectCounts[effect.type.name] =
          (effectCounts[effect.type.name] ?? 0) + 1;
    }

    return {
      'activePowerUps': _activePowerUps.length,
      'activeEffects': _activeEffects.length,
      'effectCounts': effectCounts,
      'powerUpsEnabled': _powerUpsEnabled,
      'spawnRate': _spawnRate,
      'timeSinceLastSpawn': _timeSinceLastSpawn,
    };
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _gameState?.removeListener(_onGameStateChanged);
    _activePowerUps.clear();
    _activeEffects.clear();
    super.dispose();
  }
}

/// Representa um efeito ativo de power-up
class ActiveEffect {
  final PowerUpType type;
  final double duration;
  final double intensity;
  final PaddleType? collector;
  final DateTime startTime;

  double _remainingTime;

  ActiveEffect({
    required this.type,
    required this.duration,
    required this.intensity,
    required this.collector,
    required this.startTime,
  }) : _remainingTime = duration;

  /// Atualiza o efeito
  void update(double deltaTime) {
    _remainingTime -= deltaTime;
  }

  /// Verifica se o efeito expirou
  bool get isExpired => _remainingTime <= 0;

  /// Tempo restante
  double get remainingTime => _remainingTime;

  /// Progresso do efeito (0.0 a 1.0)
  double get progress => duration > 0 ? 1.0 - (_remainingTime / duration) : 1.0;

  /// Verifica se está nos últimos segundos
  bool get isExpiring => _remainingTime <= 2.0;

  @override
  String toString() {
    return 'ActiveEffect(type: ${type.name}, remaining: ${_remainingTime.toStringAsFixed(1)}s)';
  }
}
