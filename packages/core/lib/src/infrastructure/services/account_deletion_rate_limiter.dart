import 'package:flutter/foundation.dart';

/// Serviço de rate limiting para operações de exclusão de conta
/// Previne tentativas excessivas de exclusão (brute force, DoS)
class AccountDeletionRateLimiter {
  final Map<String, List<DateTime>> _deletionAttempts = {};

  /// Máximo de tentativas por janela de tempo
  static const int maxAttemptsPerWindow = 3;

  /// Duração da janela de tempo
  static const Duration windowDuration = Duration(hours: 1);

  /// Verifica se o usuário pode tentar exclusão de conta
  ///
  /// [userId] ID do usuário tentando deletar conta
  /// Returns true se ainda pode tentar, false se excedeu limite
  bool canAttemptDeletion(String userId) {
    final attempts = _deletionAttempts[userId] ?? [];
    final now = DateTime.now();
    attempts.removeWhere(
      (time) => now.difference(time) > windowDuration,
    );

    _deletionAttempts[userId] = attempts;

    final canAttempt = attempts.length < maxAttemptsPerWindow;

    if (kDebugMode) {
      debugPrint('🔒 RateLimiter: User $userId has ${attempts.length}/$maxAttemptsPerWindow attempts');
      debugPrint('   Can attempt: $canAttempt');
    }

    return canAttempt;
  }

  /// Registra uma tentativa de exclusão
  ///
  /// [userId] ID do usuário que tentou deletar conta
  void recordDeletionAttempt(String userId) {
    final attempts = _deletionAttempts[userId] ?? [];
    attempts.add(DateTime.now());
    _deletionAttempts[userId] = attempts;

    if (kDebugMode) {
      debugPrint('📝 RateLimiter: Recorded attempt for $userId (${attempts.length}/$maxAttemptsPerWindow)');
    }
  }

  /// Obtém tempo restante de cooldown se usuário estiver bloqueado
  ///
  /// [userId] ID do usuário
  /// Returns Duration restante ou null se não houver cooldown
  Duration? getRemainingCooldown(String userId) {
    final attempts = _deletionAttempts[userId] ?? [];

    if (attempts.length < maxAttemptsPerWindow) {
      return null;
    }

    final oldestAttempt = attempts.first;
    final cooldownEnd = oldestAttempt.add(windowDuration);
    final remaining = cooldownEnd.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }

  /// Limpa tentativas registradas para um usuário
  /// Útil para reset após sucesso ou para testes
  ///
  /// [userId] ID do usuário
  void clearAttempts(String userId) {
    _deletionAttempts.remove(userId);

    if (kDebugMode) {
      debugPrint('🧹 RateLimiter: Cleared attempts for $userId');
    }
  }

  /// Limpa todas as tentativas registradas
  void clearAll() {
    _deletionAttempts.clear();

    if (kDebugMode) {
      debugPrint('🧹 RateLimiter: Cleared all attempts');
    }
  }

  /// Obtém estatísticas de tentativas
  Map<String, dynamic> getStats(String userId) {
    final attempts = _deletionAttempts[userId] ?? [];
    final cooldown = getRemainingCooldown(userId);

    return {
      'userId': userId,
      'attemptCount': attempts.length,
      'maxAttempts': maxAttemptsPerWindow,
      'windowDuration': windowDuration.inMinutes,
      'isBlocked': attempts.length >= maxAttemptsPerWindow,
      'remainingCooldownMinutes': cooldown?.inMinutes,
      'attempts': attempts.map((e) => e.toIso8601String()).toList(),
    };
  }
}
