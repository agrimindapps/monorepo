/// Modelo da bola do jogo Ping Pong
/// 
/// Classe que encapsula todas as propriedades e comportamentos da bola,
/// incluindo posição, velocidade e lógica de movimento.
library;

// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

/// Representa a bola no jogo de Ping Pong
class Ball {
  /// Posição atual da bola no eixo X
  double x;
  
  /// Posição atual da bola no eixo Y
  double y;
  
  /// Velocidade da bola no eixo X
  double speedX;
  
  /// Velocidade da bola no eixo Y
  double speedY;
  
  /// Tamanho/raio da bola
  final double size;
  
  /// Gerador de números aleatórios para comportamentos imprevisíveis
  static final Random _random = Random();
  
  /// Cria uma nova instância da bola
  Ball({
    this.x = 0.0,
    this.y = 0.0,
    this.speedX = GameConfig.initialBallSpeed,
    this.speedY = GameConfig.initialBallSpeed,
    this.size = GameConfig.ballRadius,
  });
  
  /// Reseta a bola para a posição central com velocidade aleatória
  void reset() {
    x = 0.0;
    y = 0.0;
    
    // Direção aleatória no eixo X
    speedX = _random.nextBool() 
        ? GameConfig.initialBallSpeed 
        : -GameConfig.initialBallSpeed;
    
    // Velocidade aleatória no eixo Y
    speedY = _random.nextDouble() * 
        (PhysicsConfig.maxRandomAngle - PhysicsConfig.minRandomAngle) + 
        PhysicsConfig.minRandomAngle;
  }
  
  /// Atualiza a posição da bola com base na velocidade atual
  void updatePosition() {
    x += speedX;
    y += speedY;
  }
  
  /// Inverte a velocidade horizontal (colisão com raquetes)
  void reverseHorizontal() {
    speedX = -speedX;
    _increaseSpeed();
  }
  
  /// Inverte a velocidade vertical (colisão com paredes)
  void reverseVertical() {
    speedY = -speedY;
  }
  
  /// Ajusta o ângulo da bola baseado na posição de impacto na raquete
  /// 
  /// [relativeImpactY] - Posição relativa do impacto (-1.0 a 1.0)
  void adjustAngle(double relativeImpactY) {
    speedY = relativeImpactY * GameConfig.maxAngleEffect;
  }
  
  /// Aumenta ligeiramente a velocidade da bola a cada rebatida
  void _increaseSpeed() {
    speedX *= GameConfig.ballSpeedIncrease;
    speedY *= GameConfig.ballSpeedIncrease;
    _capSpeed();
  }
  
  /// Limita a velocidade máxima da bola
  void _capSpeed() {
    if (speedX.abs() > GameConfig.maxBallSpeed) {
      speedX = GameConfig.maxBallSpeed * (speedX > 0 ? 1 : -1);
    }
    if (speedY.abs() > GameConfig.maxBallSpeed) {
      speedY = GameConfig.maxBallSpeed * (speedY > 0 ? 1 : -1);
    }
  }
  
  /// Verifica se a bola colidiu com a parede superior ou inferior
  /// 
  /// [screenHeight] - Altura da tela do jogo
  /// Returns true se houve colisão
  bool checkWallCollision(double screenHeight) {
    final halfHeight = screenHeight / 2;
    return (y <= -halfHeight + size) || (y >= halfHeight - size);
  }
  
  /// Verifica se a bola saiu pela lateral esquerda
  /// 
  /// [screenWidth] - Largura da tela do jogo
  /// Returns true se a bola saiu pela esquerda
  bool isOutLeft(double screenWidth) {
    return x < -screenWidth / 2 - size;
  }
  
  /// Verifica se a bola saiu pela lateral direita
  /// 
  /// [screenWidth] - Largura da tela do jogo
  /// Returns true se a bola saiu pela direita
  bool isOutRight(double screenWidth) {
    return x > screenWidth / 2 + size;
  }
  
  /// Obtém a velocidade atual da bola
  double get currentSpeed {
    return sqrt(speedX * speedX + speedY * speedY);
  }
  
  /// Obtém a velocidade máxima alcançada
  double get maxSpeed {
    return max(speedX.abs(), speedY.abs());
  }
  
  /// Verifica se a bola está se movendo para a direita
  bool get isMovingRight => speedX > 0;
  
  /// Verifica se a bola está se movendo para a esquerda
  bool get isMovingLeft => speedX < 0;
  
  /// Verifica se a bola está se movendo para cima
  bool get isMovingUp => speedY < 0;
  
  /// Verifica se a bola está se movendo para baixo
  bool get isMovingDown => speedY > 0;
  
  /// Cria uma cópia da bola
  Ball copy() {
    return Ball(
      x: x,
      y: y,
      speedX: speedX,
      speedY: speedY,
      size: size,
    );
  }
  
  @override
  String toString() {
    return 'Ball(x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}, '
           'speedX: ${speedX.toStringAsFixed(2)}, speedY: ${speedY.toStringAsFixed(2)})';
  }
}
