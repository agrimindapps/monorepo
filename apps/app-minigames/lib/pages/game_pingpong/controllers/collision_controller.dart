/// Controlador de colisões para o jogo Ping Pong
/// 
/// Gerencia toda a lógica de detecção de colisões entre a bola,
/// raquetes, paredes e limites da tela.
library;

// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/models/ball.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';

/// Resultado de uma verificação de pontuação
enum ScoreResult {
  playerScored,
  aiScored,
  noScore
}

/// Controlador responsável pela detecção e tratamento de colisões
class CollisionController {
  /// Estado do jogo
  PingPongGameState? _gameState;
  
  /// Histórico de colisões para evitar detecções duplicadas
  final List<CollisionInfo> _collisionHistory = [];
  
  /// Número máximo de colisões no histórico
  static const int _maxCollisionHistory = 10;
  
  /// Inicializa o controlador de colisões
  void initialize(PingPongGameState gameState) {
    _gameState = gameState;
    _collisionHistory.clear();
  }
  
  /// Verifica colisão da bola com as paredes superior e inferior
  bool checkWallCollision(Ball ball, double screenHeight) {
    final halfHeight = screenHeight / 2;
    final collision = (ball.y <= -halfHeight + ball.size) || 
                     (ball.y >= halfHeight - ball.size);
    
    if (collision) {
      _addCollisionToHistory(CollisionType.wall, ball.x, ball.y);
    }
    
    return collision;
  }
  
  /// Verifica colisão da bola com uma raquete
  bool checkPaddleCollision(Ball ball, Paddle paddle) {
    // Verifica se já houve colisão recente com esta raquete
    if (_hasRecentCollision(CollisionType.paddle, paddle.x)) {
      return false;
    }
    
    // Detecção de colisão básica
    final basicCollision = _checkBasicPaddleCollision(ball, paddle);
    if (!basicCollision) return false;
    
    // Detecção de colisão avançada para maior precisão
    final advancedCollision = _checkAdvancedPaddleCollision(ball, paddle);
    
    if (advancedCollision) {
      _addCollisionToHistory(CollisionType.paddle, paddle.x, paddle.y);
      return true;
    }
    
    return false;
  }
  
  /// Verifica colisão básica entre bola e raquete
  bool _checkBasicPaddleCollision(Ball ball, Paddle paddle) {
    // Colisão no eixo X
    final ballLeft = ball.x - ball.size;
    final ballRight = ball.x + ball.size;
    final paddleLeft = paddle.left;
    final paddleRight = paddle.right;
    
    final xCollision = ballLeft <= paddleRight && ballRight >= paddleLeft;
    
    // Colisão no eixo Y
    final ballTop = ball.y - ball.size;
    final ballBottom = ball.y + ball.size;
    final paddleTop = paddle.top;
    final paddleBottom = paddle.bottom;
    
    final yCollision = ballTop <= paddleBottom && ballBottom >= paddleTop;
    
    return xCollision && yCollision;
  }
  
  /// Verifica colisão avançada considerando direção da bola
  bool _checkAdvancedPaddleCollision(Ball ball, Paddle paddle) {
    // Verifica se a bola está se movendo em direção à raquete
    final movingTowardsPaddle = (paddle.type == PaddleType.player && ball.isMovingLeft) ||
                               (paddle.type == PaddleType.ai && ball.isMovingRight);
    
    if (!movingTowardsPaddle) return false;
    
    // Calcula a posição onde a bola estava no frame anterior
    final prevBallX = ball.x - ball.speedX;
    final prevBallY = ball.y - ball.speedY;
    
    // Verifica se a bola cruzou a raquete neste frame
    final crossedPaddle = _checkLinePaddleIntersection(
      prevBallX, prevBallY, ball.x, ball.y, paddle);
    
    return crossedPaddle;
  }
  
  /// Verifica se a linha da trajetória da bola intersecta com a raquete
  bool _checkLinePaddleIntersection(double x1, double y1, double x2, double y2, Paddle paddle) {
    // Pontos da raquete
    final paddleLeft = paddle.left;
    final paddleRight = paddle.right;
    final paddleTop = paddle.top;
    final paddleBottom = paddle.bottom;
    
    // Verifica intersecção com cada lado da raquete
    return _lineIntersectsRect(x1, y1, x2, y2, paddleLeft, paddleTop, paddleRight, paddleBottom);
  }
  
  /// Verifica se uma linha intersecta um retângulo
  bool _lineIntersectsRect(double x1, double y1, double x2, double y2, 
                          double rectLeft, double rectTop, double rectRight, double rectBottom) {
    // Verifica se algum ponto da linha está dentro do retângulo
    if (_pointInRect(x1, y1, rectLeft, rectTop, rectRight, rectBottom) ||
        _pointInRect(x2, y2, rectLeft, rectTop, rectRight, rectBottom)) {
      return true;
    }
    
    // Verifica intersecção com cada lado do retângulo
    return _lineIntersectsLine(x1, y1, x2, y2, rectLeft, rectTop, rectRight, rectTop) ||    // Top
           _lineIntersectsLine(x1, y1, x2, y2, rectRight, rectTop, rectRight, rectBottom) || // Right
           _lineIntersectsLine(x1, y1, x2, y2, rectRight, rectBottom, rectLeft, rectBottom) || // Bottom
           _lineIntersectsLine(x1, y1, x2, y2, rectLeft, rectBottom, rectLeft, rectTop);     // Left
  }
  
  /// Verifica se um ponto está dentro de um retângulo
  bool _pointInRect(double x, double y, double rectLeft, double rectTop, double rectRight, double rectBottom) {
    return x >= rectLeft && x <= rectRight && y >= rectTop && y <= rectBottom;
  }
  
  /// Verifica se duas linhas se intersectam
  bool _lineIntersectsLine(double x1, double y1, double x2, double y2,
                          double x3, double y3, double x4, double y4) {
    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom == 0) return false; // Linhas paralelas
    
    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;
    
    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }
  
  /// Verifica se a bola saiu pelas laterais (pontuação)
  ScoreResult? checkScoreCollision(Ball ball, double screenWidth) {
    final halfWidth = screenWidth / 2;
    
    if (ball.x < -halfWidth - ball.size) {
      // Bola saiu pela esquerda - IA marcou
      return ScoreResult.aiScored;
    } else if (ball.x > halfWidth + ball.size) {
      // Bola saiu pela direita - Jogador marcou
      return ScoreResult.playerScored;
    }
    
    return null;
  }
  
  /// Calcula o ponto exato de colisão entre bola e raquete
  CollisionPoint calculateCollisionPoint(Ball ball, Paddle paddle) {
    // Calcula o ponto central da colisão
    final collisionX = paddle.type == PaddleType.player ? paddle.right : paddle.left;
    final collisionY = ball.y;
    
    // Calcula a normal da superfície no ponto de colisão
    final normalX = paddle.type == PaddleType.player ? 1.0 : -1.0;
    const normalY = 0.0;
    
    // Calcula o fator de impacto baseado na posição relativa
    final relativeY = paddle.getRelativeImpactPosition(ball.y);
    
    // Calcula a zona de impacto
    final impactZone = paddle.getImpactZone(ball.y);
    
    return CollisionPoint(
      x: collisionX,
      y: collisionY,
      normalX: normalX,
      normalY: normalY,
      relativeImpact: relativeY,
      impactZone: impactZone,
      paddleVelocity: paddle.velocity,
    );
  }
  
  /// Aplica efeitos físicos da colisão
  void applyCollisionEffects(Ball ball, CollisionPoint collision) {
    // Aplica reflexão baseada na normal
    ball.speedX = -ball.speedX * collision.normalX;
    
    // Aplica efeito do ângulo baseado na posição de impacto
    final angleEffect = collision.relativeImpact * collision.impactZone.angleEffect;
    ball.speedY += angleEffect;
    
    // Aplica efeito da velocidade da raquete
    ball.speedY += collision.paddleVelocity * 0.1;
    
    // Aplica boost de velocidade baseado na zona de impacto
    ball.speedX *= collision.impactZone.speedBoost;
    ball.speedY *= collision.impactZone.speedBoost;
    
    // Adiciona variação aleatória mínima para evitar loops
    final random = Random();
    ball.speedY += (random.nextDouble() - 0.5) * 0.5;
  }
  
  /// Verifica se houve colisão recente no histórico
  bool _hasRecentCollision(CollisionType type, double x) {
    final now = DateTime.now();
    const cooldownMs = 50; // 50ms de cooldown
    
    for (final collision in _collisionHistory) {
      if (collision.type == type && 
          (collision.x - x).abs() < 20 &&
          now.difference(collision.timestamp).inMilliseconds < cooldownMs) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Adiciona uma colisão ao histórico
  void _addCollisionToHistory(CollisionType type, double x, double y) {
    _collisionHistory.add(CollisionInfo(
      type: type,
      x: x,
      y: y,
      timestamp: DateTime.now(),
    ));
    
    // Limita o tamanho do histórico
    if (_collisionHistory.length > _maxCollisionHistory) {
      _collisionHistory.removeAt(0);
    }
  }
  
  /// Limpa o histórico de colisões
  void clearCollisionHistory() {
    _collisionHistory.clear();
  }
  
  /// Obtém estatísticas de colisões
  Map<String, dynamic> getCollisionStatistics() {
    final wallCollisions = _collisionHistory.where((c) => c.type == CollisionType.wall).length;
    final paddleCollisions = _collisionHistory.where((c) => c.type == CollisionType.paddle).length;
    
    return {
      'totalCollisions': _collisionHistory.length,
      'wallCollisions': wallCollisions,
      'paddleCollisions': paddleCollisions,
      'recentCollisions': _collisionHistory.length,
    };
  }
  
  /// Libera recursos
  void dispose() {
    _gameState = null;
    _collisionHistory.clear();
  }
}

/// Tipos de colisão
enum CollisionType {
  wall,
  paddle,
  score
}

/// Informações sobre uma colisão
class CollisionInfo {
  final CollisionType type;
  final double x;
  final double y;
  final DateTime timestamp;
  
  CollisionInfo({
    required this.type,
    required this.x,
    required this.y,
    required this.timestamp,
  });
}

/// Ponto de colisão detalhado
class CollisionPoint {
  final double x;
  final double y;
  final double normalX;
  final double normalY;
  final double relativeImpact;
  final PaddleZone impactZone;
  final double paddleVelocity;
  
  CollisionPoint({
    required this.x,
    required this.y,
    required this.normalX,
    required this.normalY,
    required this.relativeImpact,
    required this.impactZone,
    required this.paddleVelocity,
  });
}
