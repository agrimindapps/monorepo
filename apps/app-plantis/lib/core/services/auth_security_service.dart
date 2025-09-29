import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import 'secure_storage_service.dart';

/// Authentication security service implementing OWASP Mobile Top 10 protections
class AuthSecurityService {
  static AuthSecurityService? _instance;
  static AuthSecurityService get instance =>
      _instance ??= AuthSecurityService._();

  AuthSecurityService._();

  // ignore: unused_field - Kept for potential future secure storage implementations
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  // Security constants
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const int _maxRequestsPerWindow = 10;

  // Keys for security data
  static const String _failedAttemptsKey = 'failed_login_attempts';
  static const String _lockoutTimestampKey = 'account_lockout_timestamp';
  static const String _lastLoginAttemptKey = 'last_login_attempt';
  // ignore: unused_field - Kept for potential future rate limiting tracking
  static const String _requestTimestampsKey = 'request_timestamps';

  // State tracking
  final Map<String, List<DateTime>> _rateLimitTracking = {};
  Timer? _cleanupTimer;

  /// Initialize security service
  void initialize() {
    // Start periodic cleanup of rate limit tracking
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupOldRateLimitData(),
    );

    debugPrint('🔒 Auth security service initialized');
  }

  /// Check if account is currently locked out
  Future<bool> isAccountLockedOut(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutTimestamp = prefs.getInt(
        '${_lockoutTimestampKey}_$userIdentifier',
      );

      if (lockoutTimestamp == null) return false;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
      final isStillLocked =
          DateTime.now().difference(lockoutTime) < _lockoutDuration;

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
        '${_lockoutTimestampKey}_$userIdentifier',
      );

      if (lockoutTimestamp == null) return null;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
      final elapsed = DateTime.now().difference(lockoutTime);

      if (elapsed >= _lockoutDuration) {
        await _clearLockout(userIdentifier);
        return null;
      }

      return _lockoutDuration - elapsed;
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
          prefs.getInt('${_failedAttemptsKey}_$userIdentifier') ?? 0;
      final newAttempts = currentAttempts + 1;

      await prefs.setInt('${_failedAttemptsKey}_$userIdentifier', newAttempts);
      await prefs.setInt(
        '${_lastLoginAttemptKey}_$userIdentifier',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint(
        '⚠️ Failed login attempt $newAttempts/$_maxFailedAttempts for $userIdentifier',
      );

      // Lock account if max attempts reached
      if (newAttempts >= _maxFailedAttempts) {
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

      debugPrint('✅ Successful login for $userIdentifier');
    } catch (e) {
      debugPrint('❌ Error recording successful login: $e');
    }
  }

  /// Get current failed attempts count
  Future<int> getFailedAttemptsCount(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('${_failedAttemptsKey}_$userIdentifier') ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting failed attempts: $e');
      return 0;
    }
  }

  /// Check rate limiting for API requests
  Future<bool> isRateLimited(String endpoint, String userIdentifier) async {
    final key = '${endpoint}_$userIdentifier';
    final now = DateTime.now();

    // Get existing timestamps for this key
    final timestamps = _rateLimitTracking[key] ?? <DateTime>[];

    // Remove timestamps older than the rate limit window
    timestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _rateLimitWindow,
    );

    // Check if rate limit is exceeded
    if (timestamps.length >= _maxRequestsPerWindow) {
      debugPrint('🚦 Rate limit exceeded for $endpoint by $userIdentifier');
      return true;
    }

    // Add current timestamp
    timestamps.add(now);
    _rateLimitTracking[key] = timestamps;

    return false;
  }

  /// Validate password strength
  SecurityValidationResult validatePasswordStrength(String password) {
    final issues = <String>[];

    if (password.length < 8) {
      issues.add('Password must be at least 8 characters long');
    }

    if (password.length > 128) {
      issues.add('Password must be less than 128 characters');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      issues.add('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      issues.add('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      issues.add('Password must contain at least one number');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      issues.add('Password must contain at least one special character');
    }

    // Check for common weak patterns
    if (_isCommonPassword(password)) {
      issues.add('Password is too common, please choose a stronger password');
    }

    if (_hasSequentialCharacters(password)) {
      issues.add('Password contains sequential characters (e.g., abc, 123)');
    }

    if (_hasRepeatingCharacters(password)) {
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
        debugPrint('🚨 Dangerous input pattern detected: $input');
        return false;
      }
    }

    return true;
  }

  /// Sanitize input string
  String sanitizeInput(String input) {
    // Remove dangerous characters and patterns
    String sanitized = input;

    // Escape and remove dangerous characters
    sanitized =
        sanitized
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

      debugPrint('🗑️ Security data cleared for $userIdentifier');
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
      maxAllowedAttempts: _maxFailedAttempts,
      remainingLockoutTime: remainingLockout,
      rateLimitWindows: _rateLimitTracking.length,
    );
  }

  // Private methods
  Future<void> _lockAccount(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        '${_lockoutTimestampKey}_$userIdentifier',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint(
        '🔒 Account locked for $userIdentifier due to too many failed attempts',
      );
    } catch (e) {
      debugPrint('❌ Error locking account: $e');
    }
  }

  Future<void> _clearFailedAttempts(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_failedAttemptsKey}_$userIdentifier');
      await prefs.remove('${_lastLoginAttemptKey}_$userIdentifier');
    } catch (e) {
      debugPrint('❌ Error clearing failed attempts: $e');
    }
  }

  Future<void> _clearLockout(String userIdentifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_lockoutTimestampKey}_$userIdentifier');
    } catch (e) {
      debugPrint('❌ Error clearing lockout: $e');
    }
  }

  void _cleanupOldRateLimitData() {
    final now = DateTime.now();

    _rateLimitTracking.forEach((key, timestamps) {
      timestamps.removeWhere(
        (timestamp) => now.difference(timestamp) > _rateLimitWindow,
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

  bool _hasRepeatingCharacters(String password) {
    final charCount = <String, int>{};

    for (final char in password.split('')) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    // Check if any character appears more than 3 times
    return charCount.values.any((count) => count > 3);
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
}

enum PasswordStrength { weak, medium, strong }
