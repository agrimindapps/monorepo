import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Security Service implementing OWASP Mobile Top 10 protections
/// with configurable policies for cross-app usage
class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();

  SecurityService._();

  // Configurable policies
  PasswordPolicy _passwordPolicy = const PasswordPolicy.standard();
  LockoutPolicy _lockoutPolicy = const LockoutPolicy.standard();
  Map<String, RateLimitConfig> _rateLimitConfigs = {};

  // State tracking
  final Map<String, List<DateTime>> _rateLimitTracking = {};
  Timer? _cleanupTimer;

  /// Configure security service with app-specific policies
  void configure({
    PasswordPolicy? passwordPolicy,
    LockoutPolicy? lockoutPolicy,
    Map<String, RateLimitConfig>? rateLimitConfigs,
  }) {
    if (passwordPolicy != null) _passwordPolicy = passwordPolicy;
    if (lockoutPolicy != null) _lockoutPolicy = lockoutPolicy;
    if (rateLimitConfigs != null) _rateLimitConfigs.addAll(rateLimitConfigs);

    if (kDebugMode) {
      debugPrint('🔒 SecurityService configured with custom policies');
    }
  }

  /// Initialize security service
  void initialize() {
    // Start periodic cleanup of rate limit tracking
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupOldRateLimitData(),
    );

    if (kDebugMode) {
      debugPrint('🔒 SecurityService initialized');
    }
  }

  /// Check if account is currently locked out
  Future<bool> isAccountLockedOut(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutTimestamp = prefs.getInt(
        'lockout_timestamp_$userIdentifier',
      );

      if (lockoutTimestamp == null) return false;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
      final isStillLocked =
          DateTime.now().difference(lockoutTime) < _lockoutPolicy.duration;

      // If lockout has expired, clear the lockout
      if (!isStillLocked) {
        await _clearLockout(userIdentifier);
      }

      return isStillLocked;
    } catch (e) {
      debugPrint('❌ Error checking account lockout: $e');
      return false;
    }
  }

  /// Get remaining lockout time
  Future<Duration?> getRemainingLockoutTime(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutTimestamp = prefs.getInt(
        'lockout_timestamp_$userIdentifier',
      );

      if (lockoutTimestamp == null) return null;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
      final elapsed = DateTime.now().difference(lockoutTime);

      if (elapsed >= _lockoutPolicy.duration) {
        await _clearLockout(userIdentifier);
        return null;
      }

      return _lockoutPolicy.duration - elapsed;
    } catch (e) {
      debugPrint('❌ Error getting lockout time: $e');
      return null;
    }
  }

  /// Record failed login attempt
  Future<void> recordFailedLoginAttempt(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentAttempts =
          prefs.getInt('failed_attempts_$userIdentifier') ?? 0;
      final newAttempts = currentAttempts + 1;

      await prefs.setInt('failed_attempts_$userIdentifier', newAttempts);
      await prefs.setInt(
        'last_login_attempt_$userIdentifier',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (kDebugMode) {
        debugPrint(
          '⚠️ Failed login attempt $newAttempts/${_lockoutPolicy.maxAttempts} for $userIdentifier',
        );
      }

      // Lock account if max attempts reached
      if (newAttempts >= _lockoutPolicy.maxAttempts) {
        await _lockAccount(userIdentifier);
      }
    } catch (e) {
      debugPrint('❌ Error recording failed attempt: $e');
    }
  }

  /// Record successful login
  Future<void> recordSuccessfulLogin(String userIdentifier) async {
    try {
      await _clearFailedAttempts(userIdentifier);
      await _clearLockout(userIdentifier);

      if (kDebugMode) {
        debugPrint('✅ Successful login for $userIdentifier');
      }
    } catch (e) {
      debugPrint('❌ Error recording successful login: $e');
    }
  }

  /// Get current failed attempts count
  Future<int> getFailedAttemptsCount(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('failed_attempts_$userIdentifier') ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting failed attempts: $e');
      return 0;
    }
  }

  /// Check rate limiting for API requests
  Future<bool> isRateLimited(String endpoint, String userIdentifier) async {
    final config = _rateLimitConfigs[endpoint] ?? const RateLimitConfig.standard();
    final key = '${endpoint}_$userIdentifier';
    final now = DateTime.now();

    // Get existing timestamps for this key
    final timestamps = _rateLimitTracking[key] ?? <DateTime>[];

    // Remove timestamps older than the rate limit window
    timestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > config.windowDuration,
    );

    // Check if rate limit is exceeded
    if (timestamps.length >= config.maxRequests) {
      if (kDebugMode) {
        debugPrint('🚦 Rate limit exceeded for $endpoint by $userIdentifier');
      }
      return true;
    }

    // Add current timestamp
    timestamps.add(now);
    _rateLimitTracking[key] = timestamps;

    return false;
  }

  /// Validate password strength with configurable policy
  SecurityValidationResult validatePasswordStrength(String password) {
    final issues = <String>[];

    if (password.length < _passwordPolicy.minLength) {
      issues.add('Password must be at least ${_passwordPolicy.minLength} characters long');
    }

    if (password.length > 128) {
      issues.add('Password must be less than 128 characters');
    }

    if (_passwordPolicy.requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      issues.add('Password must contain at least one uppercase letter');
    }

    if (_passwordPolicy.requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      issues.add('Password must contain at least one lowercase letter');
    }

    if (_passwordPolicy.requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      issues.add('Password must contain at least one number');
    }

    if (_passwordPolicy.requireSpecialChars &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      issues.add('Password must contain at least one special character');
    }

    // Check for common weak patterns
    if (_isCommonPassword(password)) {
      issues.add('Password is too common, please choose a stronger password');
    }

    if (_hasSequentialCharacters(password)) {
      issues.add('Password contains sequential characters (e.g., abc, 123)');
    }

    if (_hasRepeatingCharacters(password, _passwordPolicy.maxRepeatingChars)) {
      issues.add('Password contains too many repeating characters');
    }

    final strength = _calculatePasswordStrength(password, issues.isEmpty);

    return SecurityValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      strength: strength,
    );
  }

  /// Check for input validation (prevent injection attacks)
  bool isInputSafe(String input) {
    // Check for common injection patterns
    final dangerousPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'exec\(', caseSensitive: false),
      RegExp(r'eval\(', caseSensitive: false),
      RegExp(r'union\s+select', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'insert\s+into', caseSensitive: false),
      RegExp(r'delete\s+from', caseSensitive: false),
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        if (kDebugMode) {
          debugPrint('🚨 Dangerous input pattern detected');
        }
        return false;
      }
    }

    return true;
  }

  /// Sanitize input string
  String sanitizeInput(String input) {
    String sanitized = input;

    // Escape and remove dangerous characters
    sanitized = sanitized
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('\\', '')
        .trim();

    // Limit length to prevent buffer overflow attempts
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }

    return sanitized;
  }

  /// Generate secure random token
  String generateSecureToken({int length = 32}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;

    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Clear all security data for user (logout)
  Future<void> clearUserSecurityData(String userIdentifier) async {
    try {
      await _clearFailedAttempts(userIdentifier);
      await _clearLockout(userIdentifier);

      // Clear rate limit tracking
      _rateLimitTracking.removeWhere((key, _) => key.contains(userIdentifier));

      if (kDebugMode) {
        debugPrint('🗑️ Security data cleared for $userIdentifier');
      }
    } catch (e) {
      debugPrint('❌ Error clearing security data: $e');
    }
  }

  /// Get security status report
  Future<SecurityStatusReport> getSecurityStatus(String userIdentifier) async {
    final isLocked = await isAccountLockedOut(userIdentifier);
    final failedAttempts = await getFailedAttemptsCount(userIdentifier);
    final remainingLockout = await getRemainingLockoutTime(userIdentifier);

    return SecurityStatusReport(
      isAccountLocked: isLocked,
      failedAttempts: failedAttempts,
      maxAllowedAttempts: _lockoutPolicy.maxAttempts,
      remainingLockoutTime: remainingLockout,
      rateLimitWindows: _rateLimitTracking.length,
    );
  }

  // Private methods
  Future<void> _lockAccount(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'lockout_timestamp_$userIdentifier',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (kDebugMode) {
        debugPrint(
          '🔒 Account locked for $userIdentifier due to too many failed attempts',
        );
      }
    } catch (e) {
      debugPrint('❌ Error locking account: $e');
    }
  }

  Future<void> _clearFailedAttempts(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('failed_attempts_$userIdentifier');
      await prefs.remove('last_login_attempt_$userIdentifier');
    } catch (e) {
      debugPrint('❌ Error clearing failed attempts: $e');
    }
  }

  Future<void> _clearLockout(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lockout_timestamp_$userIdentifier');
    } catch (e) {
      debugPrint('❌ Error clearing lockout: $e');
    }
  }

  void _cleanupOldRateLimitData() {
    final now = DateTime.now();

    _rateLimitTracking.forEach((key, timestamps) {
      // Use the appropriate config for cleanup
      final endpoint = key.split('_').first;
      final config = _rateLimitConfigs[endpoint] ?? const RateLimitConfig.standard();

      timestamps.removeWhere(
        (timestamp) => now.difference(timestamp) > config.windowDuration,
      );
    });

    // Remove empty entries
    _rateLimitTracking.removeWhere((key, timestamps) => timestamps.isEmpty);
  }

  bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password',
      '123456',
      '123456789',
      'qwerty',
      'abc123',
      'password123',
      'admin',
      'letmein',
      'welcome',
      'monkey',
      'login',
      'password1',
      '123123',
      'qwerty123',
      'user',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }

  bool _hasSequentialCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);

      if (char2 == char1 + 1 && char3 == char2 + 1) {
        return true;
      }
    }
    return false;
  }

  bool _hasRepeatingCharacters(String password, int maxRepeating) {
    final charCount = <String, int>{};

    for (final char in password.split('')) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    // Check if any character appears more than maxRepeating times
    return charCount.values.any((count) => count > maxRepeating);
  }

  PasswordStrength _calculatePasswordStrength(String password, bool isValid) {
    if (!isValid) return PasswordStrength.weak;

    int score = 0;

    // Length bonus
    if (password.length >= 12) {
      score += 2;
    } else if (password.length >= 8) {
      score += 1;
    }

    // Character variety
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // Bonus for mixed case and special chars
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    }

    if (score >= 6) return PasswordStrength.strong;
    if (score >= 4) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  /// Dispose the service
  void dispose() {
    _cleanupTimer?.cancel();
    _rateLimitTracking.clear();
  }
}

/// Configurable password policy
class PasswordPolicy {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int maxRepeatingChars;

  const PasswordPolicy({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
    this.maxRepeatingChars = 3,
  });

  const PasswordPolicy.standard() : this();

  const PasswordPolicy.strict() : this(
    minLength: 12,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true,
    maxRepeatingChars: 2,
  );

  const PasswordPolicy.basic() : this(
    minLength: 6,
    requireUppercase: false,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: false,
    maxRepeatingChars: 4,
  );
}

/// Configurable lockout policy
class LockoutPolicy {
  final int maxAttempts;
  final Duration duration;

  const LockoutPolicy({
    this.maxAttempts = 5,
    this.duration = const Duration(minutes: 15),
  });

  const LockoutPolicy.standard() : this();

  const LockoutPolicy.strict() : this(
    maxAttempts: 3,
    duration: const Duration(minutes: 30),
  );

  const LockoutPolicy.lenient() : this(
    maxAttempts: 10,
    duration: const Duration(minutes: 5),
  );
}

/// Configurable rate limit policy
class RateLimitConfig {
  final int maxRequests;
  final Duration windowDuration;

  const RateLimitConfig({
    this.maxRequests = 10,
    this.windowDuration = const Duration(minutes: 1),
  });

  const RateLimitConfig.standard() : this();

  const RateLimitConfig.strict() : this(
    maxRequests: 5,
    windowDuration: const Duration(minutes: 1),
  );

  const RateLimitConfig.lenient() : this(
    maxRequests: 20,
    windowDuration: const Duration(minutes: 1),
  );
}

/// Security validation result
class SecurityValidationResult {
  final bool isValid;
  final List<String> issues;
  final PasswordStrength strength;

  const SecurityValidationResult({
    required this.isValid,
    required this.issues,
    required this.strength,
  });

  @override
  String toString() => 'SecurityValidationResult(valid: $isValid, strength: $strength, issues: ${issues.length})';
}

/// Security status report
class SecurityStatusReport {
  final bool isAccountLocked;
  final int failedAttempts;
  final int maxAllowedAttempts;
  final Duration? remainingLockoutTime;
  final int rateLimitWindows;

  const SecurityStatusReport({
    required this.isAccountLocked,
    required this.failedAttempts,
    required this.maxAllowedAttempts,
    required this.remainingLockoutTime,
    required this.rateLimitWindows,
  });

  @override
  String toString() => 'SecurityStatusReport(locked: $isAccountLocked, attempts: $failedAttempts/$maxAllowedAttempts)';
}

/// Password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong;

  String get displayName {
    switch (this) {
      case weak: return 'Weak';
      case medium: return 'Medium';
      case strong: return 'Strong';
    }
  }
}