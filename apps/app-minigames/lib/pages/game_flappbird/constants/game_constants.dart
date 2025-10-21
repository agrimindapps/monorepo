/// Game constants organized by category to avoid magic numbers
class GameConstants {
  // Private constructor to prevent instantiation
  GameConstants._();
}

/// Physics-related constants
class Physics {
  Physics._();
  
  /// Bird gravity acceleration (pixels per frame²)
  static const double gravity = 0.6;
  
  /// Bird jump strength (negative value for upward force)
  static const double jumpStrength = -10.0;
  
  /// Frame rate multiplier base (1/60 second for 60fps)
  static const double frameRateBase = 0.016667;
  
  /// Default delta time fallback for 60fps
  static const double defaultDeltaTime = 0.016;
  
  /// Maximum delta time to prevent large jumps (30fps minimum)
  static const double maxDeltaTime = 0.033;
}

/// Timing-related constants
class Timing {
  Timing._();
  
  /// Game loop timer interval in milliseconds (60fps)
  static const int gameLoopInterval = 16;
  
  /// Animation duration for wing flapping in milliseconds
  static const int flapAnimationDuration = 300;
  
  /// Overlay fade transition duration in milliseconds
  static const int overlayTransitionDuration = 500;
  
  /// Container animation duration in milliseconds
  static const int containerAnimationDuration = 300;
  
  /// Score bounce animation duration in milliseconds
  static const int scoreBounceAnimationDuration = 800;
}

/// Layout and size constants
class Layout {
  Layout._();
  
  /// Ground height as percentage of screen height
  static const double groundHeightRatio = 0.15;
  
  /// Bird position as percentage of screen width
  static const double birdXPositionRatio = 0.25;
  
  /// Bird initial position as percentage of screen height
  static const double birdYPositionRatio = 0.5;
  
  /// Minimum obstacle top height as percentage of screen height
  static const double minObstacleTopHeightRatio = 0.1;
  
  /// Bird size adjustment for collision detection
  static const double collisionSizeAdjustment = 0.7;
  
  /// Bird eye size as percentage of bird size
  static const double birdEyeOuterSizeRatio = 0.4;
  
  /// Bird pupil size as percentage of bird size
  static const double birdPupilSizeRatio = 0.2;
}

/// Animation curve and interpolation constants
class Animation {
  Animation._();
  
  /// Bird rotation multiplier based on velocity
  static const double birdRotationMultiplier = 0.04;
  
  /// Alternative bird rotation multiplier for rendering
  static const double birdRenderRotationMultiplier = 0.05;
  
  /// Wing flap animation range (maximum compression)
  static const double flapAnimationRange = 0.2;
  
  /// Wing flap visual effect scale
  static const double flapVisualScale = 5.0;
  
  /// Slide animation offset for overlay entrance
  static const double slideAnimationOffset = 0.3;
}

/// Spacing and positioning constants
class Spacing {
  Spacing._();
  
  /// Default obstacle spacing in pixels
  static const double obstacleSpacing = 300.0;
  
  /// Additional spacing when creating new obstacles
  static const double newObstacleOffset = 50.0;
  
  /// Distance from edge to trigger new obstacle creation
  static const double obstacleCreationDistance = 50.0;
  
  /// Initial obstacle spawn distance from screen edge
  static const double initialObstacleDistance = 100.0;
}

/// Parallax effect constants
class Parallax {
  Parallax._();
  
  /// Cloud movement speed multiplier
  static const double cloudSpeed = 0.002;
  
  /// Bush movement speed multiplier
  static const double bushSpeed = 0.005;
  
  /// Cloud position multiplier for varied heights
  static const double cloudHeightVariation = 15.0;
  
  /// Base cloud Y position offset
  static const double cloudBaseHeight = 20.0;
  
  /// Cloud height variation modulo
  static const double cloudHeightModulo = 40.0;
  
  /// Bush Y position offset from ground
  static const double bushGroundOffset = 10.0;
  
  /// Parallax element off-screen threshold
  static const double parallaxOffScreenThreshold = -0.3;
  
  /// Cloud respawn X position
  static const double cloudRespawnX = 2.0;
  
  /// Bush respawn X position
  static const double bushRespawnX = 2.1;
}

/// Visual effects constants
class VisualEffects {
  VisualEffects._();
  
  /// Shadow blur radius for bird
  static const double birdShadowBlur = 4.0;
  
  /// Shadow offset for bird
  static const double birdShadowOffsetX = 0.0;
  static const double birdShadowOffsetY = 2.0;
  
  /// Shadow blur radius for text
  static const double textShadowBlur = 4.0;
  
  /// Shadow offset for text
  static const double textShadowOffsetX = 1.0;
  static const double textShadowOffsetY = 1.0;
  
  /// Overlay background alpha transparency
  static const double overlayBackgroundAlpha = 0.3;
  
  /// Ground border height in pixels
  static const double groundBorderHeight = 5.0;
}

/// Predefined position arrays for parallax elements
class ParallaxPositions {
  ParallaxPositions._();
  
  /// Cloud spawn positions (normalized screen widths)
  static const List<double> cloudPositions = [0.0, 0.5, 1.0, 1.5, 2.0];
  
  /// Bush spawn positions (normalized screen widths)
  static const List<double> bushPositions = [0.0, 0.7, 1.4, 2.1];
}