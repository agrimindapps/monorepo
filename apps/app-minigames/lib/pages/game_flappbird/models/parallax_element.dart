// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/services/object_pool.dart';

enum ParallaxType { cloud, bush }

class ParallaxElement implements Poolable {
  double x = 0;
  double y = 0;
  ParallaxType type = ParallaxType.cloud;
  bool _isInUse = false;

  ParallaxElement();

  void configure({
    required double x,
    required double y,
    required ParallaxType type,
  }) {
    this.x = x;
    this.y = y;
    this.type = type;
  }

  void update(double speed) {
    updateWithDeltaTime(speed, Physics.defaultDeltaTime); // Default 60fps for backwards compatibility
  }

  void updateWithDeltaTime(double speed, double deltaTime) {
    // Frame-rate independent movement using delta time
    final frameMultiplier = deltaTime / Physics.frameRateBase;
    x -= speed * frameMultiplier;
  }

  bool isOffScreen() {
    return x < Parallax.parallaxOffScreenThreshold;
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
    x = 0;
    y = 0;
    _isInUse = false;
  }
}
