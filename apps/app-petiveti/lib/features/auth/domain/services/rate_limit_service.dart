/// Service responsible for rate limiting authentication attempts
/// Follows Single Responsibility Principle - only handles rate limiting logic
class RateLimitService {
  DateTime? _lastLoginAttempt;
  DateTime? _lastRegisterAttempt;
  int _loginAttempts = 0;
  int _registerAttempts = 0;

  static const int maxAttempts = 5;
  static const Duration cooldownPeriod = Duration(minutes: 2);

  /// Checks if a login attempt is allowed
  bool canAttemptLogin() {
    if (_lastLoginAttempt == null) return true;

    final timeSinceLastAttempt = DateTime.now().difference(_lastLoginAttempt!);
    if (timeSinceLastAttempt > cooldownPeriod) {
      _loginAttempts = 0;
      return true;
    }

    return _loginAttempts < maxAttempts;
  }

  /// Checks if a register attempt is allowed
  bool canAttemptRegister() {
    if (_lastRegisterAttempt == null) return true;

    final timeSinceLastAttempt =
        DateTime.now().difference(_lastRegisterAttempt!);
    if (timeSinceLastAttempt > cooldownPeriod) {
      _registerAttempts = 0;
      return true;
    }

    return _registerAttempts < maxAttempts;
  }

  /// Records a login attempt
  void recordLoginAttempt() {
    _lastLoginAttempt = DateTime.now();
    _loginAttempts++;
  }

  /// Records a register attempt
  void recordRegisterAttempt() {
    _lastRegisterAttempt = DateTime.now();
    _registerAttempts++;
  }

  /// Resets login attempts counter
  void resetLoginAttempts() {
    _loginAttempts = 0;
    _lastLoginAttempt = null;
  }

  /// Resets register attempts counter
  void resetRegisterAttempts() {
    _registerAttempts = 0;
    _lastRegisterAttempt = null;
  }

  /// Gets rate limit message for login
  String getRateLimitMessageForLogin() {
    return _getRateLimitMessage(_lastLoginAttempt);
  }

  /// Gets rate limit message for register
  String getRateLimitMessageForRegister() {
    return _getRateLimitMessage(_lastRegisterAttempt);
  }

  String _getRateLimitMessage(DateTime? lastAttempt) {
    if (lastAttempt == null) {
      return 'Muitas tentativas. Aguarde antes de tentar novamente.';
    }

    final remainingTime = cooldownPeriod.inMinutes -
        DateTime.now().difference(lastAttempt).inMinutes;

    return 'Muitas tentativas. Aguarde ${remainingTime > 0 ? remainingTime : 1} minuto(s) antes de tentar novamente.';
  }

  /// Gets remaining login attempts
  int getRemainingLoginAttempts() {
    return maxAttempts - _loginAttempts;
  }

  /// Gets remaining register attempts
  int getRemainingRegisterAttempts() {
    return maxAttempts - _registerAttempts;
  }
}
