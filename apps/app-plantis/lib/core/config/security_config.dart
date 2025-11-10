import 'package:core/core.dart' hide Column;

/// Plantis-specific security configuration
/// Implements enhanced security policies for the plant care application
///
/// Note: This class uses static methods as a factory pattern for configuration.
/// It's a stateless configuration provider and doesn't require instantiation.
// ignore: avoid_classes_with_only_static_members
class PlantisSecurityConfig {
  static const int _maxLoginAttempts = 3;
  static const int _lockoutDurationMinutes = 15;
  static const int _rateLimitRequests = 5;
  static const int _rateLimitWindowMinutes = 1;

  /// Password policy for Plantis app
  static const PasswordPolicy passwordPolicy = PasswordPolicy(
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: false, // Less strict for plant care app
    maxRepeatingChars: 3,
  );

  /// Account lockout policy for Plantis app
  static const LockoutPolicy lockoutPolicy = LockoutPolicy(
    maxAttempts: _maxLoginAttempts,
    duration: Duration(minutes: _lockoutDurationMinutes),
  );

  /// Rate limiting configurations
  static final Map<String, RateLimitConfig> rateLimitConfigs = {
    'login': const RateLimitConfig(
      maxRequests: _rateLimitRequests,
      windowDuration: Duration(minutes: _rateLimitWindowMinutes),
    ),
    'register': const RateLimitConfig(
      maxRequests: 3, // Stricter for registration
      windowDuration: Duration(minutes: 5),
    ),
    'password_reset': const RateLimitConfig(
      maxRequests: 2,
      windowDuration: Duration(minutes: 10),
    ),
  };

  /// Creates a configured SecurityService instance for Plantis
  static SecurityService createSecurityService() {
    final service = SecurityService.instance;
    service.configure(
      passwordPolicy: passwordPolicy,
      lockoutPolicy: lockoutPolicy,
      rateLimitConfigs: rateLimitConfigs,
    );
    return service;
  }

  /// Creates an EnhancedFirebaseAuthService with Plantis security configuration
  static EnhancedFirebaseAuthService createEnhancedAuthService() {
    return EnhancedFirebaseAuthService(
      securityService: createSecurityService(),
    );
  }
}
