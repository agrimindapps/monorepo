/// Sistema de power-ups para o jogo Ping Pong
/// 
/// Define diferentes tipos de power-ups que podem aparecer durante o jogo
/// e alterar temporariamente o comportamento dos elementos.
library;

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

/// Modelo de um power-up
class PowerUp {
  /// Posição do power-up
  double x;
  double y;
  
  /// Tipo do power-up
  final PowerUpType type;
  
  /// Tamanho do power-up
  final double size;
  
  /// Tempo de vida restante (em segundos)
  double timeToLive;
  
  /// Se está ativo/visível
  bool isActive;
  
  /// Velocidade de animação (rotação, pulsação, etc)
  double animationSpeed;
  
  /// Fase atual da animação
  double animationPhase;
  
  /// Se foi coletado
  bool isCollected;
  
  /// Timestamp de criação
  final DateTime createdAt;
  
  /// ID único
  final String id;
  
  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    this.size = 40.0,
    this.timeToLive = 15.0,
    this.isActive = true,
    this.animationSpeed = 2.0,
    this.animationPhase = 0.0,
    this.isCollected = false,
  }) : createdAt = DateTime.now(),
       id = _generateId();
  
  /// Gera ID único para o power-up
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
  
  /// Atualiza o power-up (animação, tempo de vida)
  void update(double deltaTime) {
    if (!isActive || isCollected) return;
    
    // Atualiza tempo de vida
    timeToLive -= deltaTime;
    if (timeToLive <= 0) {
      isActive = false;
      return;
    }
    
    // Atualiza animação
    animationPhase += animationSpeed * deltaTime;
    if (animationPhase > 2 * pi) {
      animationPhase -= 2 * pi;
    }
  }
  
  /// Verifica colisão com a bola
  bool checkCollisionWithBall(double ballX, double ballY, double ballSize) {
    if (!isActive || isCollected) return false;
    
    final dx = ballX - x;
    final dy = ballY - y;
    final distance = sqrt(dx * dx + dy * dy);
    
    return distance < (size / 2 + ballSize / 2);
  }
  
  /// Verifica colisão com raquete
  bool checkCollisionWithPaddle(double paddleX, double paddleY, double paddleWidth, double paddleHeight) {
    if (!isActive || isCollected) return false;
    
    // Verifica se o power-up está dentro da área da raquete
    final powerUpLeft = x - size / 2;
    final powerUpRight = x + size / 2;
    final powerUpTop = y - size / 2;
    final powerUpBottom = y + size / 2;
    
    final paddleLeft = paddleX - paddleWidth / 2;
    final paddleRight = paddleX + paddleWidth / 2;
    final paddleTop = paddleY - paddleHeight / 2;
    final paddleBottom = paddleY + paddleHeight / 2;
    
    return powerUpLeft < paddleRight &&
           powerUpRight > paddleLeft &&
           powerUpTop < paddleBottom &&
           powerUpBottom > paddleTop;
  }
  
  /// Coleta o power-up
  void collect() {
    isCollected = true;
    isActive = false;
  }
  
  /// Verifica se o power-up está expirando (últimos 3 segundos)
  bool get isExpiring => timeToLive <= 3.0;
  
  /// Obtém a cor do power-up baseada no tipo
  Color get color => type.color;
  
  /// Obtém o ícone do power-up
  IconData get icon => type.icon;
  
  /// Obtém o valor de opacidade para animação de expiração
  double get opacity {
    if (!isActive) return 0.0;
    if (isExpiring) {
      // Pisca quando está expirando
      return 0.3 + 0.7 * (sin(animationPhase * 8) + 1) / 2;
    }
    return 1.0;
  }
  
  /// Obtém o valor de escala para animação de pulsação
  double get scale {
    if (!isActive) return 0.0;
    return 1.0 + 0.1 * sin(animationPhase * 4);
  }
  
  /// Obtém a rotação para animação
  double get rotation => animationPhase;
  
  /// Cria cópia do power-up
  PowerUp copy() {
    return PowerUp(
      x: x,
      y: y,
      type: type,
      size: size,
      timeToLive: timeToLive,
      isActive: isActive,
      animationSpeed: animationSpeed,
      animationPhase: animationPhase,
      isCollected: isCollected,
    );
  }
  
  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'type': type.index,
      'size': size,
      'timeToLive': timeToLive,
      'isActive': isActive,
      'animationSpeed': animationSpeed,
      'animationPhase': animationPhase,
      'isCollected': isCollected,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
  
  /// Cria PowerUp a partir de Map
  factory PowerUp.fromMap(Map<String, dynamic> map) {
    final powerUp = PowerUp(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      type: PowerUpType.values[map['type'] ?? 0],
      size: map['size']?.toDouble() ?? 40.0,
      timeToLive: map['timeToLive']?.toDouble() ?? 15.0,
      isActive: map['isActive'] ?? true,
      animationSpeed: map['animationSpeed']?.toDouble() ?? 2.0,
      animationPhase: map['animationPhase']?.toDouble() ?? 0.0,
      isCollected: map['isCollected'] ?? false,
    );
    
    return powerUp;
  }
  
  @override
  String toString() {
    return 'PowerUp(type: ${type.name}, x: ${x.toStringAsFixed(1)}, y: ${y.toStringAsFixed(1)}, ttl: ${timeToLive.toStringAsFixed(1)})';
  }
}

/// Tipos de power-ups disponíveis
enum PowerUpType {
  // Power-ups da bola
  speedBoost,        // Aumenta velocidade da bola
  slowMotion,        // Diminui velocidade da bola
  multiball,         // Cria múltiplas bolas
  bigBall,           // Aumenta tamanho da bola
  smallBall,         // Diminui tamanho da bola
  
  // Power-ups da raquete
  bigPaddle,         // Aumenta tamanho da raquete
  smallPaddle,       // Diminui tamanho da raquete (do oponente)
  fastPaddle,        // Aumenta velocidade da raquete
  magneticPaddle,    // Raquete atrai a bola
  
  // Power-ups especiais
  shield,            // Escudo que bloqueia 1 ponto
  extraLife,         // Vida extra (reduz 1 ponto do oponente)
  freeze,            // Congela o oponente por alguns segundos
  confusion,         // Inverte controles do oponente
  
  // Power-ups visuais/ambientais
  fogOfWar,          // Escurece a tela parcialmente
  rainbow,           // Deixa rastro colorido na bola
  earthquake,        // Balança a tela
  
  // Power-ups de pontuação
  doublePoints,      // Próximo ponto vale 2
  pointSteal,        // Rouba 1 ponto do oponente
}

/// Extensão para propriedades dos tipos de power-up
extension PowerUpTypeExtension on PowerUpType {
  /// Nome do power-up
  String get name {
    switch (this) {
      case PowerUpType.speedBoost:
        return 'Velocidade Turbo';
      case PowerUpType.slowMotion:
        return 'Câmera Lenta';
      case PowerUpType.multiball:
        return 'Multi-Bola';
      case PowerUpType.bigBall:
        return 'Bola Grande';
      case PowerUpType.smallBall:
        return 'Bola Pequena';
      case PowerUpType.bigPaddle:
        return 'Raquete Grande';
      case PowerUpType.smallPaddle:
        return 'Raquete Pequena';
      case PowerUpType.fastPaddle:
        return 'Raquete Rápida';
      case PowerUpType.magneticPaddle:
        return 'Raquete Magnética';
      case PowerUpType.shield:
        return 'Escudo';
      case PowerUpType.extraLife:
        return 'Vida Extra';
      case PowerUpType.freeze:
        return 'Congelamento';
      case PowerUpType.confusion:
        return 'Confusão';
      case PowerUpType.fogOfWar:
        return 'Névoa';
      case PowerUpType.rainbow:
        return 'Arco-Íris';
      case PowerUpType.earthquake:
        return 'Terremoto';
      case PowerUpType.doublePoints:
        return 'Pontos Duplos';
      case PowerUpType.pointSteal:
        return 'Roubo de Pontos';
    }
  }
  
  /// Descrição do power-up
  String get description {
    switch (this) {
      case PowerUpType.speedBoost:
        return 'Aumenta a velocidade da bola temporariamente';
      case PowerUpType.slowMotion:
        return 'Diminui a velocidade da bola';
      case PowerUpType.multiball:
        return 'Cria 2 bolas adicionais';
      case PowerUpType.bigBall:
        return 'Aumenta o tamanho da bola';
      case PowerUpType.smallBall:
        return 'Diminui o tamanho da bola';
      case PowerUpType.bigPaddle:
        return 'Aumenta o tamanho da sua raquete';
      case PowerUpType.smallPaddle:
        return 'Diminui a raquete do oponente';
      case PowerUpType.fastPaddle:
        return 'Aumenta a velocidade da sua raquete';
      case PowerUpType.magneticPaddle:
        return 'Sua raquete atrai a bola';
      case PowerUpType.shield:
        return 'Bloqueia o próximo ponto contra você';
      case PowerUpType.extraLife:
        return 'Remove 1 ponto do oponente';
      case PowerUpType.freeze:
        return 'Congela o oponente por 5 segundos';
      case PowerUpType.confusion:
        return 'Inverte os controles do oponente';
      case PowerUpType.fogOfWar:
        return 'Escurece parte da tela';
      case PowerUpType.rainbow:
        return 'Bola deixa rastro colorido';
      case PowerUpType.earthquake:
        return 'Balança a tela por alguns segundos';
      case PowerUpType.doublePoints:
        return 'Seu próximo ponto vale 2';
      case PowerUpType.pointSteal:
        return 'Rouba 1 ponto do oponente';
    }
  }
  
  /// Cor do power-up
  Color get color {
    switch (this) {
      case PowerUpType.speedBoost:
        return Colors.red;
      case PowerUpType.slowMotion:
        return Colors.blue;
      case PowerUpType.multiball:
        return Colors.purple;
      case PowerUpType.bigBall:
        return Colors.orange;
      case PowerUpType.smallBall:
        return Colors.cyan;
      case PowerUpType.bigPaddle:
        return Colors.green;
      case PowerUpType.smallPaddle:
        return Colors.red.shade300;
      case PowerUpType.fastPaddle:
        return Colors.yellow;
      case PowerUpType.magneticPaddle:
        return Colors.pink;
      case PowerUpType.shield:
        return Colors.blue.shade700;
      case PowerUpType.extraLife:
        return Colors.green.shade700;
      case PowerUpType.freeze:
        return Colors.lightBlue;
      case PowerUpType.confusion:
        return Colors.deepPurple;
      case PowerUpType.fogOfWar:
        return Colors.grey;
      case PowerUpType.rainbow:
        return Colors.red;
      case PowerUpType.earthquake:
        return Colors.brown;
      case PowerUpType.doublePoints:
        return Colors.amber;
      case PowerUpType.pointSteal:
        return Colors.deepOrange;
    }
  }
  
  /// Ícone do power-up
  IconData get icon {
    switch (this) {
      case PowerUpType.speedBoost:
        return Icons.flash_on;
      case PowerUpType.slowMotion:
        return Icons.slow_motion_video;
      case PowerUpType.multiball:
        return Icons.control_point_duplicate;
      case PowerUpType.bigBall:
        return Icons.zoom_in;
      case PowerUpType.smallBall:
        return Icons.zoom_out;
      case PowerUpType.bigPaddle:
        return Icons.unfold_more;
      case PowerUpType.smallPaddle:
        return Icons.unfold_less;
      case PowerUpType.fastPaddle:
        return Icons.speed;
      case PowerUpType.magneticPaddle:
        return Icons.settings_input_component;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.extraLife:
        return Icons.favorite;
      case PowerUpType.freeze:
        return Icons.ac_unit;
      case PowerUpType.confusion:
        return Icons.shuffle;
      case PowerUpType.fogOfWar:
        return Icons.cloud;
      case PowerUpType.rainbow:
        return Icons.palette;
      case PowerUpType.earthquake:
        return Icons.vibration;
      case PowerUpType.doublePoints:
        return Icons.double_arrow;
      case PowerUpType.pointSteal:
        return Icons.money_off;
    }
  }
  
  /// Duração do efeito em segundos
  double get duration {
    switch (this) {
      case PowerUpType.speedBoost:
        return 8.0;
      case PowerUpType.slowMotion:
        return 6.0;
      case PowerUpType.multiball:
        return 10.0;
      case PowerUpType.bigBall:
        return 12.0;
      case PowerUpType.smallBall:
        return 10.0;
      case PowerUpType.bigPaddle:
        return 15.0;
      case PowerUpType.smallPaddle:
        return 12.0;
      case PowerUpType.fastPaddle:
        return 10.0;
      case PowerUpType.magneticPaddle:
        return 8.0;
      case PowerUpType.shield:
        return 0.0; // Instantâneo, mas fica ativo até ser usado
      case PowerUpType.extraLife:
        return 0.0; // Instantâneo
      case PowerUpType.freeze:
        return 5.0;
      case PowerUpType.confusion:
        return 8.0;
      case PowerUpType.fogOfWar:
        return 10.0;
      case PowerUpType.rainbow:
        return 15.0;
      case PowerUpType.earthquake:
        return 4.0;
      case PowerUpType.doublePoints:
        return 0.0; // Ativo até o próximo ponto
      case PowerUpType.pointSteal:
        return 0.0; // Instantâneo
    }
  }
  
  /// Raridade do power-up (1.0 = comum, 0.1 = muito raro)
  double get rarity {
    switch (this) {
      case PowerUpType.speedBoost:
        return 0.8;
      case PowerUpType.slowMotion:
        return 0.7;
      case PowerUpType.multiball:
        return 0.3;
      case PowerUpType.bigBall:
        return 0.6;
      case PowerUpType.smallBall:
        return 0.6;
      case PowerUpType.bigPaddle:
        return 0.7;
      case PowerUpType.smallPaddle:
        return 0.5;
      case PowerUpType.fastPaddle:
        return 0.6;
      case PowerUpType.magneticPaddle:
        return 0.4;
      case PowerUpType.shield:
        return 0.3;
      case PowerUpType.extraLife:
        return 0.2;
      case PowerUpType.freeze:
        return 0.4;
      case PowerUpType.confusion:
        return 0.3;
      case PowerUpType.fogOfWar:
        return 0.4;
      case PowerUpType.rainbow:
        return 0.8;
      case PowerUpType.earthquake:
        return 0.5;
      case PowerUpType.doublePoints:
        return 0.3;
      case PowerUpType.pointSteal:
        return 0.2;
    }
  }
  
  /// Se o power-up afeta o jogador que o coletou (true) ou o oponente (false)
  bool get affectsCollector {
    switch (this) {
      case PowerUpType.speedBoost:
        return true; // Neutro - afeta a bola
      case PowerUpType.slowMotion:
        return true; // Neutro - afeta a bola
      case PowerUpType.multiball:
        return true; // Neutro - afeta o jogo
      case PowerUpType.bigBall:
        return true; // Neutro - afeta a bola
      case PowerUpType.smallBall:
        return true; // Neutro - afeta a bola
      case PowerUpType.bigPaddle:
        return true; // Positivo para quem coleta
      case PowerUpType.smallPaddle:
        return false; // Negativo para o oponente
      case PowerUpType.fastPaddle:
        return true; // Positivo para quem coleta
      case PowerUpType.magneticPaddle:
        return true; // Positivo para quem coleta
      case PowerUpType.shield:
        return true; // Positivo para quem coleta
      case PowerUpType.extraLife:
        return true; // Positivo para quem coleta
      case PowerUpType.freeze:
        return false; // Negativo para o oponente
      case PowerUpType.confusion:
        return false; // Negativo para o oponente
      case PowerUpType.fogOfWar:
        return false; // Negativo para o oponente
      case PowerUpType.rainbow:
        return true; // Neutro - visual
      case PowerUpType.earthquake:
        return true; // Neutro - afeta ambos
      case PowerUpType.doublePoints:
        return true; // Positivo para quem coleta
      case PowerUpType.pointSteal:
        return true; // Positivo para quem coleta
    }
  }
}
