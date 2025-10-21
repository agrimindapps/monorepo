// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/services/object_pool.dart';

class Obstacle implements Poolable {
  // Posição
  double x;
  late double topHeight;

  // Definições
  final double width;
  final double screenHeight;
  final double gapSize;
  bool isPassed = false;
  
  // Poolable interface
  bool _isInUse = false;

  Obstacle({
    required this.x,
    required this.screenHeight,
    required this.gapSize,
    this.width = GameSizes.obstacleWidth,
  }) {
    // Define aleatoriamente a altura do obstáculo superior
    // Garantindo que o espaço seja adequado para passagem
    final random = Random();
    final minTopHeight = screenHeight * Layout.minObstacleTopHeightRatio;
    final maxTopHeight = screenHeight * (1 - gapSize) - minTopHeight;
    topHeight =
        minTopHeight + random.nextDouble() * (maxTopHeight - minTopHeight);
  }

  // Atualiza a posição do obstáculo
  void update(double speed) {
    updateWithDeltaTime(speed, Physics.defaultDeltaTime); // Default 60fps for backwards compatibility
  }

  void updateWithDeltaTime(double speed, double deltaTime) {
    // Frame-rate independent movement using delta time
    final frameMultiplier = deltaTime / Physics.frameRateBase;
    x -= speed * frameMultiplier;
  }

  // Verifica se o obstáculo está fora da tela
  bool isOffScreen() {
    return x + width < 0;
  }

  // Altura do obstáculo inferior
  double get bottomHeight {
    return screenHeight - topHeight - (screenHeight * gapSize);
  }

  // Verifica se o pássaro colide com este obstáculo
  bool checkCollision(double birdX, double birdY, double birdSize) {
    // Tamanho ajustado para tornar a colisão mais precisa
    final adjustedSize = birdSize * Layout.collisionSizeAdjustment;

    // Verifica colisão com o obstáculo superior
    if (birdX + adjustedSize / 2 > x && birdX - adjustedSize / 2 < x + width) {
      if (birdY - adjustedSize / 2 < topHeight) {
        return true;
      }
    }

    // Verifica colisão com o obstáculo inferior
    if (birdX + adjustedSize / 2 > x && birdX - adjustedSize / 2 < x + width) {
      if (birdY + adjustedSize / 2 > screenHeight - bottomHeight) {
        return true;
      }
    }

    return false;
  }

  // Verifica se o pássaro passou pelo obstáculo
  bool checkPassed(double birdX) {
    if (!isPassed && birdX > x + width) {
      isPassed = true;
      return true;
    }
    return false;
  }

  // Poolable interface implementation
  @override
  bool get isInUse => _isInUse;

  @override
  void setInUse(bool inUse) {
    _isInUse = inUse;
  }

  @override
  void reset() {
    isPassed = false;
    _isInUse = false;
  }

  // Factory method for object pool
  void configure({
    required double x,
    required double screenHeight,
    required double gapSize,
  }) {
    this.x = x;
    final random = Random();
    final minTopHeight = screenHeight * Layout.minObstacleTopHeightRatio;
    final maxTopHeight = screenHeight * (1 - gapSize) - minTopHeight;
    topHeight = minTopHeight + random.nextDouble() * (maxTopHeight - minTopHeight);
    isPassed = false;
  }
}
