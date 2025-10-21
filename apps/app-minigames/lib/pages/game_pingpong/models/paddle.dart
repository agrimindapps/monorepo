/// Modelo da raquete do jogo Ping Pong
/// 
/// Classe que representa tanto a raquete do jogador quanto da IA,
/// incluindo posição, movimento e zona de colisão.
library;

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

/// Tipos de raquete no jogo
enum PaddleType {
  player,
  ai
}

/// Representa uma raquete no jogo de Ping Pong
class Paddle {
  /// Posição atual da raquete no eixo Y
  double y;
  
  /// Posição fixa da raquete no eixo X
  final double x;
  
  /// Largura da raquete
  final double width;
  
  /// Altura da raquete
  final double height;
  
  /// Tipo da raquete (jogador ou IA)
  final PaddleType type;
  
  /// Velocidade atual de movimento da raquete
  double velocity;
  
  /// Última posição Y para calcular velocidade
  double _lastY;
  
  /// Cria uma nova instância da raquete
  Paddle({
    this.y = 0.0,
    required this.x,
    this.width = GameConfig.paddleWidth,
    this.height = GameConfig.paddleHeight,
    required this.type,
    this.velocity = 0.0,
  }) : _lastY = y;
  
  /// Atualiza a posição da raquete e calcula a velocidade
  /// 
  /// [newY] - Nova posição Y da raquete
  /// [screenHeight] - Altura da tela para limitar o movimento
  void updatePosition(double newY, double screenHeight) {
    _lastY = y;
    y = _clampPosition(newY, screenHeight);
    velocity = y - _lastY;
  }
  
  /// Move a raquete por um delta especificado
  /// 
  /// [deltaY] - Quantidade a mover no eixo Y
  /// [screenHeight] - Altura da tela para limitar o movimento
  void move(double deltaY, double screenHeight) {
    updatePosition(y + deltaY, screenHeight);
  }
  
  /// Limita a posição da raquete dentro dos limites da tela
  /// 
  /// [newY] - Nova posição Y desejada
  /// [screenHeight] - Altura da tela
  /// Returns a posição Y limitada
  double _clampPosition(double newY, double screenHeight) {
    final halfHeight = screenHeight / 2;
    final paddleHalfHeight = height / 2;
    
    return newY.clamp(
      -halfHeight + paddleHalfHeight,
      halfHeight - paddleHalfHeight,
    );
  }
  
  /// Verifica se a bola colidiu com esta raquete
  /// 
  /// [ballX] - Posição X da bola
  /// [ballY] - Posição Y da bola
  /// [ballSize] - Tamanho da bola
  /// Returns true se houve colisão
  bool checkCollision(double ballX, double ballY, double ballSize) {
    // Verifica colisão no eixo X
    final ballLeft = ballX - ballSize;
    final ballRight = ballX + ballSize;
    final paddleLeft = x - width / 2;
    final paddleRight = x + width / 2;
    
    final xCollision = ballLeft <= paddleRight && ballRight >= paddleLeft;
    
    // Verifica colisão no eixo Y
    final ballTop = ballY - ballSize;
    final ballBottom = ballY + ballSize;
    final paddleTop = y - height / 2;
    final paddleBottom = y + height / 2;
    
    final yCollision = ballTop <= paddleBottom && ballBottom >= paddleTop;
    
    return xCollision && yCollision;
  }
  
  /// Calcula a posição relativa de impacto na raquete
  /// 
  /// [ballY] - Posição Y da bola
  /// Returns valor entre -1.0 (topo) e 1.0 (base)
  double getRelativeImpactPosition(double ballY) {
    return (ballY - y) / (height / 2);
  }
  
  /// Obtém a zona de impacto na raquete
  /// 
  /// [ballY] - Posição Y da bola
  /// Returns a zona de impacto
  PaddleZone getImpactZone(double ballY) {
    final relativeY = getRelativeImpactPosition(ballY);
    
    if (relativeY.abs() <= 0.3) {
      return PaddleZone.center;
    } else if (relativeY.abs() <= 0.7) {
      return PaddleZone.edge;
    } else {
      return PaddleZone.corner;
    }
  }
  
  /// Verifica se a raquete está se movendo para cima
  bool get isMovingUp => velocity < 0;
  
  /// Verifica se a raquete está se movendo para baixo
  bool get isMovingDown => velocity > 0;
  
  /// Verifica se a raquete está parada
  bool get isStationary => velocity.abs() < 0.1;
  
  /// Obtém a posição do topo da raquete
  double get top => y - height / 2;
  
  /// Obtém a posição da base da raquete
  double get bottom => y + height / 2;
  
  /// Obtém a posição da esquerda da raquete
  double get left => x - width / 2;
  
  /// Obtém a posição da direita da raquete
  double get right => x + width / 2;
  
  /// Obtém o centro da raquete no eixo X
  double get centerX => x;
  
  /// Obtém o centro da raquete no eixo Y
  double get centerY => y;
  
  /// Reseta a raquete para a posição central
  void reset() {
    y = 0.0;
    velocity = 0.0;
    _lastY = 0.0;
  }
  
  /// Cria uma cópia da raquete
  Paddle copy() {
    return Paddle(
      y: y,
      x: x,
      width: width,
      height: height,
      type: type,
      velocity: velocity,
    );
  }
  
  @override
  String toString() {
    return 'Paddle(type: $type, x: ${x.toStringAsFixed(2)}, '
           'y: ${y.toStringAsFixed(2)}, velocity: ${velocity.toStringAsFixed(2)})';
  }
}

/// Zonas de impacto na raquete para diferentes efeitos
enum PaddleZone {
  /// Centro da raquete - rebatimento normal
  center,
  
  /// Bordas da raquete - ângulos mais extremos
  edge,
  
  /// Cantos da raquete - efeitos especiais
  corner
}

/// Extensão para facilitar o uso das zonas de impacto
extension PaddleZoneExtension on PaddleZone {
  /// Fator de efeito no ângulo de rebatimento
  double get angleEffect {
    switch (this) {
      case PaddleZone.center:
        return 1.0;
      case PaddleZone.edge:
        return 1.5;
      case PaddleZone.corner:
        return 2.0;
    }
  }
  
  /// Aumento de velocidade baseado na zona
  double get speedBoost {
    switch (this) {
      case PaddleZone.center:
        return 1.0;
      case PaddleZone.edge:
        return 1.02;
      case PaddleZone.corner:
        return 1.05;
    }
  }
}
