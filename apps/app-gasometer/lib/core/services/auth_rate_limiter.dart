import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Serviço para controlar rate limiting em tentativas de login
/// Protege contra ataques de força bruta implementando backoff exponencial
@LazySingleton()
class AuthRateLimiter {
  final FlutterSecureStorage _secureStorage;
  
  static const String _attemptCountKey = 'auth_attempt_count';
  static const String _lastAttemptTimeKey = 'auth_last_attempt_time';
  static const String _lockoutEndTimeKey = 'auth_lockout_end_time';
  
  // Configurações de rate limiting
  static const int _maxAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  static const int _attemptWindowMinutes = 10;
  
  AuthRateLimiter(this._secureStorage);
  
  /// Verifica se o usuário pode tentar fazer login
  /// Retorna true se pode tentar, false se está bloqueado
  Future<bool> canAttemptLogin() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Verifica se está em lockout
    final lockoutEndTimeStr = await _secureStorage.read(key: _lockoutEndTimeKey);
    if (lockoutEndTimeStr != null) {
      final lockoutEndTime = int.parse(lockoutEndTimeStr);
      if (now < lockoutEndTime) {
        return false; // Ainda está em lockout
      } else {
        // Lockout expirou, limpa os dados
        await _clearLockoutData();
      }
    }
    
    return true;
  }
  
  /// Retorna o tempo restante de lockout em minutos (0 se não está bloqueado)
  Future<int> getLockoutTimeRemainingMinutes() async {
    final lockoutEndTimeStr = await _secureStorage.read(key: _lockoutEndTimeKey);
    if (lockoutEndTimeStr == null) return 0;
    
    final lockoutEndTime = int.parse(lockoutEndTimeStr);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now >= lockoutEndTime) return 0;
    
    final remainingMs = lockoutEndTime - now;
    return (remainingMs / (1000 * 60)).ceil();
  }
  
  /// Registra uma tentativa de login falhada
  /// Implementa backoff exponencial e lockout após muitas tentativas
  Future<void> recordFailedAttempt() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Obtém contadores atuais
    final attemptCountStr = await _secureStorage.read(key: _attemptCountKey);
    final lastAttemptTimeStr = await _secureStorage.read(key: _lastAttemptTimeKey);
    
    int attemptCount = 0;
    int lastAttemptTime = 0;
    
    if (attemptCountStr != null && lastAttemptTimeStr != null) {
      attemptCount = int.parse(attemptCountStr);
      lastAttemptTime = int.parse(lastAttemptTimeStr);
      
      // Reset counter se a última tentativa foi há mais de 10 minutos
      final timeDiff = now - lastAttemptTime;
      if (timeDiff > _attemptWindowMinutes * 60 * 1000) {
        attemptCount = 0;
      }
    }
    
    attemptCount++;
    
    // Salva contadores atualizados
    await _secureStorage.write(key: _attemptCountKey, value: attemptCount.toString());
    await _secureStorage.write(key: _lastAttemptTimeKey, value: now.toString());
    
    // Se excedeu o limite, inicia lockout
    if (attemptCount >= _maxAttempts) {
      final lockoutEndTime = now + (_lockoutDurationMinutes * 60 * 1000);
      await _secureStorage.write(key: _lockoutEndTimeKey, value: lockoutEndTime.toString());
    }
  }
  
  /// Registra uma tentativa de login bem-sucedida
  /// Limpa todos os contadores de tentativas falhadas
  Future<void> recordSuccessfulAttempt() async {
    await _clearLockoutData();
  }
  
  /// Obtém informações sobre o estado atual do rate limiting
  Future<AuthRateLimitInfo> getRateLimitInfo() async {
    final canAttempt = await canAttemptLogin();
    final lockoutTimeRemaining = await getLockoutTimeRemainingMinutes();
    
    int attemptsRemaining = _maxAttempts;
    
    if (canAttempt && lockoutTimeRemaining == 0) {
      final attemptCountStr = await _secureStorage.read(key: _attemptCountKey);
      if (attemptCountStr != null) {
        final attemptCount = int.parse(attemptCountStr);
        attemptsRemaining = _maxAttempts - attemptCount;
        if (attemptsRemaining < 0) attemptsRemaining = 0;
      }
    } else {
      attemptsRemaining = 0;
    }
    
    return AuthRateLimitInfo(
      canAttemptLogin: canAttempt,
      attemptsRemaining: attemptsRemaining,
      lockoutTimeRemainingMinutes: lockoutTimeRemaining,
      maxAttempts: _maxAttempts,
      lockoutDurationMinutes: _lockoutDurationMinutes,
    );
  }
  
  /// Força reset do rate limiting (apenas para desenvolvimento/admin)
  Future<void> resetRateLimit() async {
    await _clearLockoutData();
  }
  
  /// Limpa todos os dados de lockout/contadores
  Future<void> _clearLockoutData() async {
    await Future.wait([
      _secureStorage.delete(key: _attemptCountKey),
      _secureStorage.delete(key: _lastAttemptTimeKey),
      _secureStorage.delete(key: _lockoutEndTimeKey),
    ]);
  }
}

/// Informações sobre o estado atual do rate limiting
class AuthRateLimitInfo {
  final bool canAttemptLogin;
  final int attemptsRemaining;
  final int lockoutTimeRemainingMinutes;
  final int maxAttempts;
  final int lockoutDurationMinutes;
  
  const AuthRateLimitInfo({
    required this.canAttemptLogin,
    required this.attemptsRemaining,
    required this.lockoutTimeRemainingMinutes,
    required this.maxAttempts,
    required this.lockoutDurationMinutes,
  });
  
  bool get isLocked => !canAttemptLogin;
  
  String get lockoutMessage {
    if (!isLocked) return '';
    
    if (lockoutTimeRemainingMinutes > 1) {
      return 'Muitas tentativas de login. Tente novamente em $lockoutTimeRemainingMinutes minutos.';
    } else {
      return 'Muitas tentativas de login. Tente novamente em breve.';
    }
  }
  
  String get warningMessage {
    if (isLocked || attemptsRemaining >= maxAttempts) return '';
    
    return 'Atenção: restam $attemptsRemaining tentativa(s) antes do bloqueio temporário.';
  }
}