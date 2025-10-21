// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

class Bird {
  // Posição
  double x;
  double y;

  // Física
  double velocity = 0;
  final double gravity = Physics.gravity;
  final double jumpStrength = Physics.jumpStrength;
  final double size;

  // Controle de animação
  double rotation = 0;

  Bird({
    required this.x,
    required this.y,
    this.size = 50.0,
  });

  void update() {
    updateWithDeltaTime(Physics.defaultDeltaTime); // Default 60fps for backwards compatibility
  }

  void updateWithDeltaTime(double deltaTime) {
    // Frame-rate independent physics using delta time
    // Convert to 60fps equivalent for consistency
    final frameMultiplier = deltaTime / Physics.frameRateBase;

    // Aplica gravidade à velocidade
    velocity += gravity * frameMultiplier;

    // Atualiza a posição com base na velocidade
    y += velocity * frameMultiplier;

    // Atualiza a rotação com base na velocidade
    rotation = min(pi / 4, max(-pi / 2, velocity * Animation.birdRotationMultiplier));
  }

  void jump() {
    // Aplica impulso para cima
    velocity = jumpStrength;
  }

  // Verifica se o pássaro bateu no chão
  bool isCollidingWithGround(double groundY) {
    return y + size / 2 >= groundY;
  }

  // Verifica se o pássaro bateu no teto
  bool isCollidingWithCeiling() {
    return y - size / 2 <= 0;
  }

  // Reinicia o pássaro para a posição inicial
  void reset(double initialY) {
    y = initialY;
    velocity = 0;
    rotation = 0;
  }
}
